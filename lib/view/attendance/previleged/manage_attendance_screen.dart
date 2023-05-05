import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/assign_faculty/assign_faculty_cubit.dart';
import 'package:fiwi/cubits/assign_faculty/assign_faculty_state.dart';
import 'package:fiwi/cubits/manage_course/manage_course_cubit.dart';
import 'package:fiwi/cubits/qr/qr_cubit.dart';
import 'package:fiwi/models/chartdata.dart';
import 'package:fiwi/models/course.dart';
import 'package:fiwi/models/student.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  Map<String, Set<String>> attendStudentUid = {};
  Map<String, dynamic> studentWithPercent = {};
  String dt = DateTime.now().microsecondsSinceEpoch.toString();
  List<String> sessions = [];
  late TrackballBehavior _trackballBehavior;
  int? totalStudent;
  String? chartValue;
  bool _isLoading = true;
  int? totalClasses;
  List<String> batch = [];
  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    _loadData();
    getBatch();
  }

  getBatchDialog(semester, subjectCode, subjectName, datetime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          // title: Text('Choose Batch'),
          child: Container(
            padding: EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.7,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Text(
                      'Choose Batch',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: batch.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(batch[index]),
                                onTap: () {
                                  Navigator.pushNamed(context, '/qrscreen',
                                      arguments: {
                                        'session': batch[index],
                                        'semester': semester,
                                        'subject_code': subjectCode,
                                        'subject_name': subjectName,
                                        'datetime': datetime
                                      });
                                },
                              ),
                            );
                          }),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  getBatch() async {
    List<String> bt = await BlocProvider.of<QrCubit>(context).getBatchDetails();
    if (!mounted) {
      return;
    }
    setState(() {
      batch = bt;
    });
  }

  _loadData() async {
    final ses = await FirebaseDatabase.instance.ref('attendance').get();
    final sessionMap = ses.value as Map;
    if (!mounted) {
      return;
    }
    setState(() {
      sessions = sessionMap.keys.map((e) => e.toString()).toList();
      sessions.sort((a, b) => b.compareTo(a));
    });
    log(sessions.toString());
    chartValue = sessions[0];
    _loadChart(sessions[0]);
  }

  _loadChart(sessionValue) async {
    DateTime a = DateTime.now();
    final val = await FirebaseDatabase.instance
        .ref('attendance')
        .child(sessionValue)
        .child(widget.semester.toLowerCase().replaceAll(' ', ''))
        .child(widget.subjectCode.toLowerCase())
        .once();
    if (val.snapshot.exists) {
      final itemsMap =
          Map<String, dynamic>.from(val.snapshot.value as Map).values;
      int total = itemsMap.length;

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
      //Second doughnut
      final presentList = {};
      for (var e in itemsMap) {
        for (var v in (e['uids'] as Map).values) {
          if (v['status'] == true) {
            if (presentList.containsKey(v['uid'])) {
              presentList[v['uid']] = presentList[v['uid']] + 1;
            } else {
              presentList[v['uid']] = 1;
            }
          }
        }
      }
      Map<int, Set<String>> finalList = {};
      presentList.forEach((a, b) {
        if (!finalList.containsKey(b)) {
          finalList[b] = {};
        }
        finalList[b]!.add(a);
      });

      Map<String, dynamic> lst = finalList.map((a, b) => MapEntry(
          double.parse(((a / total) * 100).toStringAsFixed(2)).toString(), b));
      Map<String, int> groupedAttendanceMap = {
        "0-20": 0,
        "20-40": 0,
        "40-60": 0,
        "60-80": 0,
        "80-100": 0
      };
      Map<String, Set<String>> uidz = {
        "0-20": {},
        "20-40": {},
        "40-60": {},
        "60-80": {},
        "80-100": {}
      };

      lst.forEach((percentage, students) {
        double p = double.parse(percentage);
        int s = (students as Set<String>).length;
        if (p >= 0 && p < 20) {
          groupedAttendanceMap["0-20"] = groupedAttendanceMap["0-20"]! + s;
          uidz["0-20"]!.addAll(students);
        } else if (p >= 20 && p < 40) {
          groupedAttendanceMap["20-40"] = groupedAttendanceMap["20-40"]! + s;
          uidz["20-40"]!.addAll(students);
        } else if (p >= 40 && p < 60) {
          groupedAttendanceMap["40-60"] = groupedAttendanceMap["40-60"]! + s;
          uidz["40-60"]!.addAll(students);
        } else if (p >= 60 && p < 80) {
          groupedAttendanceMap["60-80"] = groupedAttendanceMap["60-80"]! + s;
          uidz["60-80"]!.addAll(students);
        } else if (p >= 80 && p <= 100) {
          groupedAttendanceMap["80-100"] = groupedAttendanceMap["80-100"]! + s;
          uidz["80-100"]!.addAll(students);
        }
      });
      log(groupedAttendanceMap.toString());
      log(uidz.toString());
      final batch = await FirebaseDatabase.instance
          .ref('batch')
          .child(sessionValue)
          .child('uid')
          .once();
      final uids = (batch.snapshot.value as Map).keys.toList();
      if (!mounted) {
        return;
      }
      setState(() {
        totalClasses = total;
        totalStudent = uids.length;
        attendStudentUid = uidz;
        studentWithPercent = lst;
        chartData = [
          ChartData('Present', averagePresent.round(),
              const Color.fromARGB(0, 34, 255, 163)),
          ChartData('Absent', averageAbsent.floor(),
              const Color.fromARGB(0, 252, 87, 109))
        ];
        chartData2 = [
          ChartData("80-100", groupedAttendanceMap["80-100"]!,
              const Color.fromARGB(0, 34, 255, 163)),
          ChartData("60-80", groupedAttendanceMap["60-80"]!,
              const Color.fromARGB(0, 146, 255, 43)),
          ChartData("40-60", groupedAttendanceMap["40-60"]!,
              const Color.fromARGB(0, 243, 196, 65)),
          ChartData("20-40", groupedAttendanceMap["20-40"]!,
              const Color.fromARGB(0, 252, 161, 87)),
          ChartData("0-20", groupedAttendanceMap["0-20"]!,
              const Color.fromARGB(0, 252, 87, 109)),
        ];
      });
    }
    log((DateTime.now().difference(a).inMilliseconds).toString());
  }

  openDialog(List<Map<String, dynamic>> student) {
    log(student.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.7,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ListView.builder(
                    itemCount: student.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(student[index]['name']),
                          trailing: Text('${student[index]['percent']}%'),
                          leading: Container(
                            width: 45,
                            height: 45,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: student[index]['photo'] != null &&
                                    student[index]['photo'] != ''
                                ? CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: student[index]['photo'],
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  )
                                : Image.asset('assets/no_image.png'),
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
                const PopupMenuItem<int>(
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
        margin: const EdgeInsets.only(left: 16, right: 16),
        child: SingleChildScrollView(
            child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.white)),
                    child: const Text('Take Attendance',
                        style: TextStyle(color: Colors.black87)),
                    onPressed: () {
                      getBatchDialog(widget.semester, widget.subjectCode,
                          widget.subjectName, dt);
                    }),
                ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.white)),
                    child: const Text('Attendance Report',
                        style: TextStyle(color: Colors.black87)),
                    onPressed: () {
                      if(chartValue != null){
                        Navigator.pushNamed(context, '/attendancereport',
                          arguments: {
                            'session': chartValue,
                            'semester': widget.semester,
                            'subject_code': widget.subjectCode,
                            'subject_name': widget.subjectName,
                          });
                      }else {
                        
                      }
                      
                    }),
              ],
            ),
            chartData.isNotEmpty
                ? Card(
                    // height: 200,
                    child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Students: $totalStudent',
                              style: const TextStyle(fontSize: 17),
                            ),
                            Text(
                              'Total Classes: $totalClasses',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: width * 0.25,
                            height: height * 0.05,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Semester"),
                                items: sessions.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                value: chartValue,
                                onChanged: (value) {
                                  _loadChart(value);
                                  setState(() {
                                    chartValue = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Average Attendance',
                          style: TextStyle(fontSize: 17),
                        ),
                        SfCircularChart(
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CircularSeries>[
                              // Renders doughnut chart
                              DoughnutSeries<ChartData, String>(
                                  onPointTap: (a) {
                                    log(a.dataPoints![a.pointIndex!].x
                                        .toString());
                                  },
                                  enableTooltip: true,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
                                  ),
                                  dataLabelMapper: (datum, index) =>
                                      '${datum.count}(${datum.x.split('')[0]})',
                                  dataSource: chartData,
                                  pointColorMapper: (ChartData data, _) =>
                                      data.color,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) =>
                                      data.count)
                            ]),
                        const Text(
                          'Student - Attendance Percentage',
                          style: TextStyle(fontSize: 17),
                        ),
                        SfCircularChart(
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CircularSeries>[
                              // Renders doughnut chart
                              DoughnutSeries<ChartData, String>(
                                  onPointTap: (a) async {
                                    DateTime old = DateTime.now();
                                    List<Student> student =
                                        await BlocProvider.of<QrCubit>(context)
                                            .getStudents();
                                    List<Student> filteredStudent = student
                                        .where((stud) => attendStudentUid[
                                                a.dataPoints![a.pointIndex!].x]!
                                            .contains(stud.uid))
                                        .toList();
                                    log('${a.dataPoints![a.pointIndex!].x}   ${a.dataPoints![a.pointIndex!].y}');
                                    List<Map<String, dynamic>> studentList = [];
                                    for (Student e in filteredStudent) {
                                      for (var entry
                                          in studentWithPercent.entries) {
                                        if (entry.value.contains(e.uid)) {
                                          studentList.add({
                                            'name': e.name,
                                            'percent': entry.key,
                                            'photo': e.photo,
                                          });
                                          break;
                                        }
                                      }
                                    }
                                    log((DateTime.now()
                                            .difference(old)
                                            .inMilliseconds)
                                        .toString());
                                    openDialog(studentList);
                                  },
                                  enableTooltip: true,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
                                  ),
                                  dataLabelMapper: (datum, index) =>
                                      '${datum.count} - (${datum.x})%',
                                  dataSource: chartData2,
                                  pointColorMapper: (ChartData data, _) =>
                                      data.color,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) =>
                                      data.count)
                            ]),
                      ],
                    ),
                  ))
                : Container(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('No Data Exist!!!')
                      ],
                    ),
                  ),
          ],
        )),
      ),
    );
  }
}
