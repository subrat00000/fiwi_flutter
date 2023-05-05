import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/qr/qr_cubit.dart';
import 'package:fiwi/cubits/qr/qr_state.dart';
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
  List<String> uids = [];
  bool isSimple = true;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final cubit = BlocProvider.of<QrCubit>(context);
    List<Student> student = await cubit.getStudents();
    List<String> u = await cubit.getBatchUids(widget.session);
    if (!mounted) {
      return;
    }
    setState(() {
      st = student;
      uids = u;
    });
  }

  Widget profilepic(photo){ return Container(
    width: 45,
    height: 45,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
    ),
    child: photo != null && photo != ''
        ? CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: photo!,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        : Image.asset('assets/no_image.png'),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Center(
              child: isSimple
                  ? Text('Simple', style: TextStyle(color: Colors.black87))
                  : Text(
                      'Details',
                      style: TextStyle(color: Colors.black87),
                    ),
            ),
            Switch(
                value: isSimple,
                onChanged: (value) {
                  setState(() {
                    isSimple = value;
                  });
                })
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87),
          ),
          title: Text(
            'Attendance Report(${widget.session})',
            style: const TextStyle(color: Colors.black87, fontSize: 20),
          ),
        ),
        body: BlocListener<QrCubit, QrState>(
          listener: (context, state) {
            if (state is UpdateAttendanceSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Updated Successfully."),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ));
            } else if (state is QrErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error.toString()),
                backgroundColor: Colors.redAccent[400],
                behavior: SnackBarBehavior.floating,
              ));
            }
          },
          child: st.isNotEmpty
              ? StreamBuilder(
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
                      Map<String, int> absentResult = absent
                          .map((e) => e["uid"])
                          .fold<Map<String, int>>({}, (acc, uid) {
                        acc[uid] = (acc[uid] ?? 0) + 1;
                        return acc;
                      });

                      Map<String, int> absentPercentage = absentResult.map((a,
                              b) =>
                          MapEntry(a, ((b / attendance.length) * 100).toInt()));
                      absentPercentage.forEach((key, value) {
                        if (value == 100) {
                          result[key] = 0;
                        }
                      });
                      final percentage = result.map((a, b) => MapEntry(a,
                          ((b / attendance.length) * 100).toStringAsFixed(1)));
                      List<Student> student = st
                          .where(
                              (student) => percentage.containsKey(student.uid))
                          .toList();
                      student.sort((a, b) => a.name!.compareTo(b.name!));
                      attendance.sort((a, b) =>
                          a['createdAt'].toString().compareTo(b['createdAt']));
                      //Second ListView.builder
                      // log(uids.toString()+"************");
                      List<Student> batchStudent = st
                          .where((student) => uids.contains(student.uid))
                          .toList();
                      batchStudent.sort((a, b) => a.name!.compareTo(b.name!));
                      return Stack(
                        children: [
                          Visibility(
                            visible: isSimple,
                            child: ListView.builder(
                                itemCount: student.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                      child: ListTile(
                                          leading: profilepic(student[index].photo),
                                          trailing: Text(
                                              '${percentage[student[index].uid]}%'),
                                          title: Text(student[index].name!),
                                          onTap: () {}));
                                }),
                          ),
                          Visibility(
                            visible: !isSimple,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  columns: [
                                    const DataColumn(
                                      label: Text(''),
                                    ),
                                    const DataColumn(
                                      label: Text('Name'),
                                    ),
                                    for (int i = 0; i < attendance.length; i++)
                                      DataColumn(
                                        label: Text(
                                            '${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[i]['createdAt'])).day}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[i]['createdAt'])).month}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[i]['createdAt'])).year} ${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[i]['createdAt'])).hour}:${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[i]['createdAt'])).minute}'),
                                      ),
                                  ],
                                  rows: batchStudent
                                      .map(
                                        (student) => DataRow(
                                          cells: [
                                            DataCell(
                                              profilepic(student.photo)
                                            ),
                                            DataCell(Text(student.name!)),
                                            for (int k = 0;
                                                k < attendance.length;
                                                k++)
                                              DataCell(
                                                onDoubleTap: () {
                                                  bool value = (attendance[k]
                                                          ['uids'] as Map)
                                                      .values
                                                      .toList()
                                                      .where(
                                                        (e) =>
                                                            e['uid'] ==
                                                            student.uid,
                                                      )
                                                      .first['status'];
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) =>
                                                              AlertDialog(
                                                                content: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Center(child: profilepic(student.photo)),
                                                                    Text(
                                                                        'Name: ${student.name}',),
                                                                    Text(
                                                                        'Date Time: ${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[k]['createdAt'])).day}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[k]['createdAt'])).month}/${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[k]['createdAt'])).year} ${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[k]['createdAt'])).hour}:${DateTime.fromMicrosecondsSinceEpoch(int.parse(attendance[k]['createdAt'])).minute}'),
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                'From: ',
                                                                            style:
                                                                                TextStyle(color: Colors.black),
                                                                          ),
                                                                          TextSpan(
                                                                            text: value?
                                                                                'Present':'Absent',
                                                                            style:
                                                                                TextStyle(color: Colors.red[300]),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Text.rich(
                                                                      TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                'To: ',
                                                                            style:
                                                                                TextStyle(color: Colors.black),
                                                                          ),
                                                                          TextSpan(
                                                                            text: !value?
                                                                                'Present':'Absent',
                                                                            style:
                                                                                TextStyle(color: Colors.green[300]),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                actions: <
                                                                    Widget>[
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                    child:
                                                                        const Text(
                                                                            'No'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      BlocProvider.of<QrCubit>(context).updateAttendance(
                                                                          widget
                                                                              .session,
                                                                          widget
                                                                              .semester,
                                                                          widget
                                                                              .subjectCode,
                                                                          attendance[k]
                                                                              [
                                                                              'createdAt'],
                                                                          student
                                                                              .uid!,
                                                                          !value);
                                                                          Navigator.pop(context);
                                                                    },
                                                                    child: const Text(
                                                                        'Yes'),
                                                                  ),
                                                                ],
                                                              ));
                                                },
                                                (attendance[k]['uids'] as Map)
                                                            .values
                                                            .toList()
                                                            .where(
                                                              (e) =>
                                                                  e['uid'] ==
                                                                  student.uid,
                                                            )
                                                            .first['status']
                                                            .toString() ==
                                                        'true'
                                                    ? const Text('P')
                                                    : const Text('A'),
                                              ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  })
              : const Center(child: CircularProgressIndicator()),
        ));
  }
}
