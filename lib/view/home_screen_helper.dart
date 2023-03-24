import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/repositories/exit.dart';
import 'package:fiwi/view/attendance_screen.dart';
import 'package:fiwi/view/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class HomeScreenHelper extends StatefulWidget {
  const HomeScreenHelper({super.key});

  @override
  State<HomeScreenHelper> createState() => HomeScreenHelperState();
}

class HomeScreenHelperState extends State<HomeScreenHelper> {
  int todayAsDay = 6;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        return Exit().showExitDialog(context);
      },
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, state) {
          return Column(
                children: [
                  Card(
                    color: Colors.grey[200],
                    elevation: 6,
                    child: Column(children: <Widget>[
                      InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (BuildContext context) =>
                          //             TimeTable()));
                        },
                        child: const Align(
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
                              color: Colors.cyanAccent,
                              elevation: 0,
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width *
                                        0.8,
                                height:
                                    150, //MediaQuery.of(context).size.height * 0.3,
                                child: const Center(
                                  child: Text('Sunday is fun day',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            )
                          : Card(
                              color: Colors.white70,
                              elevation: 6,
                              child: Column(children: <Widget>[
                                Container(
                                  height:
                                      150, //MediaQuery.of(context).size.height * 0.3,
                                  child: StreamBuilder(
                                    stream: FirebaseDatabase.instance
                                        .ref('timetable/sem1/sun')
                                        .onValue,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.data == null ||
                                          snapshot.data!.snapshot
                                                  .value ==
                                              null) {
                                        return const Center(
                                          child:
                                              CircularProgressIndicator(),
                                        );
                                      } else {
                                        final itemsMap = snapshot
                                                .data!.snapshot.value
                                            as Map<dynamic, dynamic>;
                                        final itemsList =
                                            itemsMap.entries.toList();
                                        return ListView.builder(
                                          padding: const EdgeInsets.all(
                                              10.0),
                                          itemBuilder:
                                              (context, index) {
                                            return showPeriod(context,
                                                itemsList[index]);
                                          },
                                          itemCount: itemsList.length,
                                          scrollDirection:
                                              Axis.horizontal,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ]),
                            ),
                    ]),
                  ),
                  
                ]);
              
        },
      ),
    );
  }

  Widget showPeriod(BuildContext context, document) {
    // DateTime showStartTime =
    //     DateTime.parse(document.value['startTime'].toDate().toString());
    // DateTime showEndTime =
    //     DateTime.parse(document.value['endTime'].toDate().toString());

    String showStartTime = document.value['startTime'].toString();
    String showEndTime = document.value['endTime'].toString();
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
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
              // myText(
              //    Colors.white,
              //   DateFormat.jm().format(showStartTime)
              // ),
              // myText(
              //    Colors.white,
              //   DateFormat.jm().format(showEndTime)
              // ),
              myText(Colors.black, showStartTime),
              myText(Colors.black, showEndTime),
            ],
          ),
          myText(
            Colors.black,
            document.value['subject'],
          ),
          myText(
            Colors.black,
            document.value['faculty'],
          ),
        ],
      ),
    );
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
