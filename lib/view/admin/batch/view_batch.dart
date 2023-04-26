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

class ViewBatchScreen extends StatefulWidget {
  final String? session;
  final List<String>? uids;
  const ViewBatchScreen({
    super.key,
    required this.session,
    required this.uids,
  });

  @override
  State<ViewBatchScreen> createState() => _ViewBatchScreenState();
}

class _ViewBatchScreenState extends State<ViewBatchScreen> {
  List<Map<dynamic,dynamic>> student=[];
  getUsersData(List<String> uids) async {
    final futures =
        uids.map((e) => FirebaseDatabase.instance.ref('users').child(e).get());
    final results = await Future.wait(futures);
    setState(() {
      student = results.map((users) {
        final itemsMap = users.value as Map;
        return itemsMap;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();

    getUsersData(widget.uids!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black87,
          ),
          title: Text(
            'Session ${widget.session}',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: student.isNotEmpty? ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10.0),
              itemCount: student.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    student[index]['name'].toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                  // onTap: () {
                  //   // Navigator.pushNamed(context, itemsMap[a]['route']);
                  // },
                );
              }):Container(),
        ));
  }
}
