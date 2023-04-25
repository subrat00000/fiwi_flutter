import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/create_batch/create_batch_state.dart';
import 'package:fiwi/models/student.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateBatchCubit extends Cubit<CreateBatchState> {
  CreateBatchCubit() : super(CreateBatchInitialState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");

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
}
