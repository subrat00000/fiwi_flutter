import 'package:firebase_auth/firebase_auth.dart';

abstract class GoogleAuthState {}

class GoogleAuthInitialState extends GoogleAuthState {}

class GoogleAuthLoggedInState extends GoogleAuthState {
}

class GoogleAuthUserCreateState extends GoogleAuthState {
  final User user;
  GoogleAuthUserCreateState(this.user);
}
class GoogleAuthStateLoading extends GoogleAuthState {}

class GoogleAuthStateError extends GoogleAuthState {
  final String error;

  GoogleAuthStateError(this.error);
}