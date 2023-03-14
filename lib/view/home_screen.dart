import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Center(child: Text("hello"));
        },
      ),
    )));
  }
}
