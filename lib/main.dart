import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:fiwi/cubits/create_user/create_user_cubit.dart';
import 'package:fiwi/cubits/google_signin/google_signin_cubit.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_state.dart';
import 'package:fiwi/cubits/splash_cubit.dart';
import 'package:fiwi/routers.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/signin/create_user.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  await Hive.initFlutter();
  await Hive.openBox('user');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SplashCubit(),
        ),
        BlocProvider(
          create: (context) => PhoneSigninCubit(),
        ),
        BlocProvider(
          create: (context) => GoogleAuthCubit(),
        ),
        BlocProvider(
          create: (context) => HomeCubit(),
        ),
        BlocProvider(
          create: (context) => InternetCubit(),
        ),
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => CreateUserCubit(),
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return MaterialApp(
              onGenerateRoute: Routers.generateRoute,
              home: state is AuthLoggedInState
                  ? const HomeScreen()
                  : state is AuthUserCreateState
                      ? const CreateUser()
                      : const SplashScreen()
                      );
        },
      ),
    );
  }
}
