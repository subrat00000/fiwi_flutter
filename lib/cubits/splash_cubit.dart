import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

enum SplashState { splash }

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState.splash) {
    init();
  }
  Box box = Hive.box('user');

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
