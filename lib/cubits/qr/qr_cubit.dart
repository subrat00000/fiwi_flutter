import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_state.dart';
import 'package:fiwi/cubits/delete_account/delete_account_state.dart';
import 'package:fiwi/cubits/qr/qr_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class QrCubit extends Cubit<QrState> {
  final DatabaseReference bref = FirebaseDatabase.instance.ref("batch");
  final DatabaseReference attref = FirebaseDatabase.instance.ref("attendance");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  QrCubit() : super(QrInitialState());

  initializeAttendance(String session, String semester,String subject,String dt) async {
    try {
      
      DataSnapshot students = await bref.child(session).child('uid').get();
      final itemsMap = students.value as Map;
      final itemsValue = itemsMap.keys.toList();
      semester = semester.toLowerCase().replaceAll(' ', '');
      attref
          .child(session)
          .child(semester)
          .child(subject)
          .child(dt)
          .set({'createdAt': dt, 'semester': semester, 'session': session,'subject':subject,'qractive':true});
      for (int i = 0; i < itemsValue.length; i++) {
        attref.child(session).child(semester).child(subject).child(dt).child('uid').update({itemsValue[i]: ''});
      }
      emit(PreSetupForAttendanceSuccessState());
    } catch (e) {
      emit(QrErrorState(e.toString()));
    }
  }
}
