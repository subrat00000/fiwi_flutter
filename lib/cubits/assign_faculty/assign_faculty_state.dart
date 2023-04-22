abstract class AssignFacultyState {}

class AssignFacultyInitialState extends AssignFacultyState {}

class AssignFacultySuccessState extends AssignFacultyState {}

class RemoveFacultySuccessState extends AssignFacultyState {}

class AssignFacultyErrorState extends AssignFacultyState {
  String error;
  AssignFacultyErrorState(this.error);
}