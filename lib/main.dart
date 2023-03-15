import 'package:firebase_auth/firebase_auth.dart';
import 'package:fiwi/cubits/google_signin/google_signin_cubit.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_state.dart';
import 'package:fiwi/routers.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: Routers.generateRoute,
      initialRoute: _auth.currentUser != null ? '/home' : '/splash',
    );
  }
}
