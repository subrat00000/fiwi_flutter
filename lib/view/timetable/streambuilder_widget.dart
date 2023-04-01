import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class StreamBuilderWidget extends StatefulWidget {
  final String day, dayInNum;
  final bool isEdit;
  const StreamBuilderWidget(
      {super.key,
      required this.day,
      required this.dayInNum,
      this.isEdit = false});

  @override
  State<StatefulWidget> createState() => _StreamBuilderWidgetState();
}

class _StreamBuilderWidgetState extends State<StreamBuilderWidget> {
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  TimeOfDay? dateChecker;
  _bottomDialogBox() {
    dateChecker = null;
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                double width = MediaQuery.of(context).size.width;
            return Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                child: SingleChildScrollView(
                    child: Container(
                        margin: const EdgeInsets.all(20),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              dateChecker = picked;
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
                                              dateChecker = picked;
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
                                padding:
                                    EdgeInsets.only(left: width*0.12, right: width*0.12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${startTime.hour}:${startTime.minute}',
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${endTime.hour}:${endTime.minute}',
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),

                            ]))));
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
                  .ref('timetable/semester1')
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
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(20.0)),
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
        widget.isEdit
            ? IconButton(
                icon: const Icon(Icons.add),
                color: Colors.black87,
                onPressed: () {
                  _bottomDialogBox();
                },
              )
            : Container(),
        IconButton(
          icon: const Icon(Icons.add),
          color: Colors.black87,
          onPressed: () {
            _bottomDialogBox();
          },
        )
      ]),
    );
  }
}
