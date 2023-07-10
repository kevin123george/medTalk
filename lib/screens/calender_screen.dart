import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/records.dart';
import '../models/schedulers.dart';
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
  List<Schedulers> schedulers = [];
  List<String> items = [];
  Map<String, String> language = {};

  @override
  void initState() {
    fetchEvents();
    super.initState();
    Notifications.initialize(flutterLocalNotificationsPlugin);
  }

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

  void scheduleNotifications(DateTime reminderTime, String title, String body) {
    int notificationId = generateRandomId();
    Notifications.scheduleTextNotifications(
        reminderTime, notificationId, title, body, flutterLocalNotificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
      displayColor: Theme.of(context).colorScheme.onSurface,
    );
    language = context.watch<LanguageProvider>().languageMap;
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
              width: MediaQuery.of(context).size.width,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: FloatingActionButton.large(
                  onPressed: () {
                    _showDialog(language, items);
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text(language['add_event'] ?? 'Add Event'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // List
            ...schedulers.map((Schedulers scheduler) {
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
                            title: Text(
                              scheduler.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(scheduler.body ?? ''),
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
                            Text(
                              scheduler.title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Text(scheduler.body ?? ''),
                            SizedBox(height: 10),
                            Text(getFormattedTimestamp(scheduler.startDateTime!.toInt())),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showDialog(Map<String, String> language, List<String> items) {
    String? _selectedRepeat = language['repeat_none'];
    DateTime _selectedDate = DateTime.now();
    String? _eventName = "";
    String? _eventDescription = "";

    Future<void> _pickTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute),
      );
      if (picked != null) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
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
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
        await _pickTime(); // Chain the time picker here
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        final eventTitleController = TextEditingController();
        final eventDescriptionController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(language['add_event'] ?? 'Add Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: eventTitleController,
                      decoration: InputDecoration(
                        labelText: language['event_name'],
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          _eventName = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: eventDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: language['event_description'],
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          _eventDescription = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: Text('Selected DateTime: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate)}'),
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
                          items: items.map(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
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
                            final newScheduler = Schedulers(
                              title: eventTitleController.text,
                              startDateTime: _selectedDate.microsecondsSinceEpoch,
                              endDateTime: null,
                              body: eventDescriptionController.text,
                              repeatType: getRepeatTypeFromString(_selectedRepeat ?? ''),
                              reminderTime: _selectedDate.microsecondsSinceEpoch - 5000,
                              // repeatEndDate: DateTime.now(),
                            );

                            DatabaseHelper.insertScheduler(newScheduler).then((schedulerId) {
                              if (schedulerId != null) {
                                print('Scheduler inserted with ID: $schedulerId');
                                // TODO: Refresh the list of events
                                fetchEvents();
                              } else {
                                print('Failed to insert scheduler');
                              }
                            });

                            Navigator.pop(context);
                            scheduleNotifications(_selectedDate, _eventName!, _eventDescription!);
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

  RepeatType getRepeatTypeFromString(String type) {
    switch (type) {
      case 'Repeat None':
        return RepeatType.None;
      case 'Repeat Daily':
        return RepeatType.Daily;
      case 'Repeat Weekly':
        return RepeatType.Weekly;
      case 'Repeat Monthly':
        return RepeatType.Monthly;
      default:
        return RepeatType.None;
    }
  }

  // Future<int?> insertScheduler(Schedulers scheduler) async {
  //   final db = await DatabaseHelper.instance.database;
  //   return await db.insert('schedulers', scheduler.toMap());
  // }

  Future<void> fetchEvents() async {
    final listOfSchedules = await DatabaseHelper.getAllSchedulers();
    setState(() {
      schedulers = listOfSchedules;
    });
  }

  String getFormattedTimestamp(int timestampInMilliseconds) {
    DateTime dateTime =
    DateTime.fromMicrosecondsSinceEpoch(timestampInMilliseconds);
    String formattedDateTime =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }
}