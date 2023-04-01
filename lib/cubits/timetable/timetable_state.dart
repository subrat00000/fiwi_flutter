abstract class TimetableState {}

class TimetableInitialState extends TimetableState {}

class TimetableLoadingState extends TimetableState {}

class TimetableAddPeriodState extends TimetableState {}

class TimetableEditPeriodState extends TimetableState {}

class TimetableDeletePeriodState extends TimetableState {}

class TimetableErrorState extends TimetableState {
  String error;
  TimetableErrorState(this.error);
}