import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/change_semester/change_semester_cubit.dart';
import 'package:fiwi/models/chartdata.dart';
import 'package:fiwi/models/timetable.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FacultyHomeScreen extends StatefulWidget {
  const FacultyHomeScreen({super.key});

  @override
  State<FacultyHomeScreen> createState() => FacultyHomeScreenState();
}



class FacultyHomeScreenState extends State<FacultyHomeScreen> {
  late TrackballBehavior _trackballBehavior;
  int todayAsDay = DateTime.now().weekday;
  Box box = Hive.box('user');
  bool loading = true;
  String chartValue = 'Day';
  List tableList = [];
  List<String> items = ['Semester', 'Month', 'Week', 'Day'];
  

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Column(children: [
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
                  child: Container(
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
                    Container(
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
                                    startTime:
                                        DateTime.parse(data.value['startTime']),
                                    endTime:
                                        DateTime.parse(data.value['endTime']),
                                    subject: data.value['subject'],
                                    faculty: data.value['faculty'],
                                    semester: data.value['semester']))
                                .toList();
                            timetable.sort((a, b) =>
                                a.startTime!.hour.compareTo(b.startTime!.hour) *
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
          margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
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
                child: Container(
                  width: width * 0.3,
                  height: height * 0.05,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Semester"),
                      items:
                          items.map<DropdownMenuItem<String>>((String value) {
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
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                height: height * 0.2,
                
              ),
            ],
          ))
    ]);
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
