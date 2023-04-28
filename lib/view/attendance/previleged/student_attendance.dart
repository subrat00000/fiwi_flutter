import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/create_batch/create_batch_cubit.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final String datetime;
  final String semester;
  final String session;
  final String subjectCode;
  final String subjectName;
  const StudentAttendanceScreen({super.key, required this.datetime, required this.semester, required this.session, required this.subjectCode, required this.subjectName});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Student>? student;

  selectedStudent() async {
    List<Student> ur =
        await BlocProvider.of<CreateBatchCubit>(context).getStudents();
    setState(() {
      student = ur;
    });
  }
  @override
  void initState(){
    super.initState();
  
    selectedStudent();
  }
  
  @override
  Widget build(BuildContext context) {
    log(widget.semester);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Attendance',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          color: Colors.black54,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        // width: double.infinity,
        color: Colors.white70,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
            child: student != null? StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref('attendance')
                    .child(widget.session)
                    .child(widget.semester.toLowerCase().replaceAll(' ', ''))
                    .child(widget.subjectCode.toLowerCase())
                    .child(widget.datetime)
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
                    final itemsListmap = itemsMap['uids'] as Map;
                    final value = itemsListmap.values.toList();
                    List<String> uids = value.map((e)=>e['uid'].toString()).toList();
                    List<Student> filteredStudent =  student!.where((e)=>uids.contains(e.uid)).toList()..add();
                    List<Student> filteredSelectedStudent = filteredStudent.map((e) => null)
                    // return Text(filteredStudent[0].name!);
                    return ListView.builder(
                        itemCount: filteredStudent.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10.0),
                        itemBuilder: (context, index) {
                          return Card(
                            child: CheckboxListTile(
                              title: Text(
                                  '${filteredStudent[index].name}'),
                              subtitle: filteredStudent[index].email != null
                                  ? Text(filteredStudent[index].email!)
                                  : Text(filteredStudent[index].phone!),
                              onChanged: (bool? value) {},
                              value: false,
                            ),
                          );
                        });
                  }
                }):Container(),
          )
        ]),
      ),
    );
  }
}
