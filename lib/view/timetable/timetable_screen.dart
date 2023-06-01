import 'package:fiwi/cubits/timetable/timetable_cubit.dart';
import 'package:fiwi/cubits/timetable/timetable_state.dart';
import 'package:fiwi/view/timetable/streambuilder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<StatefulWidget> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  Box box = Hive.box('user');

  String? role;
  bool isEdit = false;
  bool isAdmin = false;
  bool simpleTimetable = true;

  _loadData() {
    role = box.get('role') ?? '';
    simpleTimetable = box.get('simpleTimetable') ?? true;
    if (role == 'admin') {
      isEdit = true;
      isAdmin = true;
    } else if (role == 'faculty') {
      isEdit = true;
      isAdmin = false;
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TimetableCubit, TimetableState>(
            listener: (context, state) {
          if (state is TimetableAddPeriodSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Class Created Successfully."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is TimetableEditPeriodSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Class Updated Successfully."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is TimetableDeletePeriodSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Class Deleted Successfully."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is TimetableErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ));
          }
        }),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: ListView(
          children: <Widget>[
            StreamBuilderWidget(
              day: 'Monday',
              dayInNum: '1',
              isEdit: isEdit,
              isAdmin: isAdmin,
              isSimpleTimetable: simpleTimetable,
            ),
            StreamBuilderWidget(
              day: 'Tuesday',
              dayInNum: '2',
              isEdit: isEdit,
              isAdmin: isAdmin,
              isSimpleTimetable: simpleTimetable,
            ),
            StreamBuilderWidget(
              day: 'WednesDay',
              dayInNum: '3',
              isEdit: isEdit,
              isAdmin: isAdmin,
              isSimpleTimetable: simpleTimetable,
            ),
            StreamBuilderWidget(
              day: 'Thursday',
              dayInNum: '4',
              isEdit: isEdit,
              isAdmin: isAdmin,
              isSimpleTimetable: simpleTimetable,
            ),
            StreamBuilderWidget(
              day: 'Friday',
              dayInNum: '5',
              isEdit: isEdit,
              isAdmin: isAdmin,
              isSimpleTimetable: simpleTimetable,
            ),
            StreamBuilderWidget(
              day: 'Satarday',
              dayInNum: '6',
              isEdit: isEdit,
              isAdmin: isAdmin,
              isSimpleTimetable: simpleTimetable,
            ),
          ],
        ),
      ),
    );
  }
}
