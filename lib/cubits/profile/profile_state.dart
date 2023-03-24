class ProfileState{}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState{}

class ProfileGetDataState extends ProfileState {}

class ProfileErrorState extends ProfileState {
  String string;
  ProfileErrorState(this.string);
}
