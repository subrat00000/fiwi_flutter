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
import 'package:fiwi/view/attendance/previleged/attendance_report.dart';
import 'package:fiwi/view/attendance/previleged/manage_attendance_screen.dart';
import 'package:fiwi/view/attendance/previleged/qr_screen.dart';
import 'package:fiwi/view/attendance/previleged/student_attendance.dart';
import 'package:fiwi/view/attendance/student/qr_scan.dart';
import 'package:fiwi/view/home_screen.dart';
import 'package:fiwi/view/library/non_previleged/book_issue_screen.dart';
import 'package:fiwi/view/library/non_previleged/qrscan_book_manage.dart';
import 'package:fiwi/view/library/previleged/accept_issue_request.dart';
import 'package:fiwi/view/library/previleged/borrow_book.dart';
import 'package:fiwi/view/library/previleged/borrow_book_details.dart';
import 'package:fiwi/view/library/previleged/express_checkout.dart';
import 'package:fiwi/view/library/previleged/manage_book.dart';
import 'package:fiwi/view/library/previleged/qr_book_issue.dart';
import 'package:fiwi/view/library/previleged/qr_book_returned.dart';
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
      case '/addbooks':
        return MaterialPageRoute(
            builder: (context) => const AddBookScreen());
      case '/qrscan':
        return MaterialPageRoute(
            builder: (context) => const QrScan());
      case '/borrowedbook':
        return MaterialPageRoute(
            builder: (context) => const BorrowBookScreen());
      case '/bookissue':
        return MaterialPageRoute(
            builder: (context) => const BookIssueScreen());
      case '/qrscanbookmanage':
        return MaterialPageRoute(
            builder: (context) => const QrScanBookManage());
      case '/expresscheckout':
        return MaterialPageRoute(
            builder: (context) => const ExpressCheckoutScreen());
      case '/qrbookreturned':
      final itemsMap = setting.arguments as Map;
        return MaterialPageRoute(
            builder: (context) => QRBookReturnedScreen(trackBook:itemsMap));
      case '/qrbookissue':
      final itemsMap = setting.arguments as Map;
        return MaterialPageRoute(
            builder: (context) => QRBookIssueScreen(books: itemsMap['books'],userId: itemsMap['user_id'],));
      case '/borrowedbookdetails':
        final itemsMap = setting.arguments as Map;
        return MaterialPageRoute(
            builder: (context) => BorrowBookDetailsScreen(data:itemsMap));
      case '/acceptissuerequest':
        final itemsMap = setting.arguments as Map;
        return MaterialPageRoute(
            builder: (context) => AcceptIssueRequestScreen(data:itemsMap));
      case '/attendancereport':
        final itemsMap = setting.arguments as Map;
        String session = itemsMap['session'];
        String semester = itemsMap['semester'];
        String subjectCode = itemsMap['subject_code'];
        String subjectName = itemsMap['subject_name'];
        return MaterialPageRoute(
            builder: (context) => AttendanceReportScreen(session:session,semester:semester,subjectCode:subjectCode,subjectName: subjectName));
      case '/studentattendance':
        final itemsMap = setting.arguments as Map;
        String session = itemsMap['session'];
        String semester = itemsMap['semester'];
        String subjectCode = itemsMap['subject_code'];
        String subjectName = itemsMap['subject_name'];
        String dt = itemsMap['datetime'];
        return MaterialPageRoute(
            builder: (context) => StudentAttendanceScreen(session:session,semester:semester,subjectCode:subjectCode,subjectName: subjectName,datetime:dt));
      case '/qrscreen':
        final itemsMap = setting.arguments as Map;
        String session = itemsMap['session'];
        String semester = itemsMap['semester'];
        String subjectCode = itemsMap['subject_code'];
        String subjectName = itemsMap['subject_name'];
        String dt = itemsMap['datetime'];
        return MaterialPageRoute(
            builder: (context) => QrScreen(
                  session:session,semester:semester,subjectCode:subjectCode,subjectName: subjectName,datetime:dt
                ));
      case '/createbatch':
        String session = '';
        List<String> uids = [];
        if (setting.arguments != null) {
          final itemsMap = setting.arguments as Map;
          session = itemsMap['session'];
          uids = itemsMap['uids'];
        }

        return MaterialPageRoute(
            builder: (context) =>
                CreateBatchScreen(session: session, uids: uids));
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
        final itemsMap = setting.arguments as Map;
        String semester = itemsMap['semester'];
        String subjectCode = itemsMap['subject_code'];
        String subjectName = itemsMap['subject_name'];
        return MaterialPageRoute(
            builder: (context) => ManageAttendanceScreen(semester:semester,subjectCode:subjectCode,subjectName:subjectName));
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
