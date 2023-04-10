//create admin,faculty,librarian
//create all the subjects for university or college
//activate the inactive student of university or college

import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List admin_list = [
    {'icon': 'assets/role.png', 'title': 'Manage Role', 'route': '/managerole'},
    {'title': 'Manage Courses', 'icon': 'assets/courses.png', 'route': '/managecourse'},
    {'title': 'Activate Student', 'icon': 'assets/activate.png', 'route': '/activatestudent'},
    {'title': 'Delete Someone Account', 'icon': 'assets/minus.png', 'route': '/deleteaccount'},
    {'title': 'Chanage Semester', 'icon':'assets/courses.png', 'route':'/changesemester'}
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: Colors.white70,
        child: ListView.builder(
            itemCount: admin_list.length,
            itemBuilder: ((context, index) {
              return Card(
                child: ListTile(
                  title: Text(admin_list[index]['title']),
                  leading: Image.asset(admin_list[index]['icon'],height: 22),
                  onTap: () {
                    Navigator.pushNamed(context, admin_list[index]['route']);
                  },
                ),
              );
            })));
  }
}
