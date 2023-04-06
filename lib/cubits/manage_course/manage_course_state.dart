abstract class ManageCourseState {}

class ManageCourseInitialState extends ManageCourseState{}

class ManageCourseCreateState extends ManageCourseState {}

class ManageCourseErrorState extends ManageCourseState{
  String error;
  ManageCourseErrorState(this.error);
}

class ManageCourseDeleteState extends ManageCourseState {}