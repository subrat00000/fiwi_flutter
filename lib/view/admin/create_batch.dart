import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_cubit.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/create_batch/create_batch_cubit.dart';
import 'package:fiwi/cubits/manage_role/manage_role_cubit.dart';
import 'package:fiwi/cubits/manage_role/manage_role_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];
  final myFocusNode = FocusNode();
  bool search = false;
  List<Student> filteredUser = [];
  List<Student> users = [];
  String? query;
  String? semesterValue;
  Stream? _stream;
  Timer? _timer;
  List<String> batchYears = [];
  String? sessionValue;
  String batchName = 'session';
  final batchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    batchYears = generateBatchYears();
    batchYears.sort();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {});

    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    // if (_timer != null) {
    //   _timer!.cancel();
    // }
  }

  _loadData() async {
    users = await BlocProvider.of<CreateBatchCubit>(context).getStudents();
    setState(() {
      filteredUser = users;
    });
  }

  List<String> generateBatchYears() {
    List<String> years = [];
    int currentYear = DateTime.now().year;
    for (int i = 0; i < 6; i++) {
      int startYear = currentYear + i - 4;
      int endYear = currentYear + i - 2;
      String batchYear =
          '${startYear.toString()}-${endYear.toString().substring(2)}';
      years.add(batchYear);
    }
    return years;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<String> value = users
              .where((e) => e.selected == true)
              .map((e) => e.uid!)
              .toList();
          log(value.toString());
          if (sessionValue != null ||
              value.isNotEmpty ||
              semesterValue != null) {
            BlocProvider.of<CreateBatchCubit>(context).createBatch(sessionValue!,semesterValue!,value);
          } else {
            ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: const Text("Please Fill all required fields"),
                            backgroundColor: Colors.redAccent[400],
                            behavior: SnackBarBehavior.floating,
                          ));
          }
        },
        child: Icon(Icons.save_rounded),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (search == true) {
              setState(() {
                search = false;
                query = '';
              });
              myFocusNode.unfocus();
              filteredUser = users;
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black87,
        ),
        actions: [
          if (search)
            IconButton(
              onPressed: () {
                setState(() {
                  search = false;
                  query = '';
                });
                myFocusNode.unfocus();
                filteredUser = users;
              },
              icon: const Icon(
                Icons.close_outlined,
                color: Colors.black87,
              ),
            ),
          if (!search)
            IconButton(
              onPressed: () {
                setState(() {
                  search = true;
                });
                myFocusNode.requestFocus();
              },
              icon: const Icon(Icons.search, color: Colors.black87),
            ),
          if (!search)
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.black87,
              ),
              onSelected: (value) {
                batchFocusNode.unfocus();
                if (value == 0) {
                  sessionValue = null;
                  setState(() {
                    batchName = 'session';
                  });
                } else if (value == 1) {
                  setState(() {
                    batchName = 'write';
                  });
                  batchFocusNode.requestFocus();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("Session"),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Write..."),
                  ),
                ];
              },
            ),
        ],
        title: search
            ? TextField(
                focusNode: myFocusNode,
                onChanged: (value) {
                  setState(() {
                    query = value;
                    filteredUser = users.where((user) {
                      final nameLower = user.name!.toLowerCase();
                      return nameLower.contains(value);
                    }).toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  batchName == 'session'
                      ? SizedBox(
                          width: 100,
                          child: DropdownButton<String>(
                            icon: Icon(Icons.edit_outlined),
                            hint: const Text("Session"),
                            elevation: 0,
                            underline: Container(),
                            style: TextStyle(color: Colors.black87),
                            // style: ,
                            // decoration: InputDecoration(
                            //   contentPadding: EdgeInsets.zero,
                            //   focusedBorder: OutlineInputBorder(
                            //     borderRadius: BorderRadius.circular(10),
                            //     borderSide:
                            //         const BorderSide(color: Colors.white70),
                            //   ),
                            //   enabledBorder: OutlineInputBorder(
                            //     borderRadius: BorderRadius.circular(10),
                            //     borderSide:
                            //         const BorderSide(color: Colors.white70),
                            //   ),
                            //   border: const OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.white70),
                            //     borderRadius: BorderRadius.all(
                            //       Radius.circular(10.0),
                            //     ),
                            //   ),
                            //   hintStyle: const TextStyle(color: Colors.black12),
                            // ),
                            items: batchYears
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: sessionValue,
                            onChanged: (String? value) {
                              setState(() {
                                sessionValue = value;
                              });
                            },
                          ),
                        )
                      : Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() {
                              sessionValue = value;
                            }),
                            focusNode: batchFocusNode,
                            decoration: const InputDecoration(
                              hintText: 'Batch Name',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    '${users.where((element) => element.selected == true).length}/${users.length}',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  )
                ],
              ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 4,
                ),
                itemBuilder: (context, index) {
                  return RadioListTile(
                    visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                        '${items[index]} (${users.where((element) => element.semester == items[index] && element.selected == true).length}/${users.where((element) => element.semester == items[index]).length})'),
                    value: items[index],
                    groupValue: semesterValue,
                    onChanged: (value) {
                      log(value.toString());
                      setState(() {
                        semesterValue = value;
                      });
                    },
                  );
                }),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: filteredUser.length,
                  itemBuilder: (context, index) {
                    // return ListTile(
                    //     title: Text(filteredUser[index]['name']));
                    return Card(
                      child: ListTile(
                        title: Text(
                            '${filteredUser[index].name}(${filteredUser[index].session})'),
                        trailing: Checkbox(
                          onChanged: (value) {
                            setState(() {
                              users
                                  .where((element) =>
                                      element.uid == filteredUser[index].uid)
                                  .first
                                  .selected = value;
                              filteredUser[index].selected = value;
                            });

                            log(filteredUser[index].selected.toString());
                          },
                          value: filteredUser[index].selected,
                        ),
                        subtitle: filteredUser[index].email != null
                            ? Text(filteredUser[index].email!)
                            : Text(filteredUser[index].phone!),
                        leading: Container(
                          width: 55,
                          height: 55,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: filteredUser[index].photo != null &&
                                  filteredUser[index].photo != ''
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: filteredUser[index].photo!,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Image.asset('assets/no_image.png'),
                        ),
                        onTap: () {
                          // Navigator.pushNamed(context, itemsMap[a]['route']);
                        },
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
