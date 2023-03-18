import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthUserCreateState
    extends AuthState {} //When  is authenticated with otp user has to enter details to create profile

class AuthLoggedInState extends AuthState {
} //After user profile is created it will be this state

class AuthLoggedOutState extends AuthState {}

class AuthErrorState extends AuthState {
  final String error;
  AuthErrorState(this.error);
}
