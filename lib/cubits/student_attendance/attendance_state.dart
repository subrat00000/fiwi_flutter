abstract class StudentAttendanceState{}

class StudentAttendanceInitialState extends StudentAttendanceState {}

class AtudentAttendanceSuccessState extends StudentAttendanceState {}

class StudentAttendanceErrorState extends StudentAttendanceState {
  String error;
  StudentAttendanceErrorState(this.error);
}