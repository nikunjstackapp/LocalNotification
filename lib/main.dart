import 'package:flutter/material.dart';
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
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

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
        body: StatefulBuilder(
          builder: (context, setState) {
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 30),
              shrinkWrap: true,
              physics: PageScrollPhysics(),
              children: [
                const SizedBox(height: 20),
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
                const SizedBox(height: 30),
                TextField(decoration: InputDecoration(hintText: 'Title'), controller: titleController),
                const SizedBox(height: 10),
                TextField(decoration: InputDecoration(hintText: 'Body'), controller: bodyController),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      NotifyService.instance.scheduleNotification(
                          title: titleController.text, body: bodyController.text, setState: setState);
                      titleController.clear();
                      bodyController.clear();
                    },
                    child: const Text('Press To Send Notify'),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: PageScrollPhysics(),
                  itemCount: NotifyService.instance.pendingNotificationRequests.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: ListTile(
                      title: Text(NotifyService.instance.pendingNotificationRequests[index].title.toString()),
                      subtitle: Text(NotifyService.instance.pendingNotificationRequests[index].body.toString()),
                      trailing: IconButton(
                        onPressed: () => NotifyService.instance
                            .cancelSingleNotifications(NotifyService.instance.pendingNotificationRequests[index].id!, setState),
                        icon: Text(
                          'Cansel\nSchedule',
                          style: TextStyle(fontSize: 8),
                        ),
                      ),
                    ));
                  },
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () => NotifyService.instance.cancelAllNotifications(setState),
                    child: const Text('Cancel All Notification'),
                  ),
                ),
              ],
            );
          },
        ));
  }
}
