abstract class ChangeSemesterState {}

class ChangeSemesterInitialState extends ChangeSemesterState {}

class ChangeSemesterLoadingState extends ChangeSemesterState {}

class ChangeSemesterSuccessState extends ChangeSemesterState {
  ChangeSemesterSuccessState(List<Object> a);
}

class UnSubscribeAllTopicSuccessState extends ChangeSemesterState {}

class NoUserFoundErrorState extends ChangeSemesterState {
  String oldSemester;
  NoUserFoundErrorState(this.oldSemester);
}

class SubscribeAllTopicSuccessState extends ChangeSemesterState {}

class SubscribeFailedState extends ChangeSemesterState{
  String error;
  SubscribeFailedState(this.error);
}

class UnsubscribeFailedState extends ChangeSemesterState {
  String error;
  UnsubscribeFailedState(this.error);
}

class SuccessFetchUserState extends ChangeSemesterState {
  List data;
  SuccessFetchUserState(this.data);
}

class ChangeSemesterErrorState extends ChangeSemesterState {
  String error;
  ChangeSemesterErrorState(this.error);
}
