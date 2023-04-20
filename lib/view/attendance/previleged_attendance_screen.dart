
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class PrevilegedAttendanceScreen extends StatefulWidget {
  const PrevilegedAttendanceScreen({super.key});

  @override
  State<PrevilegedAttendanceScreen> createState() => _PrevilegedAttendanceScreenState();
}

class _PrevilegedAttendanceScreenState extends State<PrevilegedAttendanceScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green,
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
