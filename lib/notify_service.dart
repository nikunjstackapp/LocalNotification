import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotifyService {
  NotifyService._privateConstructor();

  static final NotifyService instance = NotifyService._privateConstructor();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late DateTime selectedDateTime;
  int uniqueChannelID = 0;
  List<PendingNotificationRequest> pendingNotificationRequests = [];


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
    returnPendingNotifications();
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification clicked with payload: $payload');
    }
  }

  Future<void> scheduleNotification({Function? setState, String? title, String? body}) async {
    print("send Notify Called");
    uniqueChannelID = DateTime.now().millisecond;
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'sender_channel', 'Sender Channel',
        channelDescription: 'Channel for sender notifications',
        priority: Priority.high,
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        color: Colors.yellow,sound: RawResourceAndroidNotificationSound('music'));

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
      uniqueChannelID, //gamme e int api sakvi tamtare//
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    returnPendingNotifications();
    setState!(() {});
  }

  Future<void> cancelAllNotifications(Function setState) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    returnPendingNotifications();
    setState(() {});
    print('Cancel Notification called');
  }

  Future<void> cancelSingleNotifications(int id, Function setState) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    returnPendingNotifications();
    setState(() {});
    print('Cancel single Notification called');
  }

  returnPendingNotifications() async {
    pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
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
