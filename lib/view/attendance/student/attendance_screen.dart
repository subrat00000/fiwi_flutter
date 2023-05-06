import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/student_attendance/attendance_cubit.dart';
import 'package:fiwi/cubits/student_attendance/attendance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Box box = Hive.box('user');
  String? session;
  String? semester;

  @override
  void initState() {
    super.initState();
    session = box.get('session') ?? '';
    semester = box.get('semester') ?? '';

    // _getPercent();
  }

  _getData(String subjectCode) async {
    DatabaseEvent data = await FirebaseDatabase.instance
        .ref('attendance')
        .child(session!)
        .child(semester!.toLowerCase().replaceAll(' ', ''))
        .child(subjectCode.toLowerCase())
        .once();
    if (data.snapshot.value != null) {
      final itemsList = Map<String, dynamic>.from(data.snapshot.value as Map);
      log(itemsList.toString());
    } else {
      log('Empty');
    }
  }

  _getPercent(String subjectCode) {
    _getData(subjectCode);
    return 'a';
  }

  @override
  Widget build(BuildContext context) {
    log(box.get('semester'));
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
                      return Card(
                          child: ListTile(
                        trailing: Text(_getPercent(data[index]['code'])),
                        title: Text(
                            '${data[index]['name']}(${data[index]['code']})'),
                      ));
                    });
              }
            }));
  }
}
