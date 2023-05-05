abstract class QrState {}

class QrInitialState extends QrState {}

class PreSetupForAttendanceSuccessState extends QrState {
  String encryptedMessage;
  PreSetupForAttendanceSuccessState(this.encryptedMessage);
}

class AttendanceAlreadyInitialized extends QrState{
  String encryptedOldMessage;
  AttendanceAlreadyInitialized(this.encryptedOldMessage);
}
class TakeAttendanceSuccessState extends QrState{}

class TakeAttendanceErrorState extends QrState {
  String error;
  TakeAttendanceErrorState(this.error);
}

class UpdateAttendanceSuccessState extends QrState{}

class QrErrorState extends QrState {
  String error;
  QrErrorState(this.error);
}