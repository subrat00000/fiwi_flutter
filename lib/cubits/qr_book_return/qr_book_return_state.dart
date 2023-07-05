abstract class QrBookReturnState{}

class QrBookReturnInitialState extends QrBookReturnState{}

class QrBookReturnSuccessState extends QrBookReturnState {}

class QrBookReturnErrorState extends QrBookReturnState {
  String error;
  QrBookReturnErrorState(this.error);
}