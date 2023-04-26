abstract class CreateBatchState {}

class CreateBatchInitialState extends CreateBatchState {}

class CreateBatchSuccessState extends CreateBatchState {}

class CreateBatchErrorState extends CreateBatchState {
  String error;
  CreateBatchErrorState(this.error);
}