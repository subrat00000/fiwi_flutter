import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/google_signin/google_signin_state.dart';
import 'package:fiwi/cubits/profile/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class ProfileCubit extends Cubit<ProfileState>{
  
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  var box = Hive.box('user');
  ProfileCubit(): super(ProfileInitialState());
  void loadData() {
    if (box.isNotEmpty) {
      emit(ProfileGetDataSuccessState(box));
    } else {
      emit(ProfileErrorState('Data not found'));
    }
  }

  Future<void> saveData(Map<String, Object> data) async {
    try{
      ref.child(_auth.currentUser!.uid).update(data);
      box.putAll(data);
      emit(ProfileUpdateDataSuccessState(data));
    } catch(e){
      emit(ProfileErrorState(e.toString()));
    }
    
  }
}