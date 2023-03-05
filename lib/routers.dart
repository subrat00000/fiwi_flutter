import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/signin/google_signin.dart';
import 'package:fiwi/view/signin/otp.dart';
import 'package:fiwi/view/signin/phone_signin.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:flutter/material.dart';

class Routers {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch(setting.name) {
      case '':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case 'googlesignin':
        return MaterialPageRoute(builder: (_) => const GoogleSignin());
      case 'phonesignin':
        return MaterialPageRoute(builder: (_) => const PhoneSignin());
      case 'otp':
        return MaterialPageRoute(builder: (_) => const Otp());
      case 'home':
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(
              child: Text('Some thing went wrong!!!'),
            ),
          );
        });
    }
  }
}