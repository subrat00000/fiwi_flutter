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

class BorrowBookScreen extends StatefulWidget {
  const BorrowBookScreen({super.key});

  @override
  State<BorrowBookScreen> createState() => BorrowBookScreenState();
}

class BorrowBookScreenState extends State<BorrowBookScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87),
          ),
          title: const Text(
            'Borrowed Books',
            style: TextStyle(color: Colors.black87, fontSize: 20),
            textAlign: TextAlign.start,
          ),
        ),
      body: Column(
        children: [
          Stack(
            children: [
              
            ],
          ),
        ],
      ),
    );
  }
}
