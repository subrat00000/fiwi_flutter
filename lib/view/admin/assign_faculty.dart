import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/assign_faculty/assign_faculty_cubit.dart';
import 'package:fiwi/cubits/assign_faculty/assign_faculty_state.dart';
import 'package:fiwi/cubits/manage_course/manage_course_cubit.dart';
import 'package:fiwi/models/course.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class AssignFacultyScreen extends StatefulWidget {
  final Object? args;
  const AssignFacultyScreen(this.args, {super.key});

  @override
  State<AssignFacultyScreen> createState() => _AssignFacultyScreenState();
}

class _AssignFacultyScreenState extends State<AssignFacultyScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  String? assignedUid;

  @override
  void initState() {
    super.initState();
    getAssignedUid();
  }

  getAssignedUid() async {
    String? val = await BlocProvider.of<AssignFacultyCubit>(context)
        .getCourseValue(widget.args!);
    setState(() {
      assignedUid = val;
    });
    log('pressed $assignedUid  $val');
  }

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
        title: Text(
          'Assign to ${widget.args}',
          style: TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      body: BlocListener<AssignFacultyCubit, AssignFacultyState>(
        listener: (context, state) {
          if (state is AssignFacultySuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("User Assigned Successfully"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is RemoveFacultySuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("User Removed Successfully"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is AssignFacultyErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error.toLowerCase()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        child: StreamBuilder(
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
              (DatabaseEvent admin, DatabaseEvent faculty) => <String, dynamic>{
                'admin': admin.snapshot.value,
                'faculty': faculty.snapshot.value,
              },
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final itemsMap = snapshot.data!.values.toList();
                final itemsList =
                    itemsMap.expand((data) => data.values).toList();

                log(assignedUid.toString());
                // return Text(itemsList.toString());
                return Container(
                    width: double.infinity,
                    color: Colors.white70,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemsList.length,
                        itemBuilder: ((context, index) {
                          return Card(
                            child: ListTile(
                                onTap: () => Navigator.push,
                                trailing: assignedUid !=
                                            itemsList[index]['uid'] ||
                                        assignedUid == null
                                    ? ElevatedButton(
                                        onPressed: () {
                                          BlocProvider.of<AssignFacultyCubit>(
                                                  context)
                                              .assignUserToSubject(widget.args!,
                                                  itemsList[index]['uid']);
                                          getAssignedUid();
                                        },
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.white)),
                                        child: const Text(
                                          'Assign',
                                          style:
                                              TextStyle(color: Colors.black87),
                                        ))
                                    : ElevatedButton(
                                        onPressed: () {
                                          BlocProvider.of<AssignFacultyCubit>(
                                                  context)
                                              .removeUserToSubject(
                                                  widget.args!);
                                          getAssignedUid();
                                        },
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.white)),
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        )),
                                title: Row(
                                  children: [
                                    Text(
                                      itemsList[index]['name'],
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  toCamelCase(itemsList[index]['role']),
                                )),
                          );
                        })));
              }
            }),
      ),
    );
  }
}
