import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/admin_qr/qr_cubit.dart';
import 'package:fiwi/models/chartdata.dart';
import 'package:fiwi/models/timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  int todayAsDay = DateTime.now().weekday;
  Box box = Hive.box('user');
  bool loading = true;
  List tableList = [];
  List<String> batch = [];
  // bool _isLoading = true;
  String? chartValue;
  List chartData = [];

  @override
  void initState() {
    super.initState();
    getBatch();
  }

  getBatch() async {
    List<String> bt = await BlocProvider.of<QrCubit>(context).getBatchDetails();
    if (!mounted) {
      return;
    }
    setState(() {
      batch = bt;
    });
    chartValue = batch[0];
    log(batch.toString());
    _loadChart(chartValue);
  }

  _loadChart(sessionValue) async {
    final val = await FirebaseDatabase.instance
        .ref('attendance')
        .child(sessionValue)
        .once();
    final studentList = await FirebaseDatabase.instance
        .ref('batch')
        .child(sessionValue)
        .child('uid')
        .once();
    if (val.snapshot.exists && studentList.snapshot.exists) {
      final itemsMap = Map<String, dynamic>.from(val.snapshot.value as Map);
      final totalStudentList =
          (studentList.snapshot.value as Map).keys.toList().length;
      Map<String, Map<String, Map<String, dynamic>>> attendanceDetails = {};

      itemsMap.forEach((semester, subjects) {
        Map<String, Map<String, dynamic>> streamsData = {};

        subjects.forEach((key, value) {
          streamsData[key] ??= {
            'total_class': 0,
            'present': 0,
            'semester': '',
            'subject': ''
          };
          for (var element in (value as Map).values) {
            streamsData[key]!['total_class'] += 1;
            streamsData[key]!['semester'] = element['semester'];
            streamsData[key]!['subject'] = element['subject_name'];
            (element['uids'] as Map).forEach((uid, student) {
              if (student['status'] == true) {
                streamsData[key]!['present'] += 1;
              }
            });
          }
        });
        attendanceDetails[semester] = streamsData;
      });
      List myData = [];
      attendanceDetails.forEach((semester, subjects) {
        subjects.forEach((stream, data) {
          double presentPercent = (data['present'] /
                  (int.parse(data['total_class'].toString()) *
                      totalStudentList)) *
              100;
          myData.add({
            'subject_code': stream,
            'present': presentPercent,
            'semester': data['semester'],
            'subject_name': data['subject']
          });
        });
      });
      myData.sort((a, b) =>
          b['semester'].toString().compareTo(a['semester'].toString()));
      log(myData.toString());
      if (!mounted) {
        return;
      }
      setState(() {
        chartData = myData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(children: [
        Card(
          color: Colors.grey[200],
          elevation: 0,
          child: Column(children: <Widget>[
            const InkWell(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Text(
                        'Today\'s Time Table',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                    ),
                  )),
            ),
            (todayAsDay == 7)
                ? Card(
                    color: Colors.white,
                    elevation: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 150, //MediaQuery.of(context).size.height * 0.3,
                      child: const Center(
                        child: Text('Sunday is fun day',
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  )
                : Card(
                    color: Colors.white,
                    elevation: 0,
                    child: Column(children: <Widget>[
                      SizedBox(
                        height: 150, //MediaQuery.of(context).size.height * 0.3,
                        child: StreamBuilder(
                          stream: FirebaseDatabase.instance
                              .ref('timetable/$todayAsDay')
                              .onValue,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                snapshot.data!.snapshot.value == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              final itemsMap = snapshot.data!.snapshot.value
                                  as Map<dynamic, dynamic>;
                              final itemsList = itemsMap.entries.toList();
                              List<Timetable> timetable = itemsList
                                  .map((data) => Timetable(
                                      startTime: DateTime.parse(
                                          data.value['startTime']),
                                      endTime:
                                          DateTime.parse(data.value['endTime']),
                                      subject: data.value['subject'],
                                      faculty: data.value['faculty'],
                                      semester: data.value['semester']))
                                  .toList();
                              timetable.sort((a, b) =>
                                  a.startTime!.hour
                                          .compareTo(b.startTime!.hour) *
                                      60 +
                                  a.startTime!.minute
                                      .compareTo(b.startTime!.minute));
                              if (box.get('role') == 'student') {
                                tableList = timetable.where((table) {
                                  return box.get('semester') == table.semester!;
                                }).toList();
                              } else {
                                tableList = timetable;
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.all(10.0),
                                itemBuilder: (context, index) {
                                  return showPeriod(context, tableList[index]);
                                },
                                itemCount: tableList.length,
                                scrollDirection: Axis.horizontal,
                              );
                            }
                          },
                        ),
                      ),
                    ]),
                  ),
          ]),
        ),
        SizedBox(
          height: height * 0.02,
        ),
        Container(
            margin: const EdgeInsets.only(left: 15, right: 15),
            // height: height * 0.2,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 226, 226, 226),
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.02,
                ),
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text('Attendance Report'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: width * 0.3,
                    height: height * 0.05,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text("Semester"),
                        items:
                            batch.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: chartValue,
                        onChanged: (value) {
                          setState(() {
                            chartValue = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                chartData.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chartData.length,
                        itemBuilder: (context, index) {
                          // return Text(chartData[index].toString(),style: TextStyle(color:Colors.black87),);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  child: Text(
                                      '${chartData[index]['subject_name']}(${chartData[index]['subject_code']})(${chartData[index]['semester']})'),
                                ),
                              ),
                              SfCircularChart(
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  series: <CircularSeries>[
                                    // Renders doughnut chart
                                    DoughnutSeries<ChartData, String>(
                                        onPointTap: (a) {
                                          log(a.dataPoints![a.pointIndex!].x
                                              .toString());
                                        },
                                        enableTooltip: true,
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                          isVisible: true,
                                          labelPosition:
                                              ChartDataLabelPosition.outside,
                                        ),
                                        dataLabelMapper: (datum, index) =>
                                            '${datum.count}%(${datum.x.split('')[0]})',
                                        dataSource: [
                                          ChartData(
                                              'Present',
                                              double.parse(chartData[index]
                                                          ['present']
                                                      .toString())
                                                  .round(),
                                              const Color.fromARGB(
                                                  0, 34, 255, 163)),
                                          ChartData(
                                              'Absent',
                                              (100 -
                                                      double.parse(
                                                          chartData[index]
                                                                  ['present']
                                                              .toString()))
                                                  .floor(),
                                              const Color.fromARGB(
                                                  0, 252, 87, 109))
                                        ],
                                        pointColorMapper: (ChartData data, _) =>
                                            data.color,
                                        xValueMapper: (ChartData data, _) =>
                                            data.x,
                                        yValueMapper: (ChartData data, _) =>
                                            data.count)
                                  ]),
                            ],
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                SizedBox(
                  height: height * 0.02,
                ),
                Container(
                  height: height * 0.2,
                ),
              ],
            ))
      ]),
    );
  }

  Widget showPeriod(BuildContext context, document) {
    DateTime showStartTime = document.startTime;
    DateTime showEndTime = document.endTime;
    if (box.get('role') != 'student' ||
        box.get('semester') == document.semester) {
      loading = false;
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 5),
        width: 220,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.fromLTRB(
            10.0, 5.0, 0.0, 5.0), //MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                myText(Colors.black, DateFormat.jm().format(showStartTime)),
                myText(Colors.black, DateFormat.jm().format(showEndTime)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                myText(
                  Colors.black,
                  document.subject,
                ),
                myText(
                  Colors.black,
                  document.semester,
                ),
              ],
            ),
            myText(
              Colors.black,
              document.faculty,
            ),
          ],
        ),
      );
    } else {
      return loading
          ? Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.42),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container();
    }
  }

  Widget myText(tColor, textValue) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        textValue,
        style: TextStyle(color: tColor),
      ),
    );
  }
}
