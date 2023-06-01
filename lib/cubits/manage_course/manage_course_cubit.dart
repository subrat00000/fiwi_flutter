import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_course/manage_course_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ManageCourseCubit extends Cubit<ManageCourseState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference mrref = FirebaseDatabase.instance.ref('courseList');
  var box = Hive.box('user');
  ManageCourseCubit() : super(ManageCourseInitialState());

  addCourse(value) {
    try {
      mrref.child(value['code'].toLowerCase()).set({
        'name': value['name'],
        'code': value['code'].toUpperCase(),
        'semester': value['semester']
      });

      emit(ManageCourseCreateState());
    } catch (e) {
      emit(ManageCourseErrorState(e.toString()));
    }
  }

  deleteCourse(String code) {
    try {
      mrref.child(code.toLowerCase()).remove();
      emit(ManageCourseDeleteState());
    } catch (e) {
      emit(ManageCourseErrorState(e.toString()));
    }
  }
}
