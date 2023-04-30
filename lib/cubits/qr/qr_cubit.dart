import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_state.dart';
import 'package:fiwi/cubits/delete_account/delete_account_state.dart';
import 'package:fiwi/cubits/qr/qr_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class QrCubit extends Cubit<QrState> {
  Box box = Hive.box('user');
  final DatabaseReference bref = FirebaseDatabase.instance.ref("batch");
  final DatabaseReference attref = FirebaseDatabase.instance.ref("attendance");
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  QrCubit() : super(QrInitialState());

  initializeAttendance(String session, String semester, String subjectCode,
      String subjectName, String dt) async {
    try {
      emit(QrInitialState());
      DataSnapshot students = await bref.child(session).child('uid').get();
      final itemsMap = students.value as Map;
      final itemsValue = itemsMap.keys.toList();
      final oldSemesterValue = semester;
      semester = semester.toLowerCase().replaceAll(' ', '');
      String plainText = jsonEncode({
        'session': session,
        'semester': semester,
        'subject': subjectCode,
        'dt': dt
      });
      final key = encrypt.Key.fromUtf8(box.get('key'));
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // final decrypted = encrypter.decrypt(encrypted, iv: iv);

      final value = await attref
          .child(session)
          .child(semester)
          .child(subjectCode.toLowerCase())
          .child(dt)
          .get();
      if (value.exists) {
        emit(AttendanceAlreadyInitialized(encrypted.base64));
      } else {
        DatabaseReference dtRef = attref
            .child(session)
            .child(semester)
            .child(subjectCode.toLowerCase())
            .child(dt);
        // DatabaseReference uidsRef = dtRef.child('uids');
        await dtRef.set({
          'createdAt': dt,
          'semester': oldSemesterValue,
          'session': session,
          'subject_code': subjectCode,
          'subject_name': subjectName,
          'encrypted_qr': encrypted.base64,
          'qractive': true,
          'adminOrFacultyUid': _auth.currentUser!.uid
        });
        TransactionResult result = await dtRef.runTransaction((post) {
          if (post == null) {
            return Transaction.abort();
          }
          Map<String, dynamic> data = Map<String, dynamic>.from(post as Map);
          log(itemsValue.toString());
          Map<String, dynamic> uidList = {};
          final map = {};
          for (int i = 0; i < itemsValue.length; i++) {
            
                uidList[itemsValue[i]] ={'uid': itemsValue[i], 'status': false};
          }
          data['uids'] = uidList;
          return Transaction.success(data);
        });
        if (result.committed) {
          emit(PreSetupForAttendanceSuccessState(encrypted.base64));
        } else {
          await dtRef.remove();
          emit(QrErrorState("Transaction failed. Please try again"));
        }
        log(result.committed.toString());
      }
    } catch (e) {
      emit(QrErrorState(e.toString()));
    }
  }

  getBatchDetails() async {
    DataSnapshot batch = await bref.get();
    final itemsMap = batch.value as Map;
    final itemsList = itemsMap.keys.map((e) => e.toString()).toList();
    return itemsList;
  }

  Future getStudents() async {
    DataSnapshot users =
        await ref.orderByChild('role').equalTo('student').get();
    final itemsMap = users.value as Map;
    final itemsList = itemsMap.values.toList();
    List<Student> value = itemsList
        .map((e) => Student(
            email: e['email'],
            name: e['name'],
            phone: e['phone'],
            photo: e['photo'],
            selected: false,
            uid: e['uid'],
            session: e['session'],
            semester: e['semester']))
        .toList();
    return value;
  }

  takeAttendance(String session, String semester, String subject,
      String datetime, String uid, bool value) {
    try {
      attref
          .child(session)
          .child(semester.toLowerCase().replaceAll(' ', ''))
          .child(subject.toLowerCase())
          .child(datetime)
          .child('uids')
          .child(uid)
          .update({'status': value});
      emit(TakeAttendanceSuccessState());
    } catch (e) {
      emit(TakeAttendanceErrorState(e.toString()));
    }
  }
}
