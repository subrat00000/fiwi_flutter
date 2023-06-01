import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/timetable/timetable_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:fiwi/repositories/notification.dart';
import 'package:intl/intl.dart';

class TimetableCubit extends Cubit<TimetableState> {
  Box box = Hive.box('user');
  final DatabaseReference userRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference ref = FirebaseDatabase.instance.ref("timetable");
  final DatabaseReference cList = FirebaseDatabase.instance.ref("courseList");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TimetableCubit() : super(TimetableInitialState());
  final weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final now = DateTime.now();

  getCourseList() async {
    DataSnapshot a = await cList.get();
    return a.value;
  }

  getAdminAndFaculty() async {
    List<Map<dynamic, dynamic>> userList = [];
    List role = ['admin', 'faculty'];
    for (var element in role) {
      DataSnapshot snapshot =
          await userRef.orderByChild('role').equalTo(element).get();
      if (snapshot.value != null) {
        final map = snapshot.value as Map;
        map.forEach((key, value) {
          userList.add({'name':value['name'],'photo':value['photo']});
        });
      }
    }
    return userList;
  }

  void addPeroid(
    String day,
    DateTime startTime,
    DateTime endTime,
    String semester,
    String course,
    {String? teacherName}
  ) async {
    try {
      final weekDayName = weekdays[now.weekday - 1];
      var isAdminOrFaculty =
          await ref.child(day.toString()).child(course.toLowerCase()).get();
      if (!isAdminOrFaculty.exists ||
          (isAdminOrFaculty.exists &&
              (isAdminOrFaculty.value as Map)['adminOrFacultyId'] ==
                  _auth.currentUser!.uid)) {
        ref.child(day.toString()).child(course.toLowerCase()).set({
          'day': day,
          'startTime': startTime.toString(),
          'endTime': endTime.toString(),
          'semester': semester,
          'faculty': teacherName ?? box.get('name'),
          'subject': course.toUpperCase(),
          'lastUpdated': DateTime.now().toString(),
          'adminOrFacultyId': box.get('uid')
        });
        emit(TimetableAddPeriodSuccessState());
        sendNotification(
            semester.toLowerCase().replaceAll(' ', ''),
            box.get('name').toString(),
            "Your new class ${course.toUpperCase()} is scheduled from ${DateFormat.jm().format(startTime)} to ${DateFormat.jm().format(endTime)} on $weekDayName",
            "Timetable");
      } else {
        emit(TimetableErrorState("You can't overwrite a time table."));
      }
    } catch (e) {
      emit(TimetableErrorState(e.toString()));
    }
  }

  Future<void> deletePeriod(String day, String subject) async {
    try {
      final weekDayName = weekdays[now.weekday - 1];
      var isAdminOrFaculty =
          await ref.child(day.toString()).child(subject.toLowerCase()).get();
      var a = isAdminOrFaculty.value as Map;
      if (a['adminOrFacultyId'] == _auth.currentUser!.uid ||
          box.get('role') == 'admin') {
        log("hello");
        ref.child(day.toString()).child(subject.toLowerCase()).remove();
        emit(TimetableDeletePeriodSuccessState());
        sendNotification(
            a['semester'].toString().toLowerCase().replaceAll(' ', ''),
            box.get('name').toString(),
            "Your class ${a['subject'].toString()} is cancelled for $weekDayName.",
            "Timetable");
      } else {
        emit(TimetableErrorState("You have no access to delete it"));
      }
    } catch (e) {
      emit(TimetableErrorState(e.toString()));
    }
  }
}
