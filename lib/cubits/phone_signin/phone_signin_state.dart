import 'package:firebase_auth/firebase_auth.dart';

abstract class PhoneAuthState {}

class PhoneAuthInitialState extends PhoneAuthState {}

class PhoneAuthLoadingState extends PhoneAuthState {}

class PhoneAuthCodeSentState extends PhoneAuthState {
  final String vID;
  PhoneAuthCodeSentState(this.vID);
}

class PhoneAuthUserCreateState
    extends PhoneAuthState {} //When phone is authenticated with otp user has to enter details to create profile

class PhoneAuthLoggedInState extends PhoneAuthState {
  final User firebaseUser;
  PhoneAuthLoggedInState(this.firebaseUser);
  // final bool isAdmin;
  // AuthLoggedInState(this.firebaseUser,this.isAdmin);
} //After user profile is created it will be this state

class PhoneAuthLoggedOutState extends PhoneAuthState {}

class PhoneAuthErrorState extends PhoneAuthState {
  final String error;
  PhoneAuthErrorState(this.error);
}
