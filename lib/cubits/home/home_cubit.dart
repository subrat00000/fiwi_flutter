import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitialState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final DatabaseReference keyref = FirebaseDatabase.instance.ref("key");
  Box box = Hive.box('user');

  Future<void> getAuthentication() async {
    try{
    DataSnapshot user = await ref.child(_auth.currentUser!.uid).get();
    var a = user.value as Map;
    if(a['active']==false){
      emit(UserInactiveState());
    } else {
      emit(UserActiveState());
    }
    }catch(e){
      emit(ErrorState(e.toString()));
    }
  }
  getKey() async {
    DataSnapshot key = await keyref.get();
    final keyvalue = key.value.toString();
    box.put('key', keyvalue);
  }
}
