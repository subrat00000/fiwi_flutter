import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_course/manage_course_cubit.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageCourseScreen extends StatefulWidget {
  const ManageCourseScreen({super.key});

  @override
  State<ManageCourseScreen> createState() => _ManageCourseScreenState();
}



class _ManageCourseScreenState extends State<ManageCourseScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  bool validation = false;
  List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];
  String? semesterValue;
  final _formKey = GlobalKey<FormState>();
  int? courseIndex;

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
                    BlocProvider.of<ManageCourseCubit>(context)
                        .deleteCourse(courses[index].code!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  _bottomModal() {
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            double width = MediaQuery.of(context).size.width;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Column(
                        children: [
                          Text("Create Course",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87)),
                          const SizedBox(height: 20),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty && validation) {
                                return 'Please enter a valid course name';
                              }
                              return null;
                            },
                            controller: nameController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Course Name',
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty && validation) {
                                return 'Please enter a valid course code';
                              }
                              return null;
                            },
                            controller: codeController,
                            inputFormatters: [
                              UpperCaseTextFormatter()
                            ],
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Course Code',
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          DropdownButtonFormField<String>(
                            validator: (value) {
                              if (value == null && validation) {
                                return 'Please Select a Semester';
                              }
                              return null;
                            },
                            hint: const Text("Semester"),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              hintStyle: const TextStyle(color: Colors.black12),
                            ),
                            items: items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: semesterValue,
                            onChanged: (String? value) {
                              setState(() {
                                semesterValue = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          CustomButton(
                              text: "Submit",
                              icontext: false,
                              onPressed: () {
                                validation = true;
                                log(courseIndex.toString());
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<ManageCourseCubit>(context)
                                      .addCourse({
                                    'name': nameController.text,
                                    'code': codeController.text,
                                    'semester': semesterValue,
                                    'index': courseIndex
                                  });
                                  Navigator.pop(context);
                                }
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _bottomModal();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder(
          stream: FirebaseDatabase.instance.ref('courseList').onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final itemsMap = snapshot.data!.snapshot.value as Map;
              final itemsList = itemsMap.entries.toList();
              List<Course> courses = itemsList
                  .map((data) => Course(
                      name: data.value['name'],
                      code: data.value['code'],
                      semester: data.value['semester']))
                  .toList();
              courses.sort();
              // return Text(courses.toString());
              return Container(
                  width: double.infinity,
                  color: Colors.white70,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: courses.length,
                      itemBuilder: ((context, index) {
                        return Card(
                          child: ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline_rounded),
                                color: Colors.red[300],
                                onPressed: () => _modalDelete(index, courses),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    '${courses[index].name!}(${courses[index].code!})',
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                courses[index].semester!,
                              )),
                        );
                      })));
            }
          }),
    );
  }
}
