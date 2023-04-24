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
  final myFocusNode = FocusNode();
  bool search = false;
  List filteredUser = [];
  List users = [];
  String? query;
  int limit = 20;

  @override
  void initState() {
    super.initState();
    // _setData();
  }

  @override
  void dispose() {
    super.dispose();
  }
 

  _activate(user, value) {
    if (user['active'] == true) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Do you want to deactive ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: '${user['name']}',
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
                      BlocProvider.of<ActivateStudentCubit>(context)
                          .activateStudent(user['uid'], value);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ));
    } else {
      BlocProvider.of<ActivateStudentCubit>(context)
          .activateStudent(user['uid'], true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (search == true) {
              setState(() {
                search = false;
                query = '';
              });
              myFocusNode.unfocus();
              filteredUser=users;
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
                filteredUser=users;
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
                  });
                  log(filteredUser.toString());
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              )
            : const Text(
                'Create Batch',
                style: TextStyle(color: Colors.black87, fontSize: 20),
                textAlign: TextAlign.start,
              ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref('test')
                .limitToFirst(limit)
                .onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                users =
                    snapshot.data!.snapshot.value as List;
                    // return Text(itemsMap.toString());
                // users = itemsMap.values.toList();

                if (query == null) {
                  filteredUser = users;
                }
                return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: filteredUser.length,
                    itemBuilder: (context, index) {
                      return ListTile(title:Text(filteredUser[index]['name']));
                      // return Card(
                      //   child: ListTile(
                      //     title: Text(filteredUser[index]['name']),
                      //     trailing: Checkbox(
                      //       onChanged: (value) {
                      //         _activate(filteredUser[index], value);
                      //       },
                      //       value: filteredUser[index]['active'],
                      //     ),
                      //     subtitle: filteredUser[index]['email'] != null
                      //         ? Text(filteredUser[index]['email'])
                      //         : Text(filteredUser[index]['phone']),
                      //     leading: Container(
                      //       width: 55,
                      //       height: 55,
                      //       clipBehavior: Clip.antiAliasWithSaveLayer,
                      //       decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(50),
                      //       ),
                      //       child: filteredUser[index]['photo'] != null &&
                      //               filteredUser[index]['photo'] != ''
                      //           ? CachedNetworkImage(
                      //               fit: BoxFit.cover,
                      //               imageUrl: filteredUser[index]['photo'],
                      //               progressIndicatorBuilder: (context, url,
                      //                       downloadProgress) =>
                      //                   CircularProgressIndicator(
                      //                       value:
                      //                           downloadProgress.progress),
                      //               errorWidget: (context, url, error) =>
                      //                   const Icon(Icons.error),
                      //             )
                      //           : Image.asset('assets/no_image.png'),
                      //     ),
                      //     onTap: () {
                      //       // Navigator.pushNamed(context, itemsMap[a]['route']);
                      //     },
                      //   ),
                      // );
                    });
              }
            }),
      ),
    );
  }
}
