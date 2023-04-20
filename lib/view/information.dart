import 'dart:async';

import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<StatefulWidget> createState() => InformationState();
}

class InformationState extends State<Information> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      BlocProvider.of<AuthCubit>(context).getAuthentication();
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    } // cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Your account is successfully created. \n Please wait until your account gets activated.',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ));
  }
}
