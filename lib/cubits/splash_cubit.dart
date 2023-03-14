import 'package:flutter_bloc/flutter_bloc.dart';

enum SplashState {splash}
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(): super(SplashState.splash);
  
}