import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/records.dart';
import '../providers/language_provider.dart';
import '../util/common.dart';
import '../util/notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({Key? key}) : super(key: key);

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  List<String> items = [];
  Map<String, String> language = {};
  @override
  void initState() {
    super.initState();
    Notifications.initialize(flutterLocalNotificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {

    // Example of using scheduleTextNotifications
    void scheduleReminderDummy() {
      DateTime currentTime = DateTime.now();
      DateTime reminderTime = currentTime.add(Duration(seconds: 5));
      int notificationId = generateRandomId();
      String title = 'Reminder Title';
      String body = 'Reminder Body';
      Notifications.scheduleTextNotifications(
          reminderTime, notificationId, title, body, flutterLocalNotificationsPlugin);
    }

    final textTheme = Theme
        .of(context)
        .textTheme
        .apply(displayColor: Theme
        .of(context)
        .colorScheme
        .onSurface);
    Map<String, String> language =
        context.watch<LanguageProvider>().languageMap;
    items = [
      language['repeat_none'].toString(),
      language['repeat_daily'].toString(),
      language['repeat_weekly'].toString(),
      language['repeat_monthly'].toString(),
    ];
    return Expanded(

      child: SingleChildScrollView(
        child: Column(
          children: [
            // Button
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: ElevatedButton.icon(
                  onPressed: () {
                    //TODO: Add event
                    _showDialog(language, items);
                  },
                  icon: Icon(Icons.add),
                  label: Text(language['add_event'] ?? 'Add Event'),
                ),
              ),
            ),
            // List
            ...List.generate(10, (index) {
              return Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
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
                            Text('Event Name $index',
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
  void _showDialog(Map<String, String> language, List<String> items) {
    String? _selectedRepeat = language['repeat_none'];
    DateTime _selectedDate = DateTime.now();

    Future<void> _pickTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute),
      );
      if (picked != null) {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, picked.hour, picked.minute);
      }
    }

    Future<void> _pickDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now().add(Duration(days: 365)),
      );
      if (picked != null) {
        _selectedDate = DateTime(picked.year, picked.month, picked.day, _selectedDate.hour, _selectedDate.minute);
        await _pickTime();  // Chain the time picker here
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(language['add_event'] ?? 'Add Eventing'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: language['event_name'],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: language['event_description'],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: Text('Selected DateTime: ${_selectedDate.toIso8601String()}'),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            await _pickDate();
                            setState(() {});
                          },
                        ),

                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(language['repeat'] ?? 'Repeat' + ':'),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedRepeat,
                          items: items.map((String value)  {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedRepeat = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(language['cancel'] ?? 'Cancel'),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            //TODO: Add event to database
                            Navigator.pop(context);
                          },
                          child: Text(language['submit'] ?? 'Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


}