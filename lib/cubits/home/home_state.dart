abstract class HomeState { }

class InitialState extends HomeState {}
class LoadingState extends HomeState {}
class UserInactiveState extends HomeState {}
class UserActiveState extends HomeState {}
class ErrorState extends HomeState {
  String error;
  ErrorState(this.error);
 }