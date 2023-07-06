import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Box box = Hive.box('user');
  String? session;
  String? semester;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List presentPercent = [];

  @override
  void initState() {
    super.initState();
    session = box.get('session') ?? '';
    semester = box.get('semester') ?? '';

    _getData();
  }

  _getData() async {
    List temp = [];
    DatabaseEvent course = await FirebaseDatabase.instance
        .ref('courseList')
        .orderByChild('semester')
        .equalTo(semester)
        .once();
    if (course.snapshot.value != null) {
      final courseList = Map<String, dynamic>.from(course.snapshot.value as Map)
          .values
          .toList();
      courseList.forEach((element) async {
        String code = element['code'].toString().toLowerCase();
        DatabaseEvent data = await FirebaseDatabase.instance
            .ref('attendance')
            .child(session!)
            .child(semester!.toLowerCase().replaceAll(' ', ''))
            .child(code)
            .once();
        if (data.snapshot.value != null) {
          final itemsList =
              Map<String, dynamic>.from(data.snapshot.value as Map)
                  .values
                  .toList();
          final present = List.generate(itemsList.length, (i) {
            final count = (itemsList.elementAt(i)['uids'] as Map)
                .values
                .where((element) =>
                    element['status'] == true &&
                    element['uid'] == _auth.currentUser!.uid)
                .length;
            return count;
          });
          double percent =
              (present.reduce((a, b) => a + b) / itemsList.length) * 100;
          log(code + percent.toString());
          temp.add({code: percent});
        }
      });
      if (!mounted) {
      return;
    }
      setState(() {
        presentPercent = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/qrscan'),
          child: const Icon(Icons.qr_code_scanner_rounded),
        ),
        body: StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref('courseList')
                .orderByChild('semester')
                .equalTo(semester)
                .onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.snapshot.value == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final data = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map)
                    .values
                    .toList();
                return ListView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      if (presentPercent.isNotEmpty) {
                        String percent = presentPercent
                            .where((e) =>
                                data[index]['code'].toString().toLowerCase() ==
                                (e as Map).keys.first)
                            .first[data[index]['code'].toString().toLowerCase()]
                            .toString();
                        return Card(
                            child: ListTile(
                          trailing: Text('$percent%'),
                          title: Text(
                              '${data[index]['name']}(${data[index]['code']})'),
                        ));
                      } else {
                        return Container();
                      }
                    });
              }
            }));
  }
}
