import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../models/records.dart';
import '../providers/language_provider.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key? key}) : super(key: key);

  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}



class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  var text;
  var helperText;
  var isListening = false;
  var isButtonPressed = false;
  SpeechToText speechToText = SpeechToText();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final language = context.read<LanguageProvider>().languageMap;
    text = language['intro_text']!;
    helperText = language['helper_text']!;
  }


  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, String> language = context.watch<LanguageProvider>().languageMap;
    // text = language['intro_text']!;
    // helperText = language['helper_text']!;
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    return Expanded(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: Text(
              text,
              style: _getTextStyle(textTheme),
            ),
          ),
        ),
        floatingActionButton: AvatarGlow(
          animate: isButtonPressed,
          shape: BoxShape.rectangle,
          glowColor: Colors.red, // Customize the glow color
          endRadius: 100.0,
          duration: const Duration(milliseconds: 2000),
          repeat: true,
          showTwoGlows: true,
          repeatPauseDuration: const Duration(milliseconds: 10),
          child: FloatingActionButton.large(
            elevation: isButtonPressed ? 20 : 0, // Set elevation based on button state
            // backgroundColor: isButtonPressed ? Colors.green : null, // Set background color based on button state
            onPressed: () async {
              if (!isButtonPressed) {
                var available = await speechToText.initialize();
                if (available) {
                  print("the thing is available");
                  setState(() {
                    isButtonPressed = true;
                    isListening = true;
                    speechToText.listen(
                      onResult: (result) {
                        setState(() {
                          List<dynamic> alternates =
                          result.toJson()["alternates"];
                          List<String> recognizedWords = alternates
                              .map((alternate) => alternate["recognizedWords"])
                              .toList()
                              .cast<String>();
                          text = result.recognizedWords;
                        });
                      },
                      localeId: 'de-DE',
                    );
                  });

                  timer = Timer.periodic(
                      Duration(milliseconds: 50), (timer) async {
                    // Code to be executed every 10 seconds
                    if (isButtonPressed && !speechToText.isListening) {
                      available = await speechToText.initialize();
                      if (!available) {
                        speechToText.stop();
                        speechToText = SpeechToText();
                        available = await speechToText.initialize();
                      }
                      print("Triggered every 10 seconds");
                      print(available);
                      speechToText.listen(
                        onResult: (result) {
                          setState(() {
                            List<dynamic> alternates =
                            result.toJson()["alternates"];
                            List<String> recognizedWords = alternates
                                .map((alternate) =>
                            alternate["recognizedWords"])
                                .toList()
                                .cast<String>();
                            text = result.recognizedWords;
                          });
                        },
                        localeId: 'de-DE',
                      );
                      // Records? latestRecord = await DatabaseHelper.fetchLatestRecord();
                      // if (text != helperText && !speechToText.isListening && latestRecord != null && latestRecord.text != text)
                      if (text != helperText && !speechToText.isListening) {
                        final recordEntry = Records(
                            text: text,
                            timestamp:
                            DateTime.now().millisecondsSinceEpoch);
                        final generatedId =
                        await DatabaseHelper.addRecord(recordEntry);
                      }
                    }
                  });
                }
              } else {
                setState(() {
                  isButtonPressed = false;
                  isListening = false;
                });
                if (text != helperText) {
                  final recordEntry = Records(
                      text: text,
                      timestamp: DateTime.now().millisecondsSinceEpoch);
                  final generatedId =
                  await DatabaseHelper.addRecord(recordEntry);
                }
                speechToText.stop();

                timer?.cancel(); // Cancel the timer when the button is pressed
              }
            },
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.red,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  TextStyle? _getTextStyle(TextTheme textTheme) {
    double value = context.watch<FontProvider>().font_size;
    return value == 0.0
        ? textTheme.displaySmall
        : value == 1.0
        ? textTheme.displayMedium
        : value == 2.0
        ? textTheme.displayLarge
        : textTheme.displayMedium;
  }
}

class TextStyleExample extends StatelessWidget {
  const TextStyleExample({
    Key? key,
    required this.name,
    required this.style,
  }) : super(key: key);

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(name, style: style),
    );
  }
}
