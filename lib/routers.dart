import 'dart:developer';

import 'package:fiwi/view/admin/activate_student.dart';
import 'package:fiwi/view/admin/assign_faculty.dart';
import 'package:fiwi/view/admin/batch/show_batches.dart';
import 'package:fiwi/view/admin/batch/view_batch.dart';
import 'package:fiwi/view/admin/change_semester.dart';
import 'package:fiwi/view/admin/batch/create_batch.dart';
import 'package:fiwi/view/admin/delete_account.dart';
import 'package:fiwi/view/admin/manage_courses.dart';
import 'package:fiwi/view/admin/manage_role.dart';
import 'package:fiwi/view/attendance/manage_attendance_screen.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/notification_screen.dart';
import 'package:fiwi/view/profile/edit_profile_screen.dart';
import 'package:fiwi/view/profile/profile_screen.dart';
import 'package:fiwi/view/signin/create_user.dart';
import 'package:fiwi/view/signin/google_signin.dart';
import 'package:fiwi/view/signin/otp.dart';
import 'package:fiwi/view/signin/phone_signin.dart';
import 'package:fiwi/view/splash_screen.dart';
import 'package:fiwi/view/timetable/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import "package:fiwi/view/information.dart";

class Routers {
  static Route generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case '/splash':
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case '/googlesignin':
        return MaterialPageRoute(builder: (context) => const GoogleSignin());
      case '/phonesignin':
        return MaterialPageRoute(builder: (context) => const PhoneSignin());
      case '/otp':
        return MaterialPageRoute(builder: (context) => const Otp());
      case '/createuser':
        return MaterialPageRoute(builder: (context) => const CreateUser());
      case '/home':
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case '/profile':
        return PageTransition(
            child: const ProfileScreen(), type: PageTransitionType.leftToRight);
      case '/notification':
        return PageTransition(
            child: const NotificationScreen(),
            type: PageTransitionType.rightToLeft);
      case '/editprofile':
        return MaterialPageRoute(
            builder: (context) => const EditProfileScreen());
      case '/timetable':
        return MaterialPageRoute(builder: (context) => const TimeTable());
      case '/inactive':
        return MaterialPageRoute(builder: (context) => const Information());
      case '/managerole':
        return MaterialPageRoute(
            builder: (context) => const ManageRoleScreen());
      case '/managecourse':
        return MaterialPageRoute(
            builder: (context) => const ManageCourseScreen());
      case '/activatestudent':
        return MaterialPageRoute(
            builder: (context) => const ActivateStudentScreen());
      case '/deleteaccount':
        return MaterialPageRoute(
            builder: (context) => const DeleteAccountScreen());
      case '/changesemester':
        return MaterialPageRoute(
            builder: (context) => const ChangeSemesterScreen());
      case '/createbatch':
        return MaterialPageRoute(
            builder: (context) => const CreateBatchScreen());
      case '/showbatch':
        return MaterialPageRoute(builder: (context) => const ShowBatchScreen());
      case '/viewbatch':
        final itemsMap = setting.arguments as Map;
        String session = itemsMap['session'];
        List<String> uids = itemsMap['uids'];
        return MaterialPageRoute(
            builder: (context) =>
                ViewBatchScreen(session: session, uids: uids));
      case '/manageattendance':
        final args = setting.arguments;
        return MaterialPageRoute(
            builder: (context) => ManageAttendanceScreen(args));
      case '/assignfaculty':
        final args = setting.arguments;
        return MaterialPageRoute(
            builder: (context) => AssignFacultyScreen(args));
      default:
        return MaterialPageRoute(builder: (context) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Some thing went wrong!!!',
                style: TextStyle(color: Colors.red, fontSize: 30),
              ),
            ),
          );
        });
    }
  }
}
