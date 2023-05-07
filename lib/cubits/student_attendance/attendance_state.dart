abstract class StudentAttendanceState{}

class StudentAttendanceInitialState extends StudentAttendanceState {}

class StudentAttendanceSuccessState extends StudentAttendanceState {
  String data;
  StudentAttendanceSuccessState(this.data);
}

class StudentLocationPermissionErrorState extends StudentAttendanceState {}

class StudentLocationServiceErrorState extends StudentAttendanceState {}

class StudentAttendanceErrorState extends StudentAttendanceState {
  String error;
  StudentAttendanceErrorState(this.error);
}