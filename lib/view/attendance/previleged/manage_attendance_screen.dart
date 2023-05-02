import 'dart:async';
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
  const ManageAttendanceScreen({
    super.key,
    required this.semester,
    required this.subjectCode,
    required this.subjectName,
  });

  @override
  State<ManageAttendanceScreen> createState() => _ManageAttendanceScreenState();
}

class _ManageAttendanceScreenState extends State<ManageAttendanceScreen> {
  List<ChartData> chartData = [];
  List<ChartData> chartData2 = [];
  List<String>? sessions;
  late TrackballBehavior _trackballBehavior;
  int? totalStudent;
  bool _isLoading = true;
  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );
    super.initState();
    Timer(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
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
    DateTime a = DateTime.now();
    final val = await FirebaseDatabase.instance
        .ref('attendance')
        .child(sessionValue)
        .child(widget.semester.toLowerCase().replaceAll(' ', ''))
        .child(widget.subjectCode.toLowerCase())
        .get();
    if (val.exists) {
      final itemsMap = Map<String, dynamic>.from(val.value as Map).values;
      final total = itemsMap.length;
      final presentList = <Set<String>>{};
      for (var e in itemsMap) {
        for (var v in (e['uids'] as Map).values) {
          if (v['status'] == true) presentList.add({v['uid']});
        }
      }
      final present = List.generate(total, (i) {
        final count = (itemsMap.elementAt(i)['uids'] as Map)
            .values
            .where((element) => element['status'] == true)
            .length;
        return count;
      });
      final absent = List.generate(total, (i) {
        final count = (itemsMap.elementAt(i)['uids'] as Map)
            .values
            .where((element) => element['status'] == false)
            .length;
        return count;
      });
      double averagePresent = present.reduce((a, b) => a + b) / total;
      double averageAbsent = absent.reduce((a, b) => a + b) / total;
      final batch = await FirebaseDatabase.instance
          .ref('batch')
          .child(sessionValue)
          .child('uid')
          .get();
      final uids = (batch.value as Map).keys.toList();
      final countMap = <String, int>{};
      for (var element in presentList) {
        for (var map in element) {
          if (uids.contains(map)) {
            if (countMap.containsKey(map)) {
              countMap[map] = countMap[map]! + 1;
            } else {
              countMap[map] = 1;
            }
          }
        }
      }
      final outputMap = <int, Set<String>>{};
      countMap.forEach((key, value) {
        if (!outputMap.containsKey(value)) {
          outputMap[value] = {};
        }
        outputMap[value]!.add(key);
      });
      final finalOutput = outputMap.entries.map((entry) {
        return {'day': entry.key, 'student': entry.value.length};
      }).toList();
      log(finalOutput.toString());
      setState(() {
        totalStudent = uids.length;
        chartData = [
          ChartData('Present', averagePresent.round(), Colors.greenAccent),
          ChartData('Absent', averageAbsent.round(), Colors.red[200]!)
        ];
        chartData2 = [];
      });
    }
    log((DateTime.now().difference(a).inMilliseconds).toString());
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
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white)),
                  child: const Text('Take Attendance',
                      style: TextStyle(color: Colors.black87)),
                  onPressed: () {}),
            ),
            chartData.isNotEmpty
                ? Card(
                    // height: 200,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                          child: Text(
                        'Total Students: $totalStudent',
                        style: TextStyle(fontSize: 17),
                      )),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: const Text(
                            'Average Attendance',
                            style: TextStyle(fontSize: 17),
                          )),
                      SfCircularChart(
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <CircularSeries>[
                            // Renders doughnut chart
                            DoughnutSeries<ChartData, String>(
                                enableTooltip: true,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                ),
                                dataLabelMapper: (datum, index) =>
                                    '${datum.count}(${datum.x.split('')[0]})',
                                dataSource: chartData,
                                pointColorMapper: (ChartData data, _) =>
                                    data.color,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.count)
                          ]),
                    ],
                  ))
                : Container(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [ _isLoading?CircularProgressIndicator(): Text('No Data Exist!!!')],
                    ),
                  ),
          ],
        )),
      ),
    );
  }
}
