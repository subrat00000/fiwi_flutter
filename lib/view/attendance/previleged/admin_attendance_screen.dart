import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/admin_qr/qr_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String dt = DateTime.now().microsecondsSinceEpoch.toString();
  List<String> batch = [];

  openDialog(myClasses) {
    log(myClasses.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          // title: Text('Choose Batch'),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.7,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
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
                                        'semester': myClasses['semester'],
                                        'subject_code': myClasses['code'],
                                        'subject_name': myClasses['name'],
                                        'datetime': dt
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

  @override
  void initState() {
    super.initState();
    getBatch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // width: double.infinity,
        color: Colors.white70,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref('courseList')
                    .orderByChild('uid')
                    .startAt('')
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
                    final itemsList = itemsMap.values.toList();
                    final myClasses = itemsList
                        .where(
                          (e) => e['uid'] == _auth.currentUser!.uid,
                        )
                        .toList();
                    final otherClasses = itemsList
                        .where(
                          (e) => e['uid'] != _auth.currentUser!.uid,
                        )
                        .toList();
                    // return Text(itemsList.toString());
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text(
                            'My Classes',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ListView.builder(
                            itemCount: myClasses.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10.0),
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/manageattendance',
                                      arguments: {
                                        'semester': myClasses[index]
                                            ['semester'],
                                        'subject_code': myClasses[index]
                                            ['code'],
                                        'subject_name': myClasses[index]
                                            ['name'],
                                      }),
                                  title: Text(
                                      '${myClasses[index]['name']}(${myClasses[index]['code']})'),
                                  subtitle: Text(myClasses[index]['semester']),
                                  trailing: ElevatedButton(
                                      onPressed: () {
                                        openDialog(myClasses[index]);
                                      },
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.white)),
                                      child: const Icon(
                                        Icons.flight_class_rounded,
                                        color: Colors.black87,
                                      )),
                                ),
                              );
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text(
                            'Other Classes',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ListView.builder(
                            itemCount: otherClasses.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10.0),
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/manageattendance',
                                      arguments: {
                                        'semester': otherClasses[index]
                                            ['semester'],
                                        'subject_code': otherClasses[index]
                                            ['code'],
                                        'subject_name': otherClasses[index]
                                            ['name'],
                                      }),
                                  title: Text(
                                      '${otherClasses[index]['name']}(${otherClasses[index]['code']})'),
                                  subtitle:
                                      Text(otherClasses[index]['semester']),
                                  trailing: ElevatedButton(
                                      onPressed: () {
                                        openDialog(otherClasses[index]);
                                      },
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.white)),
                                      child: const Icon(
                                        Icons.flight_class_rounded,
                                        color: Colors.black87,
                                      )),
                                ),
                              );
                            }),
                      ],
                    );
                  }
                }),
          )
        ]),
      ),
    );
  }
}
