abstract class TimetableState {}

class TimetableInitialState extends TimetableState {}

class TimetableLoadingState extends TimetableState {}

class TimetableAddPeriodSuccessState extends TimetableState {}

class TimetableEditPeriodSuccessState extends TimetableState {}

class TimetableDeletePeriodSuccessState extends TimetableState {}

class TimetableErrorState extends TimetableState {
  String error;
  TimetableErrorState(this.error);
}