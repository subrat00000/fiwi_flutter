import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/create_user/create_user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class CreateUserCubit extends Cubit<CreateUserProfileState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference mrref = FirebaseDatabase.instance.ref('manageRole');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var box = Hive.box('user');
  CreateUserCubit() : super(CreateUserProfileInitialState()) {
    _checkAccess();
  }
  Future<void> _checkAccess() async {
    try {
      if (_auth.currentUser!.email != null) {
        String email = _auth.currentUser!.email!.replaceAll('@gmail.com', '');
        DataSnapshot dbemail = await mrref.child(email).get();
        var value = dbemail.value as Map;
        if (value['email'] == _auth.currentUser!.email) {
          log('email exist');
          mrref
              .child(email)
              .update({'uid': _auth.currentUser!.uid})
              .then((a) => createSpecialUser(value['name'],value['role']))
              .onError((error, stackTrace) => null);
        }
      } else if (_auth.currentUser!.phoneNumber != null) {
        String phone = _auth.currentUser!.phoneNumber!;
        DataSnapshot dbphone = await mrref.child(phone).get();
        var value = dbphone.value as Map;
        if (value['phone'] == _auth.currentUser!.phoneNumber) {
          log('phone number exist');
          mrref
              .child(phone)
              .update({'uid': _auth.currentUser!.uid})
              .then((a) => createSpecialUser(value['name'],value['role']))
              .onError((error, stackTrace) => null);
        }
      } else {
        log('student');
      }
    } catch (e) {
      emit(CreateUserProfileErrorState(e.toString()));
    }
  }

  Future<void> createSpecialUser(name,role) async {
    emit(CreateUserProfileLoadingState());
    try {
      final user = {
        'name': name,
        'email': _auth.currentUser!.email,
        'uid': _auth.currentUser!.uid,
        'photo': _auth.currentUser!.photoURL,
        'bio': 'Your bio infomation',
        'phone': _auth.currentUser!.phoneNumber.toString(),
        'role': role,
        'active': true,
        'emailVerified': _auth.currentUser!.emailVerified
      };
      await ref.child(_auth.currentUser!.uid).set(user);
      DataSnapshot de = await ref.child(_auth.currentUser!.uid).get();
      if (de.exists) {
        box.putAll(de.value as Map<dynamic, dynamic>);
        emit(CreateUserProfileSuccessState());
      }
    } on Exception catch (e) {
      emit(CreateUserProfileErrorState(e.toString()));
    }
  }

  Future<void> createUser(String name, String email, String address,
      String birthday, String sem) async {
    emit(CreateUserProfileLoadingState());
    try {
      final user = {
        'name': name,
        'email': email,
        'uid': _auth.currentUser!.uid,
        'birthday': birthday,
        'address': address,
        'photo': _auth.currentUser!.photoURL,
        'bio': 'Your bio infomation',
        'phone': _auth.currentUser!.phoneNumber.toString(),
        'role': 'student',
        'semester': sem,
        'emailVerified': _auth.currentUser!.emailVerified,
        'active': false
      };
      await ref.child(_auth.currentUser!.uid).set(user);
      DataSnapshot de = await ref.child(_auth.currentUser!.uid).get();
      if (de.exists) {
        box.putAll(de.value as Map<dynamic, dynamic>);
        emit(CreateUserProfileSuccessState());
      }
    } on Exception catch (e) {
      emit(CreateUserProfileErrorState(e.toString()));
    }
  }
}
