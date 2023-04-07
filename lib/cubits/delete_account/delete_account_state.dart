abstract class DeleteAccountState {}

class DeleteAccountInitialState extends DeleteAccountState {}

class DeleteAccountSuccessState extends DeleteAccountState {}

class DeleteAccountErrorState extends DeleteAccountState {
  String error;
  DeleteAccountErrorState(this.error);
}