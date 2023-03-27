import 'package:hive/hive.dart';

abstract class ProfileState{}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState{}

class ProfileGetDataSuccessState extends ProfileState {
  Box box;
  ProfileGetDataSuccessState(this.box);
}

class ProfileUpdateDataSuccessState extends ProfileState {
  Map<dynamic,dynamic>? data;
  ProfileUpdateDataSuccessState(data);
}

class ProfileErrorState extends ProfileState {
  String error;
  ProfileErrorState(this.error);
}
