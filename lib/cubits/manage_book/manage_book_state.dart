abstract class ManageBookState {}

class ManageBookInitialState extends ManageBookState {}

class AddBookSuccessState extends ManageBookState {}

class UpdateBookSuccessState extends ManageBookState {}

class ManageBookErrorState extends ManageBookState {
  String error;
  ManageBookErrorState(this.error);
}