import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/create_user/create_user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class CreateUserCubit extends Cubit<CreateUserProfileState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CreateUserCubit() : super(CreateUserProfileInitialState());
  var box = Hive.box('user');

  Future<void> createUser(String name, String email, 
      String address, String dob) async {
        emit(CreateUserProfileLoadingState());
    try {
      final user = {
        'name': name,
        'email': email,
        'uid': _auth.currentUser!.uid,
        'dob': dob,
        'address': address
      };
      await ref.child(_auth.currentUser!.uid).set(user);
      DatabaseEvent de = await ref.child(_auth.currentUser!.uid).once();
      if (de.snapshot.exists) {
        box.putAll(de.snapshot.value as Map<dynamic, dynamic>);
        emit(CreateUserProfileSuccessState());
      }
    } on Exception catch (e) {
      emit(CreateUserProfileErrorState(e.toString()));
    }
  }
}
