import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:notify_demo_gpt/notify_service.dart';

class NotifyService {
  NotifyService._privateConstructor();

  static final NotifyService instance = NotifyService._privateConstructor();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late DateTime selectedDateTime;

  Future<void> initializeNotifications() async {
    selectedDateTime = DateTime.now();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings ios = const DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification clicked with payload: $payload');
    }
  }

  Future<void> scheduleNotification({String? title, String? body}) async {
    print("send Notify Called");
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'sender_channel', 'Sender Channel',
        channelDescription: 'Channel for sender notifications',
        priority: Priority.high,
        importance: Importance.max,
        enableVibration: true,playSound: true,
        color: Colors.yellow);

    DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    tz.TZDateTime scheduledTime = getScheduledDateTime();

    print('scheduledTime --> ${selectedDateTime}');
    print('date time Now --> ${DateTime.now()}');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('Cancel Notification called');
  }

  Future<void> selectDateTime(BuildContext context) async {
    selectedDateTime = DateTime.now();

    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDateTime != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        selectedDateTime = DateTime(
          pickedDateTime.year,
          pickedDateTime.month,
          pickedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  tz.TZDateTime getScheduledDateTime() {
    return tz.TZDateTime.from(selectedDateTime, tz.local);
  }
}
