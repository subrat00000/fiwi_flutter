import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/create_batch/create_batch_cubit.dart';
import 'package:fiwi/cubits/qr/qr_cubit.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final String datetime;
  final String semester;
  final String session;
  final String subjectCode;
  final String subjectName;
  const StudentAttendanceScreen(
      {super.key,
      required this.datetime,
      required this.semester,
      required this.session,
      required this.subjectCode,
      required this.subjectName});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Student>? student;

  selectedStudent() async {
    List<Student> ur =
        await BlocProvider.of<CreateBatchCubit>(context).getStudents();
    setState(() {
      student = ur;
    });
  }

  @override
  void initState() {
    super.initState();

    selectedStudent();
  }

  @override
  Widget build(BuildContext context) {
    log(widget.datetime);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushNamed(context, '/manageattendance');
        },
        child: const Icon(Icons.arrow_forward_ios_rounded),
      ),
      appBar: AppBar(
        title: const Text(
          'Verify Attendance',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          color: Colors.black54,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        // width: double.infinity,
        color: Colors.white70,
        child: Column(children: [
          Expanded(
            child: student != null
                ? StreamBuilder(
                    stream: FirebaseDatabase.instance
                        .ref('attendance')
                        .child(widget.session)
                        .child(
                            widget.semester.toLowerCase().replaceAll(' ', ''))
                        .child(widget.subjectCode.toLowerCase())
                        .child(widget.datetime)
                        .onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data!.snapshot.value == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        final itemsMap = snapshot.data!.snapshot.value as Map;
                        final itemsListmap = itemsMap['uids'] as Map;
                        final value = itemsListmap.values.toList();
                        List<bool> selected =
                            value.map((e) => e['status'] as bool).toList();
                        return ListView.builder(
                            itemCount: value.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10.0),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => BlocProvider.of<QrCubit>(context)
                                    .takeAttendance(
                                        widget.session,
                                        widget.semester,
                                        widget.subjectCode,
                                        widget.datetime,
                                        value[index]['uid'],
                                        !selected[index]),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: selected[index]
                                      ? Colors.tealAccent
                                      : Colors.deepOrange[100],
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      margin: const EdgeInsets.all(4),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration:
                                          const BoxDecoration(boxShadow: [
                                        BoxShadow(
                                          color: Colors.white,
                                        ),
                                      ], shape: BoxShape.circle),
                                      child: student!
                                                      .where((e) =>
                                                          e.uid ==
                                                          value[index]['uid'])
                                                      .first
                                                      .photo !=
                                                  null &&
                                              student!
                                                      .where((e) =>
                                                          e.uid ==
                                                          value[index]['uid'])
                                                      .first
                                                      .photo !=
                                                  ''
                                          ? CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: student!
                                                  .where((e) =>
                                                      e.uid ==
                                                      value[index]['uid'])
                                                  .first
                                                  .photo!,
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            )
                                          : Image.asset('assets/no_image.png'),
                                    ),
                                    title: Text(
                                        '${student!.where((e) => e.uid == value[index]['uid']).first.name}'),
                                    subtitle: student!
                                                .where((e) =>
                                                    e.uid ==
                                                    value[index]['uid'])
                                                .first
                                                .email !=
                                            null
                                        ? Text(student!
                                            .where((e) =>
                                                e.uid == value[index]['uid'])
                                            .first
                                            .email!)
                                        : Text(student!
                                            .where((e) =>
                                                e.uid == value[index]['uid'])
                                            .first
                                            .phone!),
                                    trailing: selected[index]
                                        ? const Text('P')
                                        : const Text('A'),
                                  ),
                                ),
                              );
                            });
                      }
                    })
                : Container(),
          )
        ]),
      ),
    );
  }
}
