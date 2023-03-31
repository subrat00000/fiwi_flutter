import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class StreamBuilderWidget extends StatelessWidget {
  final String? day, dayInNum;

  const StreamBuilderWidget({super.key, this.dayInNum, this.day});

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
      color: Colors.grey[200],
      elevation: 0,
      child: Column(children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                day!,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
            )),
        Card(
          color: Colors.white,
          elevation: 0,
          child: Container(
              height: 150, // MediaQuery.of(context).size.height * 0.3,
              child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref('timetable/sem1')
                    .child(dayInNum!)
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
                    return ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        String showStartTime =
                            itemsList[index].value['startTime'].toString();
                        String showEndTime =
                            itemsList[index].value['endTime'].toString();
                        return InkWell(
                          onDoubleTap: () {
                            //  Firestore.instance.collection('Timetable').document(dId).delete();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(20.0)),
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
                                    // myText(
                                    //    Colors.white,
                                    //    DateFormat.jm().format(showStartTime),
                                    // ),
                                    // myText(
                                    //    Colors.white,
                                    //    DateFormat.jm().format(showEndTime),
                                    // ),
                                    myText(Colors.black, showStartTime),
                                    myText(Colors.black, showEndTime),
                                  ],
                                ),
                                myText(
                                  Colors.black,
                                  itemsList[index].value['subject'],
                                ),
                                myText(
                                  Colors.black,
                                  itemsList[index].value['faculty'],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: itemsList.length,
                      scrollDirection: Axis.horizontal,
                    );
                  }
                },
              )),
        ),
      ]),
    );
  }
}

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<StatefulWidget> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  var isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left:5, right:5),
        child: ListView(
          children: const <Widget>[
            StreamBuilderWidget(day: 'Monday', dayInNum: '1'),
            StreamBuilderWidget(day: 'Tuesday', dayInNum: '2'),
            StreamBuilderWidget(day: 'WednesDay', dayInNum: '3'),
            StreamBuilderWidget(day: 'Thursday', dayInNum: '4'),
            StreamBuilderWidget(day: 'Friday', dayInNum: '5'),
            StreamBuilderWidget(day: 'Satarday', dayInNum: '6'),
          ],
        ),
      );
    
  }
}
