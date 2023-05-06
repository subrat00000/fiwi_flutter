import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_role/manage_role_state.dart';
import 'package:fiwi/cubits/student_attendance/attendance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:hive/hive.dart';

class StudentAttendanceCubit extends Cubit<StudentAttendanceState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference attref = FirebaseDatabase.instance.ref('attendance');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Box box = Hive.box('user');

  StudentAttendanceCubit() : super(StudentAttendanceInitialState());

  submitAttendance(String qrValue){
    try{
      final key = encrypt.Key.fromUtf8(box.get('key'));
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key));

      final decrypted = encrypter.decrypt64(qrValue, iv: iv);
      final value = jsonDecode(decrypted);
      log(value);
    }catch(e){
      emit(StudentAttendanceErrorState(e.toString()));
    }
  }

}
