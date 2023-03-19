abstract class CreateUserProfileState {}

class CreateUserProfileInitialState extends CreateUserProfileState{}

class CreateUserProfileLoadingState extends CreateUserProfileState{}

class CreateUserProfileSuccessState extends CreateUserProfileState{}

class CreateUserProfileErrorState extends CreateUserProfileState{
  final String e;
  CreateUserProfileErrorState(this.e);
}