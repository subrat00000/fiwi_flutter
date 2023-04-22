import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_course/manage_course_cubit.dart';
import 'package:fiwi/models/course.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class AssignFacultyScreen extends StatefulWidget {
  const AssignFacultyScreen({super.key});

  @override
  State<AssignFacultyScreen> createState() => _AssignFacultyScreenState();
}

class _AssignFacultyScreenState extends State<AssignFacultyScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  _modalDelete(index, courses) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Do you want to delete ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '${courses[index].name!}(${courses[index].code!})',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                    TextSpan(
                      text: '?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    // BlocProvider.of<AssignFacultyCubit>(context)
                    //     .deleteCourse(courses[index].code!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
        ),
        title: const Text(
          'Manage Course',
          style: TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      body: StreamBuilder(
          stream: Rx.combineLatest2(
            FirebaseDatabase.instance
                .ref('users')
                .orderByChild('role')
                .equalTo('admin')
                .onValue,
            FirebaseDatabase.instance
                .ref('users')
                .orderByChild('role')
                .equalTo('faculty')
                .onValue,
            (DatabaseEvent maleData, DatabaseEvent femaleData) => <String, dynamic>{
              'male': maleData.snapshot.value,
              'female': femaleData.snapshot.value,
            },
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final itemsMap = snapshot.data!.values as Map;
              final itemsList = itemsMap.entries.toList();
              // List<Course> courses = itemsList
              //     .map((data) => Course(
              //         name: data.value['name'],
              //         code: data.value['code'],
              //         semester: data.value['semester']))
              //     .toList();
              // courses.sort();
              return Text(itemsList.toString());
              // return Container(
              //     width: double.infinity,
              //     color: Colors.white70,
              //     child: ListView.builder(
              //         shrinkWrap: true,
              //         itemCount: itemsList.length,
              //         itemBuilder: ((context, index) {
              //           return Card(
              //             child: ListTile(
              //                 // onTap: ()=> Navigator.push,
              //                 trailing: IconButton(
              //                   icon: Icon(Icons.delete_outline_rounded),
              //                   color: Colors.red[300],
              //                   onPressed: () => _modalDelete(index, courses),
              //                 ),
              //                 title: Row(
              //                   children: [
              //                     Text(
              //                       '${itemsList[index]}(${itemsList[index].value.code!})',
              //                     ),
              //                   ],
              //                 ),
              //                 subtitle: Text(
              //                   courses[index].semester!,
              //                 )),
              //           );
              //         })));
            }
          }),
    );
  }
}
