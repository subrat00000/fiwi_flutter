import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var internet = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: BlocConsumer<InternetCubit, InternetState>(
                    listener: (context, state) {
      if (state == InternetState.gained && internet==false) {
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
        internet=false;
      }
    }, builder: (context, state) {
      return const Text("");
    }))));
  }
}
