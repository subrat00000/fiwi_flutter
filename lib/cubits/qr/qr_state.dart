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

class QrErrorState extends QrState {
  String error;
  QrErrorState(this.error);
}