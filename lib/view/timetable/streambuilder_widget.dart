import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiwi/cubits/timetable/selectable_grid_cubit.dart';
import 'package:fiwi/models/timetable.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/timetable/timetable_cubit.dart';
import 'package:fiwi/view/timetable/selectable_grid.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class StreamBuilderWidget extends StatefulWidget {
  final String day, dayInNum;
  final bool isEdit;
  final bool isAdmin;
  final bool isSimpleTimetable;
  const StreamBuilderWidget(
      {super.key,
      required this.day,
      required this.dayInNum,
      required this.isAdmin,
      required this.isEdit, required this.isSimpleTimetable});

  @override
  State<StatefulWidget> createState() => _StreamBuilderWidgetState();
}

class _StreamBuilderWidgetState extends State<StreamBuilderWidget> {
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];
  Box box = Hive.box('user');
  String? course;
  List courseList = [];
  String? semesterValue;
  int? courseIndex;
  String? courseValue;
  bool loading = true;
  List<Timetable> tableList = [];
  List<Map<dynamic, dynamic>>? adminAndFaculty;
  Map<dynamic, dynamic>? adminAndFacultyValue;

  _loadData() async {
    final a =
        await BlocProvider.of<TimetableCubit>(context).getAdminAndFaculty();
    log(a.toString());
    setState(() {
      courseList = box.get('courseList') ?? [];
      adminAndFaculty = a;
    });
  }

  @override
  void initState() {
    _loadData();

    super.initState();
  }

  DateTime _convertToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  _bottomDialogBoxAdmin() {
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            double width = MediaQuery.of(context).size.width;

            loadDataLocal() {
              setState(() {
                courseList = box.get('courseList') ?? [];
              });
            }

            return Container(
                // height: MediaQuery.of(context).size.height * 0.9,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                child: Container(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('Add Class',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: CustomButton(
                                      elevation: 1,
                                      borderRadius: 50,
                                      text: 'Start Time',
                                      icontext: false,
                                      onPressed: () async {
                                        final TimeOfDay? picked =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: startTime,
                                        );
                                        if (picked != null &&
                                            picked != startTime) {
                                          setState(() {
                                            startTime = picked;
                                          });
                                        }
                                      }),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: CustomButton(
                                      elevation: 1,
                                      borderRadius: 50,
                                      text: 'End Time',
                                      icontext: false,
                                      onPressed: () async {
                                        final TimeOfDay? picked =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: endTime,
                                        );
                                        if (picked != null &&
                                            picked != endTime) {
                                          setState(() {
                                            endTime = picked;
                                          });
                                        }
                                      }),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: width * 0.12, right: width * 0.12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat.jm()
                                        .format(_convertToDateTime(startTime)),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    DateFormat.jm()
                                        .format(_convertToDateTime(endTime)),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: SizedBox(
                                // width: 150,
                                height: 50,
                                child: DropdownButtonFormField<
                                    Map<dynamic, dynamic>>(
                                  itemHeight: 50,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "Faculty",
                                      style: TextStyle(color: Colors.purple),
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(0),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: const BorderSide(
                                          color: Colors.purple),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(50.0),
                                      ),
                                    ),
                                    hintStyle:
                                        const TextStyle(color: Colors.purple),
                                  ),
                                  items: adminAndFaculty!.map<
                                          DropdownMenuItem<
                                              Map<dynamic, dynamic>>>(
                                      (Map<dynamic, dynamic> value) {
                                    return DropdownMenuItem<
                                        Map<dynamic, dynamic>>(
                                      value: value,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: Row(
                                            children: [
                                              Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.all(4),
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  decoration:
                                                      const BoxDecoration(
                                                          boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                          shape:
                                                              BoxShape.circle),
                                                  child: Material(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: value['photo'] !=
                                                                null &&
                                                            value['photo'] != ''
                                                        ? CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl:
                                                                value['photo'],
                                                            progressIndicatorBuilder: (context,
                                                                    url,
                                                                    downloadProgress) =>
                                                                CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          )
                                                        : Image.asset(
                                                            'assets/no_image.png'),
                                                  )),
                                              SizedBox(width: 10),
                                              Text(value['name']),
                                            ],
                                          )),
                                    );
                                  }).toList(),
                                  value: adminAndFacultyValue,
                                  onChanged: (Map<dynamic, dynamic>? value) {
                                    setState(() {
                                      adminAndFacultyValue = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 50,
                                  child: DropdownButtonFormField<String>(
                                    itemHeight: 50,
                                    hint: const Padding(
                                      padding: EdgeInsets.only(left: 30),
                                      child: Text(
                                        "Semester",
                                        style: TextStyle(color: Colors.purple),
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide: const BorderSide(
                                            color: Colors.purple),
                                      ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                      ),
                                      hintStyle:
                                          const TextStyle(color: Colors.purple),
                                    ),
                                    items: items.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 30),
                                            child: Text(value)),
                                      );
                                    }).toList(),
                                    value: semesterValue,
                                    onChanged: (String? value) {
                                      setState(() {
                                        semesterValue = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  width: 150,
                                  child: CustomButton(
                                      text: "Select Course",
                                      borderRadius: 50,
                                      icontext: false,
                                      onPressed: () {
                                        var a = BlocProvider.of<TimetableCubit>(
                                                context)
                                            .getCourseList();
                                        a.then((val) {
                                          var output = val.values
                                              .map((e) =>
                                                  Map<String, String>.from(e))
                                              .toList();
                                          log(output.toString());
                                          showGeneralDialog(
                                            context: context,
                                            barrierLabel: "Barrier",
                                            barrierDismissible: true,
                                            barrierColor:
                                                Colors.black.withOpacity(0.5),
                                            transitionDuration:
                                                Duration(milliseconds: 500),
                                            pageBuilder: (_, __, ___) {
                                              return Center(
                                                child: Scaffold(
                                                  body: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20,
                                                            horizontal: 40),
                                                    child: Column(
                                                      children: [
                                                        Transform.translate(
                                                          offset: Offset(
                                                              -width * 0.4, 0),
                                                          child: IconButton(
                                                            color:
                                                                Colors.black54,
                                                            icon: Icon(Icons
                                                                .arrow_back_ios_new_rounded),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ),
                                                        Text(
                                                          semesterValue ??
                                                              "Semester 1",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors
                                                                  .black87),
                                                        ),
                                                        Expanded(
                                                          child: SelectableGrid(
                                                            item: output,
                                                            semester:
                                                                semesterValue ??
                                                                    "Semester 1",
                                                            itemCount:
                                                                output.length,
                                                            itemBuilder:
                                                                (context, index,
                                                                    selected) {
                                                              return Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            5),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        output[index]
                                                                            [
                                                                            'name'],
                                                                        style:
                                                                            TextStyle(
                                                                          color: selected
                                                                              ? Colors.white
                                                                              : Colors.purple,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    selected
                                                                        ? SizedBox(
                                                                            width:
                                                                                25,
                                                                            height:
                                                                                25,
                                                                            child:
                                                                                Image.asset('assets/checked.png'),
                                                                          )
                                                                        : Container()
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        CustomButton(
                                                            text: 'Submit',
                                                            borderRadius: 50,
                                                            icontext: false,
                                                            onPressed: () {
                                                              loadDataLocal();
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            transitionBuilder:
                                                (_, anim, __, child) {
                                              Tween<Offset> tween;
                                              if (anim.status ==
                                                  AnimationStatus.reverse) {
                                                tween = Tween(
                                                    begin: Offset(0, 1),
                                                    end: Offset.zero);
                                              } else {
                                                tween = Tween(
                                                    begin: Offset(0, -1),
                                                    end: Offset.zero);
                                              }

                                              return SlideTransition(
                                                position: tween.animate(anim),
                                                child: FadeTransition(
                                                  opacity: anim,
                                                  child: child,
                                                ),
                                              );
                                            },
                                          );
                                        });
                                      }),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            courseList.isNotEmpty
                                ? SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                        itemCount: courseList.length,
                                        itemBuilder: (context, index) {
                                          if (semesterValue ==
                                              courseList[index]['semester']) {
                                            return RadioListTile(
                                              tileColor: Colors.purple,
                                              title: Text(
                                                  courseList[index]['name']),
                                              value: courseList[index]['code'],
                                              groupValue: courseValue,
                                              onChanged: (value) {
                                                log(value);
                                                setState(() {
                                                  courseValue = value;
                                                });
                                              },
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }),
                                  )
                                : Container(),
                            CustomButton(
                                borderRadius: 50,
                                text: "Submit",
                                icontext: false,
                                onPressed: () {
                                  if (semesterValue != null &&
                                      courseValue != null && adminAndFacultyValue != null) {
                                    BlocProvider.of<TimetableCubit>(context)
                                        .addPeroid(
                                            widget.dayInNum,
                                            _convertToDateTime(startTime),
                                            _convertToDateTime(endTime),
                                            semesterValue!,
                                            courseValue!,
                                            teacherName: adminAndFacultyValue!['name']);
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Text(
                                          "Please fill all the field"),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              100,
                                          right: 20,
                                          left: 20),
                                    ));
                                  }
                                })
                          ]),
                    )));
          });
        });
  }

  _bottomDialogBox() {
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            double width = MediaQuery.of(context).size.width;

            return Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                child: Container(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('Add Class',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: CustomButton(
                                      elevation: 1,
                                      borderRadius: 50,
                                      text: 'Start Time',
                                      icontext: false,
                                      onPressed: () async {
                                        final TimeOfDay? picked =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: startTime,
                                        );
                                        if (picked != null &&
                                            picked != startTime) {
                                          setState(() {
                                            startTime = picked;
                                          });
                                        }
                                      }),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: CustomButton(
                                      elevation: 1,
                                      borderRadius: 50,
                                      text: 'End Time',
                                      icontext: false,
                                      onPressed: () async {
                                        final TimeOfDay? picked =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: endTime,
                                        );
                                        if (picked != null &&
                                            picked != endTime) {
                                          setState(() {
                                            endTime = picked;
                                          });
                                        }
                                      }),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: width * 0.12, right: width * 0.12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat.jm()
                                        .format(_convertToDateTime(startTime)),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    DateFormat.jm()
                                        .format(_convertToDateTime(endTime)),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 200,
                              child: StreamBuilder(
                                  stream: FirebaseDatabase.instance
                                      .ref('courseList')
                                      .orderByChild('uid')
                                      .equalTo(_auth.currentUser!.uid)
                                      .onValue,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data == null ||
                                        snapshot.data!.snapshot.value == null) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      final itemsMap =
                                          snapshot.data!.snapshot.value as Map;
                                      final itemsList =
                                          itemsMap.values.toList();
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: itemsList.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              child: RadioListTile(
                                                title: Text(
                                                    '${itemsList[index]['name']}(${itemsList[index]['code']})'),
                                                value: index,
                                                groupValue: courseIndex,
                                                onChanged: (value) {
                                                  log(value.toString());
                                                  setState(() {
                                                    courseIndex = value;
                                                    courseValue =
                                                        itemsList[index]
                                                            ['code'];
                                                    semesterValue =
                                                        itemsList[index]
                                                            ['semester'];
                                                  });
                                                },
                                              ),
                                            );
                                          });
                                    }
                                  }),
                            ),
                            CustomButton(
                                borderRadius: 50,
                                text: "Submit",
                                icontext: false,
                                onPressed: () {
                                  if (courseIndex != null) {
                                    BlocProvider.of<TimetableCubit>(context)
                                        .addPeroid(
                                            widget.dayInNum,
                                            _convertToDateTime(startTime),
                                            _convertToDateTime(endTime),
                                            semesterValue!,
                                            courseValue!);
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Text(
                                          "Please fill all the field"),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              120,
                                          right: 20,
                                          left: 20),
                                    ));
                                  }
                                })
                          ]),
                    )));
          });
        });
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Column(children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget.day,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            )),
        Container(
            height: 150, // MediaQuery.of(context).size.height * 0.3,
            child: StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref('timetable')
                  .child(widget.dayInNum)
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final itemsMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final itemsList = itemsMap.entries.toList();
                  List<Timetable> timetable = itemsList
                      .map((data) => Timetable(
                          startTime: DateTime.parse(data.value['startTime']),
                          endTime: DateTime.parse(data.value['endTime']),
                          subject: data.value['subject'],
                          faculty: data.value['faculty'],
                          semester: data.value['semester']))
                      .toList();
                  timetable.sort((a, b) =>
                      a.startTime!.hour.compareTo(b.startTime!.hour) * 60 +
                      a.startTime!.minute.compareTo(b.startTime!.minute));
                  if (box.get('role') == 'student') {
                    tableList = timetable.where((table) {
                      return box.get('semester') == table.semester!;
                    }).toList();
                  } else {
                    tableList = timetable;
                  }

                  return SizedBox(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        DateTime showStartTime = tableList[index].startTime!;
                        DateTime showEndTime = tableList[index].endTime!;

                        loading = false;
                        return InkWell(
                          onDoubleTap: () {
                            if (box.get('role') != 'student') {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text(
                                            'Do you want to delete class?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              BlocProvider.of<TimetableCubit>(
                                                      context)
                                                  .deletePeriod(
                                                      widget.dayInNum,
                                                      tableList[index]
                                                          .subject!);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            padding: EdgeInsets.only(
                                left: 5, top: 5, bottom: 5, right: 5),
                            width: 220,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10.0, 5.0, 0.0,
                                5.0), //MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    myText(
                                      Colors.black,
                                      DateFormat.jm().format(showStartTime),
                                    ),
                                    myText(
                                      Colors.black,
                                      DateFormat.jm().format(showEndTime),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    myText(
                                      Colors.black,
                                      tableList[index].subject!,
                                    ),
                                    myText(
                                      Colors.black,
                                      tableList[index].semester!,
                                    ),
                                  ],
                                ),
                                myText(
                                  Colors.black,
                                  tableList[index].faculty!,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: tableList.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  );
                }
              },
            )),
        widget.isEdit && adminAndFaculty != null
            ? IconButton(
                icon: const Icon(Icons.add),
                color: Colors.black87,
                onPressed: () {
                  if (widget.isAdmin && !widget.isSimpleTimetable) {
                    _bottomDialogBoxAdmin();
                  } else {
                    _bottomDialogBox();
                  }
                },
              )
            : Container(),
      ]),
    );
  }
}
