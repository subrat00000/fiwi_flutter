import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/view/admin/admin_screen.dart';
import 'package:fiwi/view/attendance/previleged/admin_attendance_screen.dart';
import 'package:fiwi/view/attendance/student/attendance_screen.dart';
import 'package:fiwi/view/attendance/previleged/faculty_attendance_screen.dart';
import 'package:fiwi/view/home_screen/admin_home_screen.dart';
import 'package:fiwi/view/home_screen/faculty_home_screen.dart';
import 'package:fiwi/view/home_screen/librarian_home_screen.dart';
import 'package:fiwi/view/home_screen/student_home_screen.dart';
import 'package:fiwi/view/library/non_previleged/library_screen.dart';
import 'package:fiwi/view/timetable/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  DatabaseReference ref = FirebaseDatabase.instance.ref('users');
  String? mtoken;
  Box box = Hive.box('user');
  Map<int, String> appBarTitle = {
    0: 'Home',
    1: 'Timetable',
    2: 'Attendance',
    3: 'Library',
    4: 'Admin Panel'
  };
  var internet = true;
  String? photo;
  String? vname;
  String? vbio;
  String? vsemester;
  String? vaddress;
  String? vemail;
  String? vphone;
  String? vbirthday;
  String? role;
  Timer? _timer;

  _loadData() async {
    setState(() {
      photo = box.get('photo') ?? '';
      vname = box.get('name') ?? '';
      vbio = box.get('bio') ?? '';
      vsemester = box.get('semester') ?? '';
      vaddress = box.get('address') ?? '';
      vemail = box.get('email') ?? '';
      vphone = box.get('phone') ?? '';
      vbirthday = box.get('birthday') ?? '';
      role = box.get('role') ?? '';
    });
    DataSnapshot ds = await ref.child(box.get('uid')).get();
    var value = ds.value as Map;
    box.put('semester', value['semester']);
    if (role == 'student') {
      await messaging
          .subscribeToTopic(vsemester!.toLowerCase().replaceAll(' ', ''));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    requestPermission();
    getToken();
    initInfo();
    // changeTopic();
    // getDataFromDatabase();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      BlocProvider.of<HomeCubit>(context).getAuthentication();
      // context.read<HomeCubit>().getAuthentication();
    });
    BlocProvider.of<HomeCubit>(context).getKey();
    // final databaseReference = FirebaseDatabase.instance.ref('timetable/semester1');

    // final data = [[{
    //   'faculty': 'Nihar R. Nayak',
    //   'subject': 'DSA',
    //   'startTime': '07:00 am',
    //   'endTime': '08:00 am'
    // },{
    //   'faculty': 'Sabita Behera',
    //   'subject': 'OODUU',
    //   'startTime': '08:00 am',
    //   'endTime': '09:00 am'
    // },{'faculty': 'P. K. Tripathy', 'startTime':'09:00 am','subject':'CSA', 'endTime':'10:00 am'}],[{
    //   'faculty': 'Subhalaxmi Das',
    //   'subject': 'DSI',
    //   'startTime': '07:00 am',
    //   'endTime': '08:00 am'
    // },{
    //   'faculty': 'Om Prakash Jena',
    //   'subject': 'DMS',
    //   'startTime': '08:00 am',
    //   'endTime': '09:00 am'
    // },{
    //   'faculty': 'Nihar R. Nayak',
    //   'subject': 'DSA',
    //   'startTime': '09:00 am',
    //   'endTime': '10:00 am'
    // }],[{
    //   'faculty': 'Nihar R. Nayak',
    //   'subject': 'DSA',
    //   'startTime': '07:00 am',
    //   'endTime': '08:00 am'
    // },{
    //   'faculty': 'Sabita Behera',
    //   'subject': 'OODUU',
    //   'startTime': '08:00 am',
    //   'endTime': '09:00 am'
    // },{'faculty': 'P. K. Tripathy', 'startTime':'09:00 am','subject':'CSA', 'endTime':'10:00 am'}],[{
    //   'faculty': 'Subhalaxmi Das',
    //   'subject': 'DSI',
    //   'startTime': '07:00 am',
    //   'endTime': '08:00 am'
    // },{
    //   'faculty': 'Om Prakash Jena',
    //   'subject': 'DMS',
    //   'startTime': '08:00 am',
    //   'endTime': '09:00 am'
    // },{'faculty': 'P. K. Tripathy', 'startTime':'09:00 am','subject':'CSA', 'endTime':'10:00 am'}],[{
    //   'faculty': 'Nihar R. Nayak',
    //   'subject': 'DSA',
    //   'startTime': '07:00 am',
    //   'endTime': '08:00 am'
    // },{
    //   'faculty': 'Sabita Behera',
    //   'subject': 'OODUU',
    //   'startTime': '08:00 am',
    //   'endTime': '09:00 am'
    // },{'faculty': 'P. K. Tripathy', 'startTime':'09:00 am','subject':'CSA', 'endTime':'10:00 am'}],[{
    //   'faculty': 'Subhalaxmi Das',
    //   'subject': 'DSI',
    //   'startTime': '07:00 am',
    //   'endTime': '08:00 am'
    // },{
    //   'faculty': 'Om Prakash Jena',
    //   'subject': 'DMS',
    //   'startTime': '08:00 am',
    //   'endTime': '09:00 am'
    // },{
    //   'faculty': 'Sabita Behera',
    //   'subject': 'OODUU',
    //   'startTime': '09:00 am',
    //   'endTime': '10:00 am'
    // }]];

    // for(int j=0;j<data.length;j++){
    // for(int i =0;i< data[j].length;i++){
    //   final newChildRef = databaseReference.child((j+1).toString()).child(data[j][i]['subject']!.toLowerCase()); // Get a reference to the new child
    //   newChildRef.set(data[j][i]);
    // }
    // }
    // Set the new child data
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    } // cancel the timer when the widget is disposed
    super.dispose();
  }

  initInfo() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("*******************************onMessage*******************************");
      log("onMessage: ${message.notification!.title}/${message.notification!.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          summaryText: message.data['summary'].toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContentTitle: true);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('id', 'fiwi',
              importance: Importance.max,
              styleInformation: bigTextStyleInformation,
              priority: Priority.max,
              playSound: true);
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
      List notification = [];
      notification = box.get('notification') ?? [];
      notification.insert(0, {
        'body': message.notification!.body.toString(),
        'title': message.notification!.title.toString(),
        'dateTime': message.data['dateTime'].toString()
      });
      box.put('notification', notification);
    });
  }

  void getToken() async {
    await messaging.getToken().then((token) {
      setState(() {
        mtoken = token;
      });
      if (box.get('token') != token) {
        saveToken();
        box.put('token', token);
      }
      log(token!);
    });
  }

  void saveToken() async {
    final userToken = {
      'mtoken': mtoken,
    };
    await ref.child(_auth.currentUser!.uid).update(userToken);
  }

  void requestPermission() async {
    await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
  }

  final _pageNavigationAdmin = [
    const AdminHomeScreen(),
    const TimeTable(),
    const AdminAttendanceScreen(),
    const LibrarianHomeScreen(),
    const AdminScreen()
  ];
  final _pageNavigationStudent = [
    const StudentHomeScreen(),
    const TimeTable(),
    const AttendanceScreen(),
    const LibraryScreen(),
  ];
  final _pageNavigationFaculty = [
    const FacultyHomeScreen(),
    const TimeTable(),
    const FacultyAttendanceScreen(),
    const LibraryScreen(),
  ];
  final _pageNavigationLibrarian = [
    const LibrarianHomeScreen(),
  ];

  Widget _buildBottomNav() {
    return SizedBox(
      height: 50,
      child: role!='librarian'? BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(fontSize: 13),
        currentIndex: context.read<BottomNavCubit>().state,
        type: BottomNavigationBarType.fixed,
        onTap: _getChangeBottomNav,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset('assets/home.png', cacheHeight: 17),
              label: 'Home',
              activeIcon: Image.asset('assets/home.png', cacheHeight: 22)),
          if (role != 'librarian')
            BottomNavigationBarItem(
                icon: Image.asset('assets/timetables.png', cacheHeight: 17),
                label: 'Timetable',
                activeIcon:
                    Image.asset('assets/timetables.png', cacheHeight: 22)),
          if (role != 'librarian')
            BottomNavigationBarItem(
                icon: Image.asset('assets/attendances.png', cacheHeight: 17),
                label: 'Attendance',
                activeIcon:
                    Image.asset('assets/attendances.png', cacheHeight: 22)),
          if (role != 'librarian')
          BottomNavigationBarItem(
              icon: Image.asset('assets/librarys.png', cacheHeight: 17),
              label: 'Library',
              activeIcon: Image.asset('assets/librarys.png', cacheHeight: 22)),
          if (role == 'admin')
            BottomNavigationBarItem(
                icon: Image.asset('assets/admin.png', cacheHeight: 17),
                label: 'Admin Panel',
                activeIcon: Image.asset('assets/admin.png', cacheHeight: 22)),
        ],
      ):Container(),
    );
  }

  void _getChangeBottomNav(int index) {
    context.read<BottomNavCubit>().updateIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Repositories().showExitDialog(context);
      },
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, state) {
          return Scaffold(
              bottomNavigationBar: _buildBottomNav(),
              appBar: AppBar(
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/notification');
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black54,
                      ))
                ],
                leading: Transform.translate(
                  offset: const Offset(10, 0),
                  child: Container(
                    margin: const EdgeInsets.all(6.5),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.001, 0.001), //(x,y)
                        blurRadius: 0.05,
                      ),
                    ], shape: BoxShape.circle),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                            ),
                          ], shape: BoxShape.circle),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            child: photo != null && photo != ''
                                ? CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: photo!,
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  )
                                : Image.asset('assets/no_image.png'),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ),
                  ),
                ),
                title: Center(
                    child: Text(
                  appBarTitle[context.read<BottomNavCubit>().state]!,
                  style: const TextStyle(color: Colors.black87),
                )),
              ),
              key: _scaffoldKey,
              body: SafeArea(
                  child: MultiBlocListener(
                      listeners: [
                    BlocListener<InternetCubit, InternetState>(
                      listener: (context, state) {
                        if (state == InternetState.gained &&
                            internet == false) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Internet conntected"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ));
                          internet = true;
                        } else if (state == InternetState.lost) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("No Internet Connection found"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                          internet = false;
                        }
                      },
                    ),
                    BlocListener<HomeCubit, HomeState>(
                      listener: (context, state) {
                        if (state is UserInactiveState) {
                          BlocProvider.of<AuthCubit>(context).logOut();
                        } else if (state is ErrorState) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(state.error.toString()),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                    ),
                    BlocListener<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthLoggedOutState) {
                          Navigator.pushReplacementNamed(context, '/splash');
                        }
                      },
                    )
                  ],
                      // child: BlocConsumer<AuthCubit, AuthState>(
                      //   listener: (context, state) {
                      //     if (state is AuthLoggedOutState) {
                      //       Navigator.pushNamed(context, '/splash');
                      //     }
                      //   },
                      //   builder: (context, state) {
                      //     return TextButton(
                      //         onPressed: () {
                      //           BlocProvider.of<AuthCubit>(context).logOut();
                      //         },
                      //         child: const Text("Logout"));
                      //   },
                      // ),
                      child: role == 'admin'
                          ? _pageNavigationAdmin.elementAt(state)
                          : role == 'faculty'
                              ? _pageNavigationFaculty.elementAt(state)
                              : role == 'librarian'
                                  ? _pageNavigationLibrarian.elementAt(state)
                                  : _pageNavigationStudent.elementAt(state))));
        },
      ),
    );
  }
}
