import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/view/timetable/streambuilder_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:intl/intl.dart';



class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<StatefulWidget> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  Box box = Hive.box('user');
  
  String? role;
  bool isEdit =false;

  _loadData() {
      role = box.get('role') ?? '';
      if(role=='admin' || role=='faculty') {
        isEdit=true;
      }
    
  }
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left:5, right:5),
        child: ListView(
          children: <Widget>[
            StreamBuilderWidget(day: 'Monday', dayInNum: '1',isEdit: isEdit),
            StreamBuilderWidget(day: 'Tuesday', dayInNum: '2',isEdit: isEdit),
            StreamBuilderWidget(day: 'WednesDay', dayInNum: '3',isEdit: isEdit),
            StreamBuilderWidget(day: 'Thursday', dayInNum: '4',isEdit: isEdit),
            StreamBuilderWidget(day: 'Friday', dayInNum: '5',isEdit: isEdit),
            StreamBuilderWidget(day: 'Satarday', dayInNum: '6',isEdit: isEdit),
          ],
        ),
      );
    
  }
}
