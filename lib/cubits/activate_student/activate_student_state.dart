abstract class ActivateStudentState {}

class ActivateStudentInitialState extends ActivateStudentState {}

class ActivateStudentSuccessState extends ActivateStudentState {}

class ActivateStudentErrorState extends ActivateStudentState {
  String error;
  ActivateStudentErrorState(this.error);
}