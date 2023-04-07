import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/timetable/timetable_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class TimetableCubit extends Cubit<TimetableState> {
  Box box = Hive.box('user');
  final DatabaseReference ref = FirebaseDatabase.instance.ref("timetable");
  final DatabaseReference cList = FirebaseDatabase.instance.ref("courseList");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TimetableCubit() : super(TimetableInitialState());

  getCourseList() async {
    DataSnapshot a = await cList.get();
    return a.value;
  }

  void addPeroid(
    String day,
    DateTime startTime,
    DateTime endTime,
    String semester,
    String course,
  ) {
    try {
      ref
          .child(day.toString())
          .child(course.toLowerCase())
          .set({
        'day': day,
        'startTime': startTime.toString(),
        'endTime': endTime.toString(),
        'semester': semester,
        'faculty': box.get('name'),
        'subject': course.toUpperCase(),
        'lastUpdated': DateTime.now().toString(),
        'adminOrFacultyId': box.get('uid')
      });
      emit(TimetableAddPeriodSuccessState());
    } catch (e) {
      emit(TimetableErrorState(e.toString()));
    }
  }

  Future<void> deletePeriod(String day, String subject) async {
    
    try {
      var isAdminOrFaculty = await ref
          .child(day.toString())
          .child(subject.toLowerCase())
          .get();
      var a = isAdminOrFaculty.value as Map;
      if (a['adminOrFacultyId'] == _auth.currentUser!.uid ||
          box.get('role') == 'admin') {
            log("hello");
        ref
            .child(day.toString())
            .child(subject.toLowerCase())
            .remove();
            emit(TimetableDeletePeriodSuccessState());
      } else {
        emit(TimetableErrorState("You have no access to delete it"));
      }
    } catch (e) {
      emit(TimetableErrorState(e.toString()));
    }
  }
}
