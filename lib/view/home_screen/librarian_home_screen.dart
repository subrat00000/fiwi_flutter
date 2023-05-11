import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/change_semester/change_semester_cubit.dart';
import 'package:fiwi/models/chartdata.dart';
import 'package:fiwi/models/timetable.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LibrarianHomeScreen extends StatefulWidget {
  const LibrarianHomeScreen({super.key});

  @override
  State<LibrarianHomeScreen> createState() => LibrarianHomeScreenState();
}

class LibrarianHomeScreenState extends State<LibrarianHomeScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  Widget float1() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: null,
      heroTag: "student_borrowed",
      tooltip: 'Student Borrowed',
      child: Image.asset('assets/borrow.png',cacheHeight: 35,),
    );
  }

  Widget float2() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/addbooks'),
      heroTag: "books",
      tooltip: 'Books',
      child: Icon(Icons.menu_book_rounded),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: AnimatedFloatingActionButton(
        animatedIconData: AnimatedIcons.menu_close,
        curve: Curves.easeInCubic,
        durationAnimation: 200,
        fabButtons: <Widget>[float1(), float2()],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: _isExpanded ? 60 : 0,
            width: _isExpanded ? 60 : 0,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: _isExpanded
                ? IconButton(
                    onPressed: () {
                      // Do something when the extra button is pressed
                    },
                    icon: const Icon(Icons.more_vert),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
