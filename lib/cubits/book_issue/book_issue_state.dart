abstract class BookIssueState {}

class BookIssueInitialState extends BookIssueState {}

class BookIssueSuccessState extends BookIssueState {}

class BookAlreadyIssueRequestDoneState extends BookIssueState {}

class BookAlreadyBorrowedState extends BookIssueState {}

class BookIssueErrorState extends BookIssueState {
  String error;
  BookIssueErrorState(this.error);
}