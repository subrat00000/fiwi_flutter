import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AuthCubit extends Cubit<AuthState> {
  var box = Hive.box('user');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthCubit() : super(AuthInitialState()) {
    emit(AuthLoadingState());
    if (_auth.currentUser != null) {
      checkRegistration(_auth.currentUser?.uid);
    }
  }

  void checkRegistration(uid) async {
    if(box.get('uid')!=null){
      log(box.get('name'));
      emit(AuthLoggedInState());
    } else {
      emit(AuthUserCreateState());
    }
    
  }

  void logOut() async {
    await _auth.signOut();
    emit(AuthLoggedOutState());
  }
}
