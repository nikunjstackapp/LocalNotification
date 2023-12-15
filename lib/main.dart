import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:notify_demo_gpt/notify_service.dart';

void main() async {
  // Initialize time zone
  tzdata.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime currentDateTime;

  @override
  void initState() {
    super.initState();
    // Initialize the plugin
    currentDateTime = DateTime.now();

    NotifyService.instance.initializeNotifications();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}  ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Notifications Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  NotifyService.instance.selectDateTime(context);
                });
              },
              child: const Text('Select Date and Time'),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text('Selected Date :'),
          const SizedBox(height: 5),
          Text(
            NotifyService.instance.selectedDateTime.toString(),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              currentDateTime = DateTime.now();
              return Text(
                textAlign: TextAlign.center,
                'Current Time: \n${_formatDateTime(currentDateTime)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              );
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                NotifyService.instance.scheduleNotification(title: "Write Title", body: "Write Body Of Notification");
              },
              child: const Text('Press To Send Notify'),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => NotifyService.instance.cancelAllNotifications(),
              child: const Text('Cancel All Notification'),
            ),
          )
        ],
      ),
    );
  }
}
