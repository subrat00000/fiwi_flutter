import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_cubit.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/create_batch/create_batch_cubit.dart';
import 'package:fiwi/cubits/create_batch/create_batch_state.dart';
import 'package:fiwi/cubits/manage_role/manage_role_cubit.dart';
import 'package:fiwi/cubits/manage_role/manage_role_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShowBatchScreen extends StatefulWidget {
  const ShowBatchScreen({super.key});

  @override
  State<ShowBatchScreen> createState() => _ShowBatchScreenState();
}

class _ShowBatchScreenState extends State<ShowBatchScreen> {
  final _formKey = GlobalKey<FormState>();

  deleteBatch(session) {
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
                      text: '$session',
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
                    BlocProvider.of<CreateBatchCubit>(context)
                        .deleteBatch(session);
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/createbatch'),
          child: Icon(Icons.add_rounded),
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black87,
          ),
          title: Text(
            'All Batches',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: StreamBuilder(
              stream: FirebaseDatabase.instance.ref('batch').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final itemsMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final itemsList = itemsMap.values.toList();
                  return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10.0),
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            trailing: PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.black87,
                              ),
                              onSelected: (value) {
                                if (value == 0) {
                                  final value = itemsList[index]['uid'] as Map;
                                  List<String> valueList = value.keys
                                      .toList()
                                      .map((e) => e.toString())
                                      .toList();
                                  Navigator.pushNamed(context, '/createbatch',
                                      arguments: {
                                        'session': itemsList[index]['session'],
                                        'uids': valueList
                                      });
                                } else if (value == 1) {
                                  deleteBatch(itemsList[index]['session']);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem<int>(
                                    value: 0,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.edit_outlined),
                                        SizedBox(width: 5),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 1,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.delete_outline_rounded),
                                        SizedBox(width: 5),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                            title: Text('${itemsList[index]['session']}'),
                            onTap: () {
                              final value = itemsList[index]['uid'] as Map;
                              List<String> valueList = value.keys
                                  .toList()
                                  .map((e) => e.toString())
                                  .toList();
                              Navigator.pushNamed(context, '/viewbatch',
                                  arguments: {
                                    'session': itemsList[index]['session'],
                                    'uids': valueList
                                  });
                            },
                          ),
                        );
                      });
                }
              }),
        ));
  }
}
