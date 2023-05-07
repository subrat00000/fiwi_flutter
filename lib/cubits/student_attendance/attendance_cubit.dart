import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_role/manage_role_state.dart';
import 'package:fiwi/cubits/student_attendance/attendance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

class StudentAttendanceCubit extends Cubit<StudentAttendanceState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference attref = FirebaseDatabase.instance.ref('attendance');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Box box = Hive.box('user');

  StudentAttendanceCubit() : super(StudentAttendanceInitialState());

  submitAttendance(String qrValue) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(StudentAttendanceErrorState(
              "You need to turn on your location to give your attendance."));
        } else if (permission == LocationPermission.deniedForever) {
          emit(StudentLocationPermissionErrorState());
        }
      } else if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          emit(StudentLocationServiceErrorState());
        } else {
          Position pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.bestForNavigation);
          final key = encrypt.Key.fromUtf8(box.get('key'));
          final iv = IV.fromLength(16);

          final encrypter = Encrypter(AES(key));

          final decrypted = encrypter.decrypt64(qrValue, iv: iv);
          final value = jsonDecode(decrypted);
          double distance = Geolocator.distanceBetween(
              double.parse(value['latitude'].toString()),
              double.parse(value['longitude'].toString()),
              pos.latitude,
              pos.longitude);
          if (distance <= 50) {
            DatabaseEvent data = await attref
                .child(value['session'])
                .child(value['semester']
                    .toString()
                    .toLowerCase()
                    .replaceAll(' ', ''))
                .child(value['subject'].toString().toLowerCase())
                .child(value['dt'].toString())
                .once();
            if (data.snapshot.exists) {
              final mydata =
                  Map<String, dynamic>.from(data.snapshot.value as Map);
              if (mydata['encrypted_qr'] == qrValue) {
                await attref
                    .child(value['session'])
                    .child(value['semester']
                        .toString()
                        .toLowerCase()
                        .replaceAll(' ', ''))
                    .child(value['subject'].toString().toLowerCase())
                    .child(value['dt'].toString())
                    .child('uids')
                    .child(_auth.currentUser!.uid)
                    .update({'status': true});
                emit(StudentAttendanceSuccessState(
                    "Attendance is Successfully Taken"));
              } else {
                emit(StudentAttendanceErrorState(
                    "You have scanned a wrong QR code"));
              }
            } else {
              emit(StudentAttendanceErrorState(
                  "You have scanned a wrong QR code"));
            }
          } else {
            emit(StudentAttendanceErrorState('You are not in the Class room'));
          }
        }
      }
    } catch (e) {
      emit(StudentAttendanceErrorState(e.toString()));
    }
  }
}
