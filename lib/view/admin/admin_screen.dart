//create admin,faculty,librarian
//create all the subjects for university or college
//activate the inactive student of university or college

import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Box box = Hive.box('user');
  List admin_list = [
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
      'icon': 'assets/courses.png',
      'route': '/changesemester'
    },
    {
      'title': 'Timetable Simplification',
      'icon': 'assets/role.png',
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
            itemCount: admin_list.length,
            itemBuilder: ((context, index) {
              return Card(
                child: ListTile(

                  trailing: admin_list[index]['route'] == 'simplify_timetable'
                      ? Switch(value: simpleTimetable, onChanged: (value) {
                        box.put('simpleTimetable', value);
                        _loadData();
                      })
                      : const SizedBox(width: 0,height: 0,),
                  title: Text(admin_list[index]['title']),
                  leading: Image.asset(admin_list[index]['icon'], height: 22),
                  onTap: () {
                    if (admin_list[index]['route'] == 'simplify_timetable') {
                    } else {
                      Navigator.pushNamed(context, admin_list[index]['route']);
                    }
                  },
                ),
              );
            })));
  }
}
