// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  var text = "Drück den Knopf um mit der Transkription zu starten";
  var isListening = false;
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
        floatingActionButton: AvatarGlow(
          // onPressed: () {  },
          // elevation: 10,

          // endRadius: 75,
          animate: isListening,
          glowColor: Colors.blue,
          endRadius: 90,
          shape: BoxShape.rectangle,
          child: GestureDetector(
            onTapDown: (details) async {
              print("object");
              if (!isListening) {
                var available = await speechToText.initialize();
                print(available);
                if (available) {
                  setState(() {
                    isListening = true;
                    speechToText.listen(
                      onResult: (result) {
                        setState(() {
                          print(result);
                          print("###############");
                          print(result.recognizedWords);
                          print("###############");

                          print("--------------------");
                          text = result.recognizedWords;
                          print(text);
                        });
                      },
                      localeId: 'de-DE',
                    );
                  });
                }
              }
            },
            onTapUp: (details) {
              setState(() {
                isListening = false;
                // text = "";
              });
              speechToText.stop();
            },
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.red,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
