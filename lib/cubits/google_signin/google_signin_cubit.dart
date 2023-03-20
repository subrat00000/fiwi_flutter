import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/google_signin/google_signin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class GoogleAuthCubit extends Cubit<GoogleAuthState>{
  GoogleAuthCubit(): super(GoogleAuthInitialState());
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  var box = Hive.box('user');

  Future<void> signInWithGoogle() async {
    try {
      emit(GoogleAuthStateLoading());
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        DataSnapshot de = await ref.child(userCredential.user!.uid).get();
        if (de.exists) {
          log("User Exists");
          box.putAll(de.value as Map<dynamic, dynamic>);
          emit(GoogleAuthLoggedInState());
        } else {
          emit(GoogleAuthUserCreateState(user));
        }
        
      } else {
        emit(GoogleAuthStateError("Authentication Error"));
      }
    } catch (e) {
      emit(GoogleAuthStateError(e.toString()));
    }
  }
}