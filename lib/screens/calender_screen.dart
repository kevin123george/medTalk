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

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Button
            Container(
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton.icon(
                  onPressed: () {
                    //TODO: Add event
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Event'),
                ),
              ),
            ),
            // List
            ...List.generate(10, (index) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    onTap: () {
                      // Show dialog
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Event $index'),
                            content: Text('This is the text of event $index'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Event Name $index', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text('Short description of Event $index'),
                            SizedBox(height: 10),
                            Text('Time of event $index'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}