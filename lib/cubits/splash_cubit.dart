import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

enum SplashState { splash }

class SplashCubit extends Cubit<SplashState> {
  Box box = Hive.box('user');
  SplashCubit() : super(SplashState.splash) {
    init();
  }
  

  init() {
    box.put('notification', [
      {
        'title': 'Welcome to Fiwi',
        'body': 'Your Account is created Successfully',
        'dateTime': DateTime.now().toString()
      }
    ]);
  }
}
