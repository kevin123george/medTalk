import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MedTalk/speech_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MedTalk());
}

class MedTalk extends StatelessWidget {
  const MedTalk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedTalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SpeechScreen(),
    );
  }
}

