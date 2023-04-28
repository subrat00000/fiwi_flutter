
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({super.key});

  @override
  State<FacultyAttendanceScreen> createState() => _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      color: Colors.white70,
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(
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
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final itemsList = itemsMap.values.toList();
                  // return Text(itemsList.toString());
                  return ListView.builder(
                      itemCount: itemsList.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {},
                            title: Text(
                                '${itemsList[index]['name']}(${itemsList[index]['code']})'),
                            subtitle: Text(itemsList[index]['semester']),
                            trailing: ElevatedButton(
                              onPressed: () {},
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.white)),
                              child: const Text(
                                'Start',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                        );
                      });
                }
              }),
        )
      ]),
    );
  }
}
