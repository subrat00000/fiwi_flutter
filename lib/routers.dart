import 'package:fiwi/cubits/google_signin/google_signin_cubit.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/cubits/google_signin/otp_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_cubit.dart';
import 'package:fiwi/cubits/splash_cubit.dart';
import 'package:fiwi/cubits/wrong_page_cubit.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/signin/google_signin.dart';
import 'package:fiwi/view/signin/otp.dart';
import 'package:fiwi/view/signin/phone_signin.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Routers {
  static Route generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case '/splash':
        return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => SplashCubit(),
                    ),
                    BlocProvider(
                      create: (context) => InternetCubit(),
                    ),
                  ],
                  child: const SplashScreen(),
                ));
      case '/googlesignin':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => GoogleSigninCubit(),
                  child: const GoogleSignin(),
                ));
      case '/phonesignin':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => PhoneSigninCubit(),
                  child: const PhoneSignin(),
                ));
      case '/otp':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => OtpCubit(),
                  child: const Otp(),
                ));
      case '/home':
        return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => HomeCubit(),
                    ),
                    BlocProvider(
                      create: (context) => InternetCubit(),
                    ),
                  ],
                  child: const HomeScreen(),
                ));
      default:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            create: (context) => WrongPage(),
            child: const Scaffold(
              body: Center(
                child: Text(
                  'Some thing went wrong!!!',
                  style: TextStyle(color: Colors.red, fontSize: 30),
                ),
              ),
            ),
          );
        });
    }
  }
}
