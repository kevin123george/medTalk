import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../models/records.dart';
import '../providers/language_provider.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({Key? key}) : super(key: key);

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}



class _CalenderScreenState extends State<CalenderScreen> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme
        .of(context)
        .textTheme
        .apply(displayColor: Theme
        .of(context)
        .colorScheme
        .onSurface);
    return Expanded(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
          ),
        ),
      ),
    );
  }
}