import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'colors.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {

  SpeechToText speechToText = SpeechToText();
  var text = "hold the button to start speaking";
  var isListening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AvatarGlow(
        endRadius: 75,
        animate: isListening,
        duration: const Duration(milliseconds: 2000),
        glowColor: bgColor,
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) async{
            print("object");
            if(!isListening){
              var available = await speechToText.initialize();
              print(available);
              if(available){
                setState(() {
                  isListening = true;
                  speechToText.listen(
                    onResult: (result){
                      setState(() {
                        print(result);
                        text = result.recognizedWords;
                        print(text);
                      });
                    }
                  );
                });
              }
            }
          },
          onTapUp: (details){
            setState(() {
              isListening = false;
            });
            speechToText.stop();
          } ,
          child: CircleAvatar(
            backgroundColor: bgColor,
            radius: 35,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.red,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: const Icon(
          Icons.sort_rounded,
          color: Colors.black87,
        ),
        title: const Text(
          "MedTalk",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.only(bottom: 150),
        child: Text(
          text,
          style: const TextStyle(fontSize: 23, color: Colors.black),
        ),
      ),
    );
  }
}
