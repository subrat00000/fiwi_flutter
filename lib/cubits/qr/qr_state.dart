abstract class QrState {}

class QrInitialState extends QrState {}

class PreSetupForAttendanceSuccessState extends QrState {}

class QrErrorState extends QrState {
  String error;
  QrErrorState(this.error);
}