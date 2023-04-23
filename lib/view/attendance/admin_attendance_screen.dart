import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var internet = true;
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
                          padding: EdgeInsets.only(left:30),
                          child: Text('My Classes',style: TextStyle(fontSize: 18),),
                        ),
                        ListView.builder(
                            itemCount: myClasses.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10.0),
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  onTap: () {},
                                  title: Text(
                                      '${myClasses[index]['name']}(${myClasses[index]['code']})'),
                                  subtitle: Text(myClasses[index]['semester']),
                                  trailing: ElevatedButton(
                                    onPressed: () {},
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.white)),
                                    child: const Text(
                                      'Start',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 20,),
                        const Padding(
                          padding: EdgeInsets.only(left:30),
                          child: Text('Other Classes',style: TextStyle(fontSize: 18),),
                        ),
                        ListView.builder(
                            itemCount: otherClasses.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10.0),
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  onTap: () {},
                                  title: Text(
                                      '${otherClasses[index]['name']}(${otherClasses[index]['code']})'),
                                  subtitle: Text(otherClasses[index]['semester']),
                                  trailing: ElevatedButton(
                                    onPressed: () {},
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.white)),
                                    child: const Text(
                                      'Start',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
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
