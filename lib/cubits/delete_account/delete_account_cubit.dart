import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/delete_account/delete_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  var box = Hive.box('user');
  DeleteAccountCubit() : super(DeleteAccountInitialState());

  deleteAccount(uid) {
    try {
      ref.child(uid).remove();
      ref.child(uid).set({'active':false});
      emit(DeleteAccountSuccessState());
    } catch (e) {
      emit(DeleteAccountErrorState(e.toString()));
    }
  }
}
