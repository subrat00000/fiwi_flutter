import 'package:firebase_auth/firebase_auth.dart';

abstract class PhoneAuthState {}

class PhoneAuthInitialState extends PhoneAuthState {}

class PhoneAuthLoadingState extends PhoneAuthState {}

class PhoneAuthCodeSentState extends PhoneAuthState {}

class PhoneAuthUserCreateState
    extends PhoneAuthState {
      final User user;
  PhoneAuthUserCreateState(this.user);
} //When phone is authenticated with otp user has to enter details to create profile

class PhoneAuthLoggedInState extends PhoneAuthState {
} //After user profile is created it will be this state

class PhoneAuthLoggedOutState extends PhoneAuthState {}

class PhoneAuthErrorState extends PhoneAuthState {
  final String error;
  PhoneAuthErrorState(this.error);
}
