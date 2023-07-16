import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:uuid/uuid.dart';

import '../models/records.dart';
import '../providers/language_provider.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key? key}) : super(key: key);

  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}



class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  var resultList = [];
  var session;
  var initPressed = false;
  var text;
  var locationId;
  var resultText = '';
  var helperText;
  var isListening = false;
  var isButtonPressed = false;
  String records = '';
  SpeechToText speechToText = SpeechToText();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final language = context.read<LanguageProvider>().languageMap;
    text = language['intro_text']!;
    helperText = language['helper_text']!;
    session = Uuid().v4();
  }


  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> language = context.watch<LanguageProvider>().languageMap;
    text = language['intro_text']!;
    helperText = language['helper_text']!;
    locationId = language['locale-id']!;
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);
    return Expanded(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          // alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                child: Text(
                  resultText,
                  // style: _getTextStyle(textTheme),
                ),
              ),
              Divider( // Add a divider here
                height: 20, // Adjust the height of the divider as needed
                thickness: 2, // Adjust the thickness of the divider as needed
                color: Colors.grey, // Adjust the color of the divider as needed
              ),
              SizedBox(height: 20), // Adding spacing between the text boxes

              SingleChildScrollView(
                child: Text(
                  initPressed ?  records : text,

                  style: _getTextStyle(textTheme),
                ),
              ),
            ],
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
              setState(() {
                initPressed = true;
              });
              if (!isButtonPressed) {
                var available = await speechToText.initialize();
                if (available) {
                  setState(() {
                    isButtonPressed = true;
                    isListening = true;
                    speechToText.listen(
                      onResult: (result) {
                        setState(() {
                          resultText = result.recognizedWords;
                        });
                      },
                      localeId: locationId,
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
                      speechToText.listen(
                        onResult: (result) {
                          setState(() {
                            resultText = result.recognizedWords;
                          });
                        },
                        localeId: locationId,
                      );
                      // Records? latestRecord = await DatabaseHelper.fetchLatestRecord();
                      // if (text != helperText && !speechToText.isListening && latestRecord != null && latestRecord.text != text)
                      if (resultText != helperText && !speechToText.isListening) {
                        final recordEntry = Records(
                            text: resultText,
                            timestamp: DateTime.now().millisecondsSinceEpoch,
                            session: session
                        );

                        final generatedId = await DatabaseHelper.addRecord(recordEntry);
                        previousSessionResults();

                      }
                    }
                  });
                }
              } else {
                setState(() {
                  isButtonPressed = false;
                  isListening = false;
                });
                if (resultText != helperText) {
                  final recordEntry = Records(
                      text: resultText,
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      session: session
                  );

                  final generatedId =
                  await DatabaseHelper.addRecord(recordEntry);
                  var sessionRecords = await DatabaseHelper.fetchRecordBySession(session);
                  previousSessionResults();
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

  Future<String> previousSessionResults() async {
    final List<Records> sessionRecords = await DatabaseHelper.fetchRecordBySession(session);
    var concat = DatabaseHelper.concatenateText(sessionRecords);
    setState(() {
      records = concat;
    });
    return concat.toString();
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
