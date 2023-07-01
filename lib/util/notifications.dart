import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {

    timezone.initializeTimeZones();

    // Android Settings
    final AndroidInitializationSettings androidSetting =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        getDarwinNotificationCategory();

    // iOS and macOS Settings
    final DarwinInitializationSettings darwinSettings =
    DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: darwinNotificationCategories,
    );

    var initSettings =
    InitializationSettings(android: androidSetting, iOS: darwinSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });
  }

  
  static Future scheduleTextNotifications(
      DateTime reminderTime,
      int notificationId,
      String title,
      String body,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    AndroidNotificationDetails androidNotificationDetails =
    new AndroidNotificationDetails(
      "medTalk_channel_Id",
      "medTalk_channel_name",
      channelDescription:  "medTalk_channel_description",
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );

    var platformChannelSpecifics  = NotificationDetails(android: androidNotificationDetails);

    timezone.TZDateTime zonedTime = timezone.TZDateTime.from(
      reminderTime,
      timezone.local,
    ).subtract(const Duration(seconds: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      zonedTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'notification_payload',
    );

  }

  static List<DarwinNotificationCategory> getDarwinNotificationCategory() {
    /// A notification action which triggers a url launch event
    const String urlLaunchActionId = 'id_1';
    /// A notification action which triggers a App navigation event
    const String navigationActionId = 'id_3';
    /// Defines a iOS/MacOS notification category for text input actions.
    const String darwinNotificationCategoryText = 'textCategory';
    /// Defines a iOS/MacOS notification category for plain actions.
    const String darwinNotificationCategoryPlain = 'plainCategory';

    return <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];
  }

  // void onDidReceiveLocalNotification(
  //     int id, String title, String body, String payload) async {
  //   // display a dialog with the notification details, tap ok to go to another page
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => CupertinoAlertDialog(
  //       title: Text(title),
  //       content: Text(body),
  //       actions: [
  //         CupertinoDialogAction(
  //           isDefaultAction: true,
  //           child: Text('Ok'),
  //           onPressed: () async {
  //             Navigator.of(context, rootNavigator: true).pop();
  //             await Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => SecondScreen(payload),
  //               ),
  //             );
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }
}