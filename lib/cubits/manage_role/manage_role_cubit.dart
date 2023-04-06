import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_role/manage_role_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ManageRoleCubit extends Cubit<ManageRoleState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference mrref = FirebaseDatabase.instance.ref('manageRole');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var box = Hive.box('user');
  ManageRoleCubit() : super(ManageRoleInitialState());

  void createSpecialUserWithEmail(String email, String name, String role) {
    try {
      String username = email.replaceAll('@gmail.com', '');
      mrref.child(username).set({'name': name, 'email': email, 'role': role.toLowerCase()});
      emit(ManageRoleAddSpecialUserSuccessState());
    } catch (e) {
      emit(ManageRoleErrorState(e.toString()));
    }
  }

  void createSpecialUserWithPhone(String phone, String name, String role) {
    try {
      mrref
          .child(phone.toString())
          .set({'name': name, 'phone': phone, 'role': role.toLowerCase()});
      emit(ManageRoleAddSpecialUserSuccessState());
    } catch (e) {
      emit(ManageRoleErrorState(e.toString()));
    }
  }
}
