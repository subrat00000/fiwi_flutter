import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/qr/qr_cubit.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceReportScreen extends StatefulWidget {
  final String semester;
  final String session;
  final String subjectCode;
  final String subjectName;
  const AttendanceReportScreen(
      {super.key,
      required this.semester,
      required this.session,
      required this.subjectCode,
      required this.subjectName});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  List<Student> st = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    List<Student> student =
        await BlocProvider.of<QrCubit>(context).getStudents();
    if (!mounted) {
      return;
    }
    setState(() {
      st = student;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
        ),
        title: const Text(
          'Attendance Report',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref('attendance')
                .child(widget.session)
                .child(widget.semester.toLowerCase().replaceAll(' ', ''))
                .child(widget.subjectCode.toLowerCase())
                .onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final attendance = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map)
                    .values
                    .toList();
                final present = List.generate(attendance.length, (i) {
                  final count = (attendance.elementAt(i)['uids'] as Map)
                      .values
                      .where((element) => element['status'] == true);
                  return count;
                }).expand((element) => element).toList();
                final absent = List.generate(attendance.length, (i) {
                  final count = (attendance.elementAt(i)['uids'] as Map)
                      .values
                      .where((element) => element['status'] == false);
                  return count;
                }).expand((element) => element).toList();
                Map<String, int> result = present
                    .map((e) => e["uid"]) // Get a list of uids
                    .fold<Map<String, int>>({}, (acc, uid) {
                  // Iterate through the uids and count their occurrences
                  acc[uid] = (acc[uid] ?? 0) + 1;
                  return acc;
                });
                absent.forEach((el){result[el['uid']]=0;});
                // log(absent['uid'].toString());
                final percentage = result.map((a, b) => MapEntry(
                    a, ((b / attendance.length) * 100).toStringAsFixed(1)));
                List<Student> student = st
                    .where((student) => percentage.containsKey(student.uid))
                    .toList();
                // return Text(student.map((e) => e.name).toString());
                return ListView.builder(
                    itemCount: student.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                              leading: Container(
                                width: 45,
                                height: 45,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: student[index].photo != null &&
                                        student[index].photo != ''
                                    ? CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: student[index].photo!,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      )
                                    : Image.asset('assets/no_image.png'),
                              ),
                              trailing:
                                  Text('${percentage[student[index].uid]}%'),
                              title: Text(student[index].name!),
                              onTap: () {}));
                    });
              }
            }),
      ),
    );
  }
}
