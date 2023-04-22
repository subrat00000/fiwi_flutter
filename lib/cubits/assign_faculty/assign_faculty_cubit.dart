import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_state.dart';
import 'package:fiwi/cubits/assign_faculty/assign_faculty_state.dart';
import 'package:fiwi/cubits/delete_account/delete_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AssignFacultyCubit extends Cubit<AssignFacultyState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("courseList");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var box = Hive.box('user');
  String? val;
  AssignFacultyCubit() : super(AssignFacultyInitialState());

  getCourseValue(subject) async {
    DatabaseEvent a = await ref.child(subject.toString().toLowerCase()).once();
    var b = a.snapshot.value as Map;
    val = b['uid'];
    return val;
  }

  assignUserToSubject(subject, uid) {
    ref
        .child(subject.toString().toLowerCase())
        .update({'uid': uid})
        .then((value) => emit(AssignFacultySuccessState()))
        .onError((error, stackTrace) =>
            emit(AssignFacultyErrorState(error.toString())))
        .catchError((error) => emit(AssignFacultyErrorState(error.toString())));
  }

  removeUserToSubject(subject) {
    ref
        .child(subject.toString().toLowerCase())
        .update({'uid': null})
        .then((value) => emit(RemoveFacultySuccessState()))
        .onError((error, stackTrace) =>
            emit(AssignFacultyErrorState(error.toString())))
        .catchError((error) => emit(AssignFacultyErrorState(error.toString())));
  }
}
