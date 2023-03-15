import 'package:fiwi/cubits/google_signin/google_signin_cubit.dart';
import 'package:fiwi/cubits/google_signin/phone_signin_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/cubits/phone_signin/phone_signin_cubit.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PhoneSigninCubit(),
        ),
        BlocProvider(
          create: (context) => GoogleSigninCubit(),
        ),
      ],
      child: MaterialApp(
        home: BlocBuilder<PhoneSigninCubit, AuthState>(
          buildWhen: (oldState, newState) {
            return oldState is AuthInitialState;
          },
          builder: (context, state) {
            if (state is AuthUserCreateState) {
              return const HomeScreen();
            } else {
              return const SplashScreen();
            }
          },
        ),
        onGenerateRoute: Routers.generateRoute,
        initialRoute: '/splash',
      ),
    );
  }
}
// BlocConsumer<InternetCubit, InternetState>(
//                     listener: (context, state) {
//       if (state == InternetState.gained && internet == false) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text("Internet conntected"),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ));
//         internet = true;
//       } else if (state == InternetState.lost) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text("No Internet Connection found"),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//         ));
//         internet = false;
//       }
//     }, builder: (context, state) {