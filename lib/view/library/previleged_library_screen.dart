
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class PrevilegedLibraryScreen extends StatefulWidget {
  const PrevilegedLibraryScreen({super.key});

  @override
  State<PrevilegedLibraryScreen> createState() => _PrevilegedLibraryScreenState();
}

class _PrevilegedLibraryScreenState extends State<PrevilegedLibraryScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'Library Page',
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