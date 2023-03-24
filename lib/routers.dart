import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/notification_screen.dart';
import 'package:fiwi/view/profile_screen.dart';
import 'package:fiwi/view/signin/create_user.dart';
import 'package:fiwi/view/signin/google_signin.dart';
import 'package:fiwi/view/signin/otp.dart';
import 'package:fiwi/view/signin/phone_signin.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Routers {
  static Route generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case '/splash':
        return MaterialPageRoute(
            builder: (context) => const SplashScreen());
      case '/googlesignin':
        return MaterialPageRoute(
            builder: (context) => const GoogleSignin());
      case '/phonesignin':
        return MaterialPageRoute(
            builder: (context) => const PhoneSignin());
      case '/otp':
        return MaterialPageRoute(
            builder: (context) => const Otp());
      case '/createuser':
        return MaterialPageRoute(
            builder: (context) => const CreateUser());
      case '/home':
        return MaterialPageRoute(
            builder: (context) => const HomeScreen());
      case '/profile':
        return PageTransition(child: const ProfileScreen(), type: PageTransitionType.leftToRight);
      case '/notification':
        return PageTransition(child: const NotificationScreen(), type: PageTransitionType.rightToLeft);
      default:
        return MaterialPageRoute(builder: (context) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Some thing went wrong!!!',
                style: TextStyle(color: Colors.red, fontSize: 30),
              ),
            ),
          );
        });
    }
  }
}
