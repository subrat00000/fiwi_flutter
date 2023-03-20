import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PhoneSigninCubit extends Cubit<PhoneAuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  PhoneSigninCubit() : super(PhoneAuthInitialState());

  String? _verificationId;
  var box = Hive.box('user');

  void sendOtp(String phoneNumber) async {
    emit(PhoneAuthLoadingState());
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (phoneAuthCredential) {
        signInWithPhone(phoneAuthCredential);
      },
      verificationFailed: (error) {
        emit(PhoneAuthErrorState(error.message.toString()));
      },
      codeSent: (verificationId, forceResendingToken) {
        _verificationId = verificationId;
        emit(PhoneAuthCodeSentState());
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void verifyOtp(String otp) async {
    emit(PhoneAuthLoadingState());
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: otp);
    signInWithPhone(credential);
  }

  void signInWithPhone(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        DatabaseEvent de = await ref.child(userCredential.user!.uid).once();
        if (de.snapshot.exists) {
          log("User Exists");
          box.putAll(de.snapshot.value as Map<dynamic, dynamic>);
          emit(PhoneAuthLoggedInState());
        } else {
          emit(PhoneAuthUserCreateState(userCredential.user!));
        }
      } else {
        emit(PhoneAuthErrorState("Authentication Error"));
      }
    } on FirebaseAuthException catch (ex) {
      emit(PhoneAuthErrorState(ex.message.toString()));
    } catch (ex) {
      emit(PhoneAuthErrorState(ex.toString()));
    }
  }
}
