import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_cubit.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/manage_role/manage_role_cubit.dart';
import 'package:fiwi/cubits/manage_role/manage_role_state.dart';
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
  List filteredUser = [];
  List users = [];
  String? query;
  String? semesterValue;
  Stream? _stream;
  List<bool> selectedItems = [];
  List<bool> filteredSelectedItems = [];
  Timer? _timer;
  List<String> batchYears = [];
  String? sessionValue;

  @override
  void initState() {
    super.initState();
    batchYears = generateBatchYears();
    batchYears.sort();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadSelection();
    });

    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  _loadSelection() {
    if (selectedItems.isNotEmpty && filteredSelectedItems.isNotEmpty) {
      _timer!.cancel();
      log('canceled');
    } else if (users.isNotEmpty && filteredUser.isNotEmpty) {
      setState(() {
        selectedItems = List.filled(users.length, false);
        filteredSelectedItems = List.filled(filteredUser.length, false);
      });
    }
  }

  _loadData() {
    if (semesterValue == null) {
      setState(() {
        _stream = FirebaseDatabase.instance
            .ref('users')
            .orderByChild('role')
            .equalTo('student')
            .limitToFirst(1000)
            .onValue;
      });
    } else {
      setState(() {
        _stream = FirebaseDatabase.instance
            .ref('users')
            .orderByChild('semester')
            .equalTo(semesterValue)
            .onValue;
      });
    }
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
        onPressed: () {},
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
        ],
        title: search
            ? TextField(
                focusNode: myFocusNode,
                onChanged: (value) {
                  setState(() {
                    query = value;
                    filteredUser = users.where((user) {
                      final nameLower = user['name'].toLowerCase();
                      return nameLower.contains(value);
                    }).toList();
                    filteredSelectedItems =
                        List.filled(filteredUser.length, false);
                  });
                  for (int i = 0; i < filteredUser.length; i++) {
                    setState(() {
                      filteredSelectedItems[i] = filteredUser[i]['selected'];
                    });
                  }
                  log(filteredUser.toString());
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              )
            : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      icon: Icon(Icons.mode_edit_outline_rounded),
                      hint: const Text("Session"),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        hintStyle: const TextStyle(color: Colors.black12),
                      ),
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
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    'Total: ${users.length}\n Selected: ${selectedItems.where((element) => element == true).length}',
                    style: TextStyle(color: Colors.black87,fontSize: 14),
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
                    title: Text(items[index]),
                    value: items[index],
                    groupValue: semesterValue,
                    onChanged: (value) {
                      log(value.toString());
                      setState(() {
                        semesterValue = value;
                      });
                      _loadData();
                    },
                  );
                }),
            Expanded(
              child: StreamBuilder(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.data!.snapshot.value == null) {
                      return const Center(
                        child: Text('No Records Found!'),
                      );
                    } else {
                      final itemsMap = snapshot.data!.snapshot.value as Map;
                      // return Text(itemsMap.toString());
                      final itemsList = itemsMap.values.toList();
                      users = itemsList
                          .map((e) => {...e, 'selected': false})
                          .toList();

                      if (query == null) {
                        filteredUser = users;
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10.0),
                          itemCount: filteredUser.length,
                          itemBuilder: (context, index) {
                            // return ListTile(
                            //     title: Text(filteredUser[index]['name']));
                            return Card(
                              child: ListTile(
                                title: Text(filteredUser[index]['name']),
                                trailing: Checkbox(
                                  onChanged: (value) {
                                    for (int i = 0; i < users.length; i++) {
                                      if (users[i]['uid'] ==
                                          filteredUser[index]['uid']) {
                                        setState(() {
                                          selectedItems[i] = value!;
                                          users[i]['selected'] = value;
                                          filteredSelectedItems[index] = value;
                                          filteredUser[index]['selected'] =
                                              value;
                                        });
                                      }
                                    }
                                    log(filteredUser[index]['selected']
                                        .toString());
                                  },
                                  value: filteredSelectedItems.isNotEmpty
                                      ? filteredSelectedItems[index]
                                      : false,
                                ),
                                subtitle: filteredUser[index]['email'] != null
                                    ? Text(filteredUser[index]['email'])
                                    : Text(filteredUser[index]['phone']),
                                leading: Container(
                                  width: 55,
                                  height: 55,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: filteredUser[index]['photo'] != null &&
                                          filteredUser[index]['photo'] != ''
                                      ? CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: filteredUser[index]
                                              ['photo'],
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
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
                          });
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
