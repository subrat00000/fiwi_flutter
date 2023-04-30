import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/assign_faculty/assign_faculty_cubit.dart';
import 'package:fiwi/cubits/assign_faculty/assign_faculty_state.dart';
import 'package:fiwi/cubits/manage_course/manage_course_cubit.dart';
import 'package:fiwi/models/chartdata.dart';
import 'package:fiwi/models/course.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ManageAttendanceScreen extends StatefulWidget {
  final String semester;
  final String subjectCode;
  final String subjectName;
  final String datetime;
  const ManageAttendanceScreen(
      {super.key,
      required this.semester,
      required this.subjectCode,
      required this.subjectName,
      required this.datetime});

  @override
  State<ManageAttendanceScreen> createState() => _ManageAttendanceScreenState();
}

class _ManageAttendanceScreenState extends State<ManageAttendanceScreen> {
  List<ChartData>? data;
  List<String>? sessions;
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );
    super.initState();
    _loadData();
    _loadChart('2021-23');
  }

  _loadData() async {
    final ses = await FirebaseDatabase.instance.ref('attendance').get();
    final sessionMap = ses.value as Map;
    setState(() {
      sessions = sessionMap.keys.map((e) => e.toString()).toList();
      sessions!.sort((a, b) => b.compareTo(a));
    });
    log(sessions.toString());
  }

  _loadChart(sessionValue) async {
    final val = await FirebaseDatabase.instance
        .ref('attendance')
        .child(sessionValue)
        .child(widget.semester.toLowerCase().replaceAll(' ', ''))
        .child(widget.subjectCode.toLowerCase())
        .get();
    final itemsMap = val.value as Map;
    final itemsList = itemsMap.values.toList();
    itemsList.sort((a, b) =>
        a['createdAt'].toString().compareTo(b['createdAt'].toString()));
    setState(() {
      data = itemsList
          .map((e) => ChartData(
              DateFormat.Hm().format(DateTime.fromMicrosecondsSinceEpoch(
                  int.parse(e['createdAt']))),
              (e['uids'] as Map).values.toList().length,
              (e['uids'] as Map)
                  .values
                  .toList()
                  .where((e) => e['status'] == true)
                  .toList()
                  .length))
          .toList();
    });
    // final attendanceDate = itemsList.map((e)=> DateTime.fromMicrosecondsSinceEpoch(int.parse(e['createdAt'])).day).toList();
    // log(uids.toString());
  }

  _modalDelete(index, courses) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Do you want to delete ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '${courses[index].name!}(${courses[index].code!})',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                    TextSpan(
                      text: '?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    // BlocProvider.of<ManageAttendanceCubit>(context)
                    //     .deleteCourse(courses[index].code!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.black87,
            ),
            onSelected: (value) {
              if (value == 0) {
                // BlocProvider.of<AuthCubit>(context).logOut();
                // Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("History"),
                ),
              ];
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
        ),
        title: const Text(
          'Manage Attendance',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Center(
              child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white)),
                  child: const Text('Take Attendance',
                      style: TextStyle(color: Colors.black87)),
                  onPressed: () {}),
            ),
            data != null
                ? Container(
                    height: 200,
                    child: SfCartesianChart(
                        enableAxisAnimation: true,
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(interval: 1),
                        trackballBehavior: _trackballBehavior,
                        series: <LineSeries<ChartData, String>>[
                          LineSeries<ChartData, String>(
                            dataSource: data!,
                            markerSettings: MarkerSettings(isVisible: true),
                            name: 'Total No. of class',
                            xValueMapper: (ChartData value, _) => value.month,
                            yValueMapper: (ChartData value, _) =>
                                value.totalClass,
                          ),
                          LineSeries<ChartData, String>(
                            dataSource: data!,
                            markerSettings: MarkerSettings(isVisible: true),
                            name: 'Attended Class',
                            xValueMapper: (ChartData value, _) => value.month,
                            yValueMapper: (ChartData value, _) =>
                                value.attendedClass,
                          ),
                        ]),
                  )
                : Container(),
          ],
        )),
      ),
    );
  }
}
