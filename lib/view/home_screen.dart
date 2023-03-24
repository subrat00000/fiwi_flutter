import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiwi/cubits/auth/auth_cubit.dart';
import 'package:fiwi/cubits/auth/auth_state.dart';
import 'package:fiwi/cubits/home/home_cubit.dart';
import 'package:fiwi/cubits/home/home_state.dart';
import 'package:fiwi/cubits/internet_cubit.dart';
import 'package:fiwi/repositories/exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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
  int todayAsDay = 6;

  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    initInfo();

    // final databaseReference = FirebaseDatabase.instance.ref('timetable/sem1/sun');

    // final newChildData = [{
    //   'faculty': 'Nihar R. Nayak',
    //   'subject': 'DSA',
    //   'startTime': '09:00 am',
    //   'endTime': '10:00 am'
    // },{'faculty': 'P. K. Tripathy', 'startTime':'08:00 am','subject':'CSA', 'endTime':'09:00 am'}];
    // for(int i =0;i< newChildData.length;i++){
    //   final newChildRef = databaseReference.child(newChildData[i]['subject']!.toLowerCase()); // Get a reference to the new child
    //   newChildRef.set(newChildData[i]);
    // }
    // // Set the new child data
  }

  initInfo() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("*******************************onMessage*******************************");
      log("onMessage: ${message.notification!.title}/${message.notification!.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
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
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
  }

  var internet = true;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        return Exit().showExitDialog(context);
      },
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
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
                        child: CachedNetworkImage(
                          imageUrl: "http://via.placeholder.com/350x150",
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ),
              ),
            ),
            title: Row(
              children: <Widget>[
                SizedBox(
                  width: width * 0.23,
                ),
              ],
            ),
          ),
          key: _scaffoldKey,
          body: SafeArea(
              child: MultiBlocListener(
                  listeners: [
                BlocListener<InternetCubit, InternetState>(
                  listener: (context, state) {
                    if (state == InternetState.gained && internet == false) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Internet conntected"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ));
                      internet = true;
                    } else if (state == InternetState.lost) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
                    // TODO: implement listener
                  },
                ),
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
                  child: Column(
                    children: [
                      Card(
                        color: Colors.grey,
                        elevation: 6,
                        child: Column(children: <Widget>[
                          InkWell(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (BuildContext context) =>
                              //             TimeTable()));
                            },
                            child: const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Text(
                                      'Today\'s Time Table',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                  ),
                                )),
                          ),
                          (todayAsDay == 7)
                              ? Card(
                                  color: Colors.cyanAccent,
                                  elevation: 0,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height:
                                        150, //MediaQuery.of(context).size.height * 0.3,
                                    child: const Center(
                                      child: Text('Sunday is fun day',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                )
                              : Card(
                                  color: Colors.grey[350],
                                  elevation: 6,
                                  child: Column(children: <Widget>[
                                    Container(
                                      height:
                                          150, //MediaQuery.of(context).size.height * 0.3,
                                      child: StreamBuilder(
                                        stream: FirebaseDatabase.instance
                                            .ref('timetable/sem1/sun')
                                            .onValue,
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.data == null ||
                                              snapshot.data!.snapshot.value ==
                                                  null) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else {
                                            final itemsMap = snapshot
                                                .data!
                                                .snapshot
                                                .value as Map<dynamic, dynamic>;
                                            final itemsList =
                                                itemsMap.entries.toList();
                                            return ListView.builder(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              itemBuilder: (context, index) {
                                                return showPeriod(
                                                    context, itemsList[index]);
                                              },
                                              itemCount: itemsList.length,
                                              scrollDirection: Axis.horizontal,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ]),
                                ),
                        ]),
                      ),
                    ],
                  )))),
    );
  }

  Widget showPeriod(BuildContext context, document) {
    // DateTime showStartTime =
    //     DateTime.parse(document.value['startTime'].toDate().toString());
    // DateTime showEndTime =
    //     DateTime.parse(document.value['endTime'].toDate().toString());

    String showStartTime = document.value['startTime'].toString();
    String showEndTime = document.value['endTime'].toString();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 5),
      width: 220,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.fromLTRB(
          10.0, 5.0, 0.0, 5.0), //MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // myText(
              //    Colors.white,
              //   DateFormat.jm().format(showStartTime)
              // ),
              // myText(
              //    Colors.white,
              //   DateFormat.jm().format(showEndTime)
              // ),
              myText(Colors.black, showStartTime),
              myText(Colors.black, showEndTime),
            ],
          ),
          myText(
            Colors.black,
            document.value['sem'],
          ),
          myText(
            Colors.black,
            document.value['faculty'],
          ),
        ],
      ),
    );
  }

  Widget myText(tColor, textValue) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        textValue,
        style: TextStyle(color: tColor),
      ),
    );
  }
}
