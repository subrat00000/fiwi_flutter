import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/google_signin/google_signin_state.dart';
import 'package:fiwi/cubits/profile/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class ProfileCubit extends Cubit<ProfileState>{
  
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  var box = Hive.box('user');
  ProfileCubit(): super(ProfileInitialState()){
    emit(ProfileLoadingState());
    log(box.toMap().toString());
  }
  Future<void> loadProfile() async {
    try {
      emit(ProfileLoadingState());
      
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }
}