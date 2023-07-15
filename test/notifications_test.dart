import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medTalk/util/notifications.dart';
import 'package:timezone/data/latest.dart' as timezone;

void main() {
  group('Notifications', () {
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

    setUp(() {
      timezone.initializeTimeZones();
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      Notifications.initialize(flutterLocalNotificationsPlugin);
    });

    testWidgets('scheduleTextNotifications', (WidgetTester tester) async {
      await tester.runAsync(() async {
        DateTime reminderTime = DateTime.now();
        int notificationId = 1;
        String title = 'Test Notification';
        String body = 'This is a test notification';

        await Notifications.scheduleTextNotifications(
          reminderTime,
          notificationId,
          title,
          body,
          flutterLocalNotificationsPlugin,
        );

        List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        expect(pendingNotifications.length, 1);
        expect(pendingNotifications[0].id, notificationId);
        expect(pendingNotifications[0].title, title);
        expect(pendingNotifications[0].body, body);

      });
    });

    test('Schedule Text Notifications', () async {
      // Define the notification details
      final DateTime reminderTime = DateTime.now().add(Duration(seconds: 5));
      final int notificationId = 1;
      final String title = 'Test Notification';
      final String body = 'This is a test notification';

      // Schedule the notification
      await Notifications.scheduleTextNotifications(
          reminderTime, notificationId, title, body, flutterLocalNotificationsPlugin);

      // Verify that the notification is scheduled
      final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 1);

      // Wait for the notification to be triggered
      await Future.delayed(Duration(seconds: 10));

      // Verify that the notification is received
      final receivedNotifications = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      expect(receivedNotifications?.didNotificationLaunchApp, false);
    });
  });
}