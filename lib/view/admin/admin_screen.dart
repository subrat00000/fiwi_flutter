//create admin,faculty,librarian
//create all the subjects for university or college
//activate the inactive student of university or college

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Box box = Hive.box('user');
  List adminList = [
    {'icon': 'assets/role.png', 'title': 'Manage Role', 'route': '/managerole'},
    {
      'title': 'Manage Courses',
      'icon': 'assets/courses.png',
      'route': '/managecourse'
    },
    {
      'title': 'Activate Student',
      'icon': 'assets/activate.png',
      'route': '/activatestudent'
    },
    {
      'title': 'Delete Someone Account',
      'icon': 'assets/minus.png',
      'route': '/deleteaccount'
    },
    {
      'title': 'Chanage Semester',
      'icon': 'assets/change_semester.png',
      'route': '/changesemester'
    },
    {
      'title': 'Manage Batches',
      'icon': 'assets/manage_batch.png',
      'route': '/showbatch'
    },
    {
      'title': 'Simplify Timetable',
      'icon': 'assets/simplify_timetable.png',
      'route': 'simplify_timetable'
    }
  ];
  bool simpleTimetable = true;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() {
    setState(() {
      simpleTimetable = box.get('simpleTimetable') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: Colors.white70,
        child: ListView.builder(
          shrinkWrap: true,
            itemCount: adminList.length,
            itemBuilder: ((context, index) {
              return Card(
                child: ListTile(

                  trailing: adminList[index]['route'] == 'simplify_timetable'
                      ? Switch(value: simpleTimetable, onChanged: (value) {
                        box.put('simpleTimetable', value);
                        _loadData();
                      })
                      : const SizedBox(width: 0,height: 0,),
                  title: Text(adminList[index]['title']),
                  leading: Image.asset(adminList[index]['icon'], height: 22),
                  onTap: () {
                    if (adminList[index]['route'] == 'simplify_timetable') {
                    } else {
                      Navigator.pushNamed(context, adminList[index]['route']);
                    }
                  },
                ),
              );
            })));
  }
}
