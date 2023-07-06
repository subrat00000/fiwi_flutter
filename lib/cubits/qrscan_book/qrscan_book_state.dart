abstract class QrScanBookState{}

class QrScanBookInitialState extends QrScanBookState{}

class QrScanBookSuccessState extends QrScanBookState {}

class QrScanBookErrorState extends QrScanBookState {
  String error;
  QrScanBookErrorState(this.error);
}