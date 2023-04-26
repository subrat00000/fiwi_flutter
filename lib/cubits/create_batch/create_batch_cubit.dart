import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/create_batch/create_batch_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateBatchCubit extends Cubit<CreateBatchState> {
  CreateBatchCubit() : super(CreateBatchInitialState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference bref = FirebaseDatabase.instance.ref('batch');

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

  Future createBatch(
      String sessionValue, String semesterValue, List<String> value) async {
    try {
      DataSnapshot batch = await bref.child(sessionValue).get();
      if (batch.exists) {
        bref.child(sessionValue).set({'session': sessionValue});
        for (int i = 0; i < value.length; i++) {
          bref.child(sessionValue).child('uid').update({value[i]: ''});
        }
        emit(CreateBatchSuccessState());
      } else {
        emit(CreateBatchErrorState('A batch with same value already exist'));
      }
    } catch (e) {
      emit(CreateBatchErrorState(e.toString()));
    }
  }
}
