import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/timetable/timetable_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class TimetableCubit extends Cubit<TimetableState> {
  Box box = Hive.box('user');
  final DatabaseReference ref = FirebaseDatabase.instance.ref("timetable");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TimetableCubit() : super(TimetableInitialState());

  void addPeroid(int day, DateTime startTime, DateTime endTime, String semester,
      String subject, String faculty) {
    try {
      ref
          .child(semester.replaceAll(RegExp(r'\s+'), '').toLowerCase())
          .child(day.toString())
          .child(subject)
          .set({
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
        'semester': semester,
        'faculty': faculty,
        'subject': subject.toUpperCase(),
        'lastUpdated': DateTime.now().toString(),
        'adminOrFacultyId': _auth.currentUser!.uid
      });
    } catch (e) {
      emit(TimetableErrorState(e.toString()));
    }
  }
  //admin or faculty who created the period can update or delete it
  Future<void> updatePeroid(int day, DateTime startTime, DateTime endTime,
      String semester, String subject, String faculty) async {
    try {
      var isAdminOrFaculty = await ref
          .child(semester.replaceAll(RegExp(r'\s+'), '').toLowerCase())
          .child(day.toString())
          .child(subject)
          .get();
      var a = isAdminOrFaculty.value as Map;
      if (a['adminOrFacultyId'] == _auth.currentUser!.uid ||
          box.get('role') == 'admin') {
        ref
            .child(semester.replaceAll(RegExp(r'\s+'), '').toLowerCase())
            .child(day.toString())
            .child(subject)
            .update({
          'day': day,
          'startTime': startTime,
          'endTime': endTime,
          'semester': semester,
          'faculty': faculty,
          'subject': subject.toUpperCase(),
          'lastUpdated': DateTime.now().toString()
        });
      } else {
        emit(TimetableErrorState("You have no access to edit"));
      }
    } catch (e) {
      emit(TimetableErrorState(e.toString()));
    }
  }

  Future<void> deletePeriod(int day, String semester, String subject) async {
    try {
      var isAdminOrFaculty = await ref
          .child(semester.replaceAll(RegExp(r'\s+'), '').toLowerCase())
          .child(day.toString())
          .child(subject)
          .get();
      var a = isAdminOrFaculty.value as Map;
      if (a['adminOrFacultyId'] == _auth.currentUser!.uid ||
          box.get('role') == 'admin') {
        ref
            .child(semester.replaceAll(RegExp(r'\s+'), '').toLowerCase())
            .child(day.toString())
            .child(subject)
            .remove();
      } else {
        emit(TimetableErrorState("You have no access to delete it"));
      }
    } catch (e) {
      emit(TimetableErrorState(e.toString()));
    }
  }
}
