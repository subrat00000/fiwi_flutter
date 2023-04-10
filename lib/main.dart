import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiwi/cubits/activate_student/activate_student_cubit.dart';
import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/change_semester/change_semester_cubit.dart';
import 'package:fiwi/cubits/create_user/create_user_cubit.dart';
import 'package:fiwi/cubits/delete_account/delete_account_cubit.dart';
import 'package:fiwi/cubits/google_signin/google_signin_cubit.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/cubits/manage_course/manage_course_cubit.dart';
import 'package:fiwi/cubits/manage_role/manage_role_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_state.dart';
import 'package:fiwi/cubits/profile/profile_cubit.dart';
import 'package:fiwi/cubits/splash_cubit.dart';
import 'package:fiwi/cubits/timetable/selectable_grid_cubit.dart';
import 'package:fiwi/cubits/timetable/timetable_cubit.dart';
import 'package:fiwi/routers.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/information.dart';
import 'package:fiwi/view/signin/create_user.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'dart:developer';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('user');
  Box box = Hive.box('user');
  List notification = [];
  notification = box.get('notification') ??[];
  notification.insert(0,{
    'body': message.notification!.body.toString(),
    'title': message.notification!.title.toString(),
    'dateTime':message.data['dateTime'].toString()
  });
  box.put('notification',notification);
  log("hellosdflkasf");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
        BlocProvider(
          create: (context) => BottomNavCubit(),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(),
        ),
        BlocProvider(create: (context) => TimetableCubit()),
        BlocProvider(
          create: (context) => ManageRoleCubit(),
        ),
        BlocProvider(
          create: (context) => ManageCourseCubit(),
        ),
        BlocProvider(
          create: (context) => ActivateStudentCubit(),
        ),
        BlocProvider(
          create: (context) => DeleteAccountCubit(),
        ),
        BlocProvider(
          create: (context) => ChangeSemesterCubit(),
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return MaterialApp(
              theme: ThemeData(
                primarySwatch: Colors.purple,
                appBarTheme: const AppBarTheme(
                  color: Colors.white10,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.white10,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ),
                  elevation: 0.0,
                  iconTheme: IconThemeData(color: Colors.white),
                  // systemOverlayStyle: SystemUiOverlayStyle.dark,
                ),
              ),
              onGenerateRoute: Routers.generateRoute,
              home: state is AuthLoggedInState
                  ? const HomeScreen()
                  : state is AuthInactiveState
                      ? Information()
                      : state is AuthUserCreateState
                          ? const CreateUser()
                          : const SplashScreen());
        },
      ),
    );
  }
}
