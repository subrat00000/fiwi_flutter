import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitialState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  Future<void> getAuthentication() async {
    try{
    DataSnapshot user = await ref.child(_auth.currentUser!.uid).get();
    var a = user.value as Map;
    if(a['active']==false){
      emit(UserInactiveState());
    }
    }catch(e){
      emit(ErrorState(e.toString()));
    }
  }
}
