import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medTalk/util/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/font_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/records.dart';
import '../providers/language_provider.dart';
import '../util/notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({Key? key}) : super(key: key);

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}



class _CalenderScreenState extends State<CalenderScreen> {

  @override
  void initState() {
    super.initState();
    Notifications.initialize(flutterLocalNotificationsPlugin);
  }


  @override
  Widget build(BuildContext context) {

    int lastNotificationId = 0;

    int generateNotificationId() {
      lastNotificationId++;
      return lastNotificationId;
    }

    void scheduleDummyReminder() {
      DateTime currentTime = DateTime.now();
      DateTime reminderTime = currentTime.add(Duration(seconds: 5));
      print("dummy reminder time: " + reminderTime.toIso8601String());
      int notificationId = generateNotificationId(); // Generate a unique ID
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
    return Expanded(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: scheduleDummyReminder,
                  child: Text('Schedule Reminder'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}