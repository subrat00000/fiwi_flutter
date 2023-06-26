abstract class TrackBookState{}

class TrackBookInitialState extends TrackBookState {}

class ExpressCheckoutSuccessState extends TrackBookState {}

class TrackBookErrorState extends TrackBookState {
  String error;
  TrackBookErrorState(this.error);
}