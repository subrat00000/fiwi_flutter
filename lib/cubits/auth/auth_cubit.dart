import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthCubit extends Cubit<AuthState> {
  var box = Hive.box('user');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref('users');
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthCubit() : super(AuthInitialState()) {
    emit(AuthLoadingState());
    if (_auth.currentUser != null) {
      checkRegistration(_auth.currentUser?.uid);
    }
  }
  Future<void> getAuthentication() async {
    try {
      DataSnapshot user = await ref.child(_auth.currentUser!.uid).get();
      var a = user.value as Map;
      if (a['active'] == false) {
        emit(AuthInactiveState());
      } else {
        emit(AuthLoggedInState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void checkRegistration(uid) async {
    if (box.get('uid') != null) {
      log(box.get('uid'));
      if (box.get('active') == false) {
        emit(AuthInactiveState());
        DataSnapshot a = await ref.child(_auth.currentUser!.uid).get();
        var b = a.value as Map;
        if (b['active'] == false) {
          emit(AuthInactiveState());
        } else {
          log('*************up');
          box.put('active', true);
          emit(AuthLoggedInState());
        }
      } else {
        emit(AuthLoggedInState());
        DataSnapshot a = await ref.child(_auth.currentUser!.uid).get();
        var b = a.value as Map;
        if (b['active'] == false) {
          box.put('active', false);
          emit(AuthInactiveState());
        } else {
          log('*************down');

          emit(AuthLoggedInState());
        }
      }
    } else {
      emit(AuthUserCreateState());
    }
  }

  void logOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      box.clear();
      emit(AuthLoggedOutState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}
