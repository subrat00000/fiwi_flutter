import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/admin_qr/qr_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
      bool serviceEnabled;
      LocationPermission permission;

      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        log(permission.name.toString());
        if (permission == LocationPermission.denied) {
          log('hello');
          emit(QrErrorState('Allow location permission to continue'));
        } else if (permission == LocationPermission.deniedForever) {
          emit(QrLocationPermissionErrorState());
        }
      } else if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          emit(QrLocationServiceErrorState(
              "Turn on Location Service to continue..."));
          log('not enabled');
        } else {
          Position pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.bestForNavigation);
          DataSnapshot students = await bref.child(session).child('uid').get();
          final itemsMap = students.value as Map;
          final itemsValue = itemsMap.keys.toList();
          final oldSemesterValue = semester;
          semester = semester.toLowerCase().replaceAll(' ', '');
          String plainText = jsonEncode({
            'session': session,
            'semester': oldSemesterValue,
            'subject': subjectCode,
            'dt': dt,
            'latitude': pos.latitude,
            'longitude': pos.longitude
          });
          final key = encrypt.Key.fromUtf8(box.get('key'));
          final iv = IV.fromLength(16);

          final encrypter = Encrypter(AES(key));

          final encrypted = encrypter.encrypt(plainText, iv: iv);
          // final decrypted = encrypter.decrypt(encrypted, iv: iv);
          DatabaseReference dtRef = attref
              .child(session)
              .child(semester)
              .child(subjectCode.toLowerCase())
              .child(dt);
          final value = await dtRef.get();
          if (value.exists) {
            emit(AttendanceAlreadyInitialized(encrypted.base64));
          } else {
            Map<String, dynamic> uidList = {};

            for (int i = 0; i < itemsValue.length; i++) {
              uidList[itemsValue[i]] = {'uid': itemsValue[i], 'status': false};
            }
            await dtRef
                .set({
                  'createdAt': dt,
                  'semester': oldSemesterValue,
                  'session': session,
                  'subject_code': subjectCode,
                  'subject_name': subjectName,
                  'encrypted_qr': encrypted.base64,
                  'qractive': true,
                  'adminOrFacultyUid': _auth.currentUser!.uid,
                  'uids': uidList,
                  'latitude': pos.latitude,
                  'longitude': pos.longitude
                })
                .then((value) =>
                    emit(PreSetupForAttendanceSuccessState(encrypted.base64)))
                .onError((error, stackTrace) =>
                    emit(QrErrorState(error.toString())));
          }
        }
      }
    } catch (e) {
      emit(QrErrorState(e.toString()));
    }
  }

  getBatchDetails() async {
    DataSnapshot batch = await bref.get();
    final itemsMap = batch.value as Map;
    final itemsList = itemsMap.keys.map((e) => e.toString()).toList();
    itemsList.sort((a, b) => b.compareTo(a));
    return itemsList;
  }

  Future getStudents() async {
    DatabaseEvent users =
        await ref.orderByChild('role').equalTo('student').once();
    final itemsMap = users.snapshot.value as Map;
    final itemsList = itemsMap.values.toList();
    return itemsList
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

  getBatchUids(sessionValue) async {
    DatabaseEvent data = await bref.child(sessionValue).child('uid').once();
    return (data.snapshot.value as Map).keys.map((e) => e.toString()).toList();
  }

  updateAttendance(String session, String semester, String subject,
      String datetime, String uid, bool value) async {
    try {
      await attref
          .child(session)
          .child(semester.toLowerCase().replaceAll(' ', ''))
          .child(subject.toLowerCase())
          .child(datetime)
          .child('uids')
          .child(uid)
          .update({'status': value});
      emit(UpdateAttendanceSuccessState());
    } catch (e) {
      emit(QrErrorState(e.toString()));
    }
  }

  deleteAttendance(String session,String semester,String subject,String datetime) async{
    try{
      await attref
          .child(session)
          .child(semester.toLowerCase().replaceAll(' ', ''))
          .child(subject.toLowerCase())
          .child(datetime).remove();
    }catch(e){
      emit(QrErrorState(e.toString()));
    }
  }
}
