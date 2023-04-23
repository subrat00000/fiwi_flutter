
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'Attendance Page',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        ElevatedButton(
          onPressed: () {
            // context.read<BottomNavCubit>().getHome();
          },
          child: Text('GO TO HOME'),
        )
      ]),
    );
  }
}
