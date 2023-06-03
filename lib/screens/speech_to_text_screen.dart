// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';

import '../models/records.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  var text = "Drück den Knopf um mit der Transkription zu starten";
  var helperText = "Drück den Knopf um mit der Transkription zu starten";
  var isListening = false;
  var isButtonPressed = false;
  SpeechToText speechToText = SpeechToText();

  @override
  Widget build(BuildContext context) {
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
                style: _getTextStyle(textTheme)
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var available = await speechToText.initialize();
            if (available) {
              if (!isButtonPressed) {
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
              } else {
                setState(() {
                  isButtonPressed = false;
                  isListening = false;
                });
                if(text != helperText){
                  final recordEntry = Records(text: text, timestamp: DateTime.now().millisecondsSinceEpoch);
                  final generatedId = await DatabaseHelper.addRecord(recordEntry);
                }
                speechToText.stop();
              }
            } else {
              setState(() {
                isButtonPressed = false;
                isListening = false;
              });
            }
          },
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: Colors.red,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  TextStyle? _getTextStyle(TextTheme textTheme) {
    double value = context.watch<FontProvider>().font_size;
    return value == 0.0 ? textTheme.displaySmall
              : value == 1.0 ? textTheme.displayMedium
              : value == 2.0 ? textTheme.displayLarge
              : textTheme.displayMedium;
  }
}

class TextStyleExample extends StatelessWidget {
  const TextStyleExample({
    super.key,
    required this.name,
    required this.style,
  });

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
