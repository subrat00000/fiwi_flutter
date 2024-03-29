abstract class TrackBookState{}

class TrackBookInitialState extends TrackBookState {}

class ExpressCheckoutSuccessState extends TrackBookState {}

class ExpressCheckoutLoadingState extends TrackBookState {}

class ExpressCheckoutBookAlreadyAllotedState extends TrackBookState {}

class RejectIssueBookSuccessState extends TrackBookState {}

class TrackBookErrorState extends TrackBookState {
  String error;
  TrackBookErrorState(this.error);
}