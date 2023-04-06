abstract class ManageRoleState {}

class ManageRoleInitialState extends ManageRoleState {}

class ManageRoleAddSpecialUserSuccessState extends ManageRoleState {}

class ManageRoleDisplaySpecialUserState extends ManageRoleState {}

class ManageRoleErrorState extends ManageRoleState {
  String error;
  ManageRoleErrorState(this.error);
}