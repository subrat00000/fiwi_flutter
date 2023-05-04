
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
    
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'AttendanceReport Page',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          ElevatedButton(
            onPressed: () {
              // context.read<BottomNavCubit>().getHome();
            },
            child: Text('GO TO HOME'),
          )
        ]),
      ),
    );
  }
}
