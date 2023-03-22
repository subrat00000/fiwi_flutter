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

  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    initInfo();
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
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthLoggedOutState) {
                  Navigator.pushNamed(context, '/splash');
                }
              },
              builder: (context, state) {
                return TextButton(
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).logOut();
                    },
                    child: const Text("Logout"));
              },
            ),
          ))),
    );
  }
}
