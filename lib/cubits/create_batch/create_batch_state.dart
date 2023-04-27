abstract class CreateBatchState {}

class CreateBatchInitialState extends CreateBatchState {}

class CreateBatchSuccessState extends CreateBatchState {}

class UpdateBatchSuccessState extends CreateBatchState {}

class DeleteBatchSuccessState extends CreateBatchState {}

class CreateBatchErrorState extends CreateBatchState {
  String error;
  CreateBatchErrorState(this.error);
}