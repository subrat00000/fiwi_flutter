import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateUserCubit extends Cubit<int> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  CreateUserCubit():super(0);

  Future<void> createUser(String userId, String name, String email,String semester, DateTime dob) async {
  final user = {'name': name, 'email': email,'userid':userId,'semester': semester,'dob': dob};
  await ref.child('users').child(userId).set(user);
}
  
}