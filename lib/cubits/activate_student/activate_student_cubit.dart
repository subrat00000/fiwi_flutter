import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ActivateStudentCubit extends Cubit<ActivateStudentState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var box = Hive.box('user');
  ActivateStudentCubit() : super(ActivateStudentInitialState());

  activateStudent(uid,bool value) {
    try {
      ref.child(uid).update({'active': value});
      emit(ActivateStudentSuccessState());
    } catch (e) {
      emit(ActivateStudentErrorState(e.toString()));
    }
  }
}
