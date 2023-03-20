import 'dart:io';

import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/repositories/exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  _showExitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => exit(0),
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  var internet = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Exit().showExitDialog(context);
      },
      child: Scaffold(
          body: SafeArea(
              child: MultiBlocListener(
        listeners: [
          BlocListener<InternetCubit, InternetState>(
            listener: (context, state) {
              if (state == InternetState.gained && internet == false) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Internet conntected"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
                internet = true;
              } else if (state == InternetState.lost) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("No Internet Connection found"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
                internet = false;
              }
            },
          ),
          BlocListener<HomeCubit, HomeState>(
            listener: (context, state) {
              // TODO: implement listener
            },
          ),
        ],
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if(state is AuthLoggedOutState){
              Navigator.pushNamed(context,'/splash');
            }
          },
          builder: (context, state) {
            return TextButton(onPressed: (){BlocProvider.of<AuthCubit>(context).logOut();}, child: const Text("Logout"));
          },
        ),
      ))),
    );
  }
}
