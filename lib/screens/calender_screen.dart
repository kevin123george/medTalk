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

  List<int> scheduleNotifications(
      DateTime startDate, DateTime endDate, RepeatType repeatType, String title, String body) {
    List<int> notificationIds = [];
    int notificationId = generateRandomId();
    Notifications.scheduleTextNotifications(
        startDate, notificationId, title, body, flutterLocalNotificationsPlugin);
    notificationIds.add(notificationId);
    switch (repeatType) {
      case RepeatType.None:
        return notificationIds;
      case RepeatType.Daily:
        {
          DateTime nextDate = startDate.add(Duration(days: 1));
          while (nextDate.isBefore(endDate) || nextDate.isAtSameMomentAs(endDate)) {
            notificationId = generateRandomId();
            Notifications.scheduleTextNotifications(
                nextDate, notificationId, title, body, flutterLocalNotificationsPlugin);
            notificationIds.add(notificationId);
            nextDate = nextDate.add(Duration(days: 1));
          }
          return notificationIds;
        }
      case RepeatType.Weekly:
        {
          DateTime nextDate = startDate.add(Duration(days: 7));
          while (nextDate.isBefore(endDate) || nextDate.isAtSameMomentAs(endDate)) {
            notificationId = generateRandomId();
            Notifications.scheduleTextNotifications(
                nextDate, notificationId, title, body, flutterLocalNotificationsPlugin);
            notificationIds.add(notificationId);
            nextDate = nextDate.add(Duration(days: 7));
          }
          return notificationIds;
        }
      case RepeatType.Monthly:
        {
          DateTime nextDate = DateTime(startDate.year, startDate.month + 1, startDate.day,
              startDate.hour, startDate.minute, startDate.second, startDate.millisecond, startDate.microsecond);
          while (nextDate.isBefore(endDate) || nextDate.isAtSameMomentAs(endDate)) {
            notificationId = generateRandomId();
            Notifications.scheduleTextNotifications(
                nextDate, notificationId, title, body, flutterLocalNotificationsPlugin);
            notificationIds.add(notificationId);
            nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day,
                nextDate.hour, nextDate.minute, nextDate.second, nextDate.millisecond, nextDate.microsecond);
          }
          return notificationIds;
        }
      default:
        return notificationIds;
    }
  }

  void cancelScheduledNotifications(List<int> notificationIds) {
    for (int id in notificationIds) {
      flutterLocalNotificationsPlugin.cancel(id);
    }
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
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirmation'),
                                        content: Text(language['delete_confirm'] ?? 'Are you sure you want to delete.?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(language['cancel'] ?? 'Cancel'),
                                            onPressed: () {
                                              print('Cancel button pressed');
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(language['delete'] ?? 'Delete'),
                                            onPressed: () async {
                                              DatabaseHelper dbHelper = DatabaseHelper();
                                              if (scheduler.id != null) {
                                                await dbHelper.deleteScheduler(scheduler.id!);
                                                print('Delete button pressed for scheduler with title: ${scheduler.title}');
                                                Navigator.of(context).pop();
                                                await fetchEvents();
                                              }

                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
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
    DateTime _endDate = DateTime.now().add(Duration(days: 1));
    String? _eventName = "";
    String? _eventDescription = "";

    Future<DateTime> _pickTime(String helpText, DateTime initialTime) async {
      final TimeOfDay? picked = await showTimePicker(
        helpText: helpText,
        context: context,
        initialTime: TimeOfDay(hour: initialTime.hour, minute: initialTime.minute),
      );
      if (picked != null) {
        return DateTime(
          initialTime.year,
          initialTime.month,
          initialTime.day,
          picked.hour,
          picked.minute,
        );
      } else {
        return initialTime;
      }
    }

    Future<void> _pickEndDate() async {
      final DateTime? picked = await showDatePicker(
        helpText: "Select End Date",
        context: context,
        initialDate: _endDate,
        firstDate: _endDate,
        lastDate: DateTime.now().add(Duration(days: 365)),
      );
      if (picked != null) {
        _endDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endDate.hour,
          _endDate.minute,
        );
        _endDate = await _pickTime("Select end time", _endDate);
      }
    }

    Future<void> _pickDate() async {
      final DateTime? picked = await showDatePicker(
        helpText: "Select Start Date",
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
        _selectedDate = await _pickTime("Select start time", _selectedDate); // Chain the time picker here
        _endDate = _selectedDate.add(Duration(days: 1));
        await _pickEndDate();
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
                          child: Text('Start Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate)}'),
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
                        Flexible(
                          child: Text('End Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_endDate)}'),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            await _pickEndDate();
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
                            var repeatType = getRepeatTypeFromString(_selectedRepeat ?? '');
                            List<int> notificationIds = scheduleNotifications(_selectedDate, _endDate, repeatType, _eventName!, _eventDescription!);
                            final newScheduler = Schedulers(
                              title: eventTitleController.text,
                              startDateTime: _selectedDate.microsecondsSinceEpoch,
                              endDateTime: _endDate?.microsecondsSinceEpoch,
                              body: eventDescriptionController.text,
                              repeatType: repeatType,
                              reminderTime: _selectedDate.microsecondsSinceEpoch - 5000,
                              notificationIds: notificationIds
                              // repeatEndDate: DateTime.now(),
                            );

                            DatabaseHelper.insertScheduler(newScheduler).then((schedulerId) {
                              if (schedulerId != null) {
                                print('Scheduler inserted with ID: $schedulerId');
                                print('db save ist!!!');
                                print(newScheduler);
                                // TODO: Refresh the list of events
                                fetchEvents();
                              } else {
                                print('Failed to insert scheduler');
                              }
                            });

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

  RepeatType getRepeatTypeFromString(String type) {
    switch (type) {
      case 'None':
        return RepeatType.None;
      case 'Daily':
        return RepeatType.Daily;
      case 'Weekly':
        return RepeatType.Weekly;
      case 'Monthly':
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