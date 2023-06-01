import 'package:fiwi/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Box box = Hive.box('user');
  List notification = [];

  _loadData(){
    notification = box.get('notification') ?? [];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black87,
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      body: SizedBox(
          width: double.infinity,
          // color: Colors.white70,
          child: ListView.builder(
              itemCount: notification.length,
              itemBuilder: ((context, index) {
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        // contentPadding: EdgeInsets.only(bottom: 5),
                        title: Text(notification[index]['title'].toString()),
                        subtitle: Text(notification[index]['body'].toString()),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 16),
                          child: Text(getTimeAgo(DateTime.parse(
                              notification[index]['dateTime'].toString())))),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                );
              }))),
    );
  }
}
