abstract class QrScanBookState{}

class QrScanBookInitialState extends QrScanBookState{}

class QrScanBookIssueSuccessState extends QrScanBookState {}

class QrScanBookInvalidUserState extends QrScanBookState {}

class QrScanReturnBookSuccessState extends QrScanBookState {}

class QrScanBookErrorState extends QrScanBookState {
  String error;
  QrScanBookErrorState(this.error);
}