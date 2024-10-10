import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Book Request Received',
      description: 'Your have been booked by a customer!.',
      date: DateTime.now().subtract(Duration(hours: 1)),
    ),
     NotificationItem(
      title: 'Book Request Received',
      description: 'Your have been booked by a customer!.',
      date: DateTime.now().subtract(Duration(days: 2, hours: 3)),
    ),
    NotificationItem(
      title: 'Service Completed',
      description: 'Congratulations! You have completed the service.',
      date: DateTime.now().subtract(Duration(days: 6, hours: 1)),
    ),
      NotificationItem(
      title: 'Book Request Received',
      description: 'Your have been booked by a customer!.',
      date: DateTime.now().subtract(Duration(days: 14, hours: 2)),
    ),
     NotificationItem(
      title: 'Service Completed',
      description: 'Congratulations! You have completed the service.',
      date: DateTime.now().subtract(Duration(days: 21, hours: 2, )),
    ),
    // Add more notifications here
  ];

  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 7, 49, 112),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(notification.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.description),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('MM/dd/yyyy - hh:mm a').format(notification.date),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              trailing: Icon(Icons.notification_important, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final DateTime date;

  NotificationItem({
    required this.title,
    required this.description,
    required this.date,
  });
}
