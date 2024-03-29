import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiwi/cubits/create_batch/create_batch_cubit.dart';
import 'package:fiwi/cubits/create_batch/create_batch_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateBatchScreen extends StatefulWidget {
  final String session;
  final List<String> uids;
  const CreateBatchScreen({super.key, this.session = '', this.uids = const []});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];
  final myFocusNode = FocusNode();
  bool search = false;
  List<Student> filteredUser = [];
  List<Student> users = [];
  String? query;
  String? semesterValue;
  List<String> batchYears = [];
  String? sessionValue;
  String batchName = 'session';
  final batchFocusNode = FocusNode();
  bool update = false;
  List<String> uidsvalue=[];

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
    List<Student> ur =
        await BlocProvider.of<CreateBatchCubit>(context).getStudents();

    if (widget.uids.isNotEmpty) {
      setState(() {
        update = true;
        sessionValue = widget.session;
        uidsvalue = widget.uids;
      });
    }
    for (int i = 0; i < ur.length; i++) {
      if (widget.uids.contains(ur[i].uid)) {
        setState(() {
          ur[i].selected = true;
        });
      }
    }
    setState(() {
      users = ur;
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, uidsvalue);
        return true;
      },
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              List<String> value = users
                  .where((e) => e.selected == true)
                  .map((e) => e.uid!)
                  .toList();
              setState(() {
                uidsvalue = value;
              });
              log(value.toString());
              if (sessionValue != null && value.isNotEmpty) {
                BlocProvider.of<CreateBatchCubit>(context)
                    .createBatch(sessionValue!, update, value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Please Fill all required fields"),
                  backgroundColor: Colors.redAccent[400],
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: const Icon(Icons.save_rounded),
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
                  Navigator.pop(context,uidsvalue);
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
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      batchName == 'session'
                          ? widget.session == ''
                              ? SizedBox(
                                  width: 100,
                                  child: DropdownButton<String>(
                                    icon: const Icon(Icons.edit_outlined),
                                    hint: const Text("Session"),
                                    elevation: 0,
                                    underline: Container(),
                                    style: const TextStyle(color: Colors.black87),
                                    items: batchYears
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    value:
                                        sessionValue == '' ? null : sessionValue,
                                    onChanged: (String? value) {
                                      setState(() {
                                        sessionValue = value;
                                      });
                                    },
                                  ),
                                )
                              : Text(
                                  widget.session,
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 16),
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
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      )
                    ],
                  ),
          ),
          body: BlocListener<CreateBatchCubit, CreateBatchState>(
            listener: (context, state) {
              if (state is CreateBatchSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Batch Created Successfully"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
                Navigator.pop(context,uidsvalue);
              } else if (state is UpdateBatchSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Batch Updated Successfully"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
                Navigator.pop(
                  context, uidsvalue
                );
              } else if (state is CreateBatchErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error.toString()),
                  backgroundColor: Colors.redAccent[400],
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                          return Card(
                            child: ListTile(
                              title: Text(
                                  '${filteredUser[index].name}(${filteredUser[index].semester})'),
                              trailing: Checkbox(
                                onChanged: (value) {
                                  setState(() {
                                    users
                                        .where((element) =>
                                            element.uid ==
                                            filteredUser[index].uid)
                                        .first
                                        .selected = value;
                                    filteredUser[index].selected = value;
                                  });
    
                                  log(filteredUser[index].selected.toString());
                                },
                                value: filteredUser[index].selected,
                              ),
                              subtitle: filteredUser[index].email != null
                                  ? Text('${filteredUser[index].email!}(${filteredUser[index].session})')
                                  : Text('${filteredUser[index].phone!}(${filteredUser[index].session})'),
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
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
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
          )),
    );
  }
}
