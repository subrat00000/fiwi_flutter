import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/qr/qr_cubit.dart';
import 'package:fiwi/cubits/qr/qr_state.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget {
  final String semester;
  final String datetime;
  final String session;
  final String subjectCode;
  final String subjectName;
  const QrScreen(
      {super.key,
      required this.datetime,
      required this.semester,
      required this.session,
      required this.subjectCode,
      required this.subjectName});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? dt;
  bool newSession = false;
  String? updatedt;

  @override
  void initState() {
    super.initState();
    dt = DateTime.now().microsecondsSinceEpoch.toString();
    updatedt = widget.datetime;
    BlocProvider.of<QrCubit>(context).initializeAttendance(widget.session,
        widget.semester, widget.subjectCode, widget.subjectName, updatedt!);
  }

  openDialogAppSettings() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                  'Location permission is permanently denied. Open App Setting...'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Geolocator.openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }
  openDialogLocationSettings() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                  'Location Service is disabled. Open Location Setting...'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Geolocator.openLocationSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          color: Colors.black54,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
          // width: double.infinity,
          color: Colors.white70,
          child: BlocConsumer<QrCubit, QrState>(
            listener: (context, state) {
              if (state is QrErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error.toString()),
                  backgroundColor: Colors.redAccent[400],
                  behavior: SnackBarBehavior.floating,
                ));
                Navigator.pop(context);
              } else if (state is QrLocationServiceErrorState) {
                Navigator.pop(context);
                openDialogLocationSettings();
              } else if (state is QrLocationPermissionErrorState) {
                Navigator.pop(context);
                openDialogAppSettings();
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                      Center(
                          child: state is AttendanceAlreadyInitialized
                              ? Center(
                                  child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      const Text(
                                          'Your previous session is not disposed yet. Click on Start New Session to start a new class or click Next to continue'),
                                      ElevatedButton(
                                          onPressed: () {
                                            BlocProvider.of<QrCubit>(context)
                                                .initializeAttendance(
                                                    widget.session,
                                                    widget.semester,
                                                    widget.subjectCode,
                                                    widget.subjectName,
                                                    dt!);
                                            setState(() {
                                              newSession = true;
                                              updatedt = dt;
                                            });
                                          },
                                          child:
                                              const Text('Start New Session')),
                                      QrImage(
                                        data: state.encryptedOldMessage,
                                        size: 400,
                                      )
                                    ],
                                  ),
                                ))
                              : state is PreSetupForAttendanceSuccessState
                                  ? QrImage(
                                      data: state.encryptedMessage,
                                      size: 400,
                                    )
                                  : Container()),
                    ],
                  ),
                  Positioned(
                    bottom:
                        20, // adjust the value to position the button as per your requirement
                    left: 20,
                    right: 20,
                    child: CustomButton(
                        text: 'Next',
                        borderRadius: 50,
                        icontext: false,
                        onPressed: () {
                          if (state is PreSetupForAttendanceSuccessState ||
                              state is AttendanceAlreadyInitialized) {
                            Navigator.pushNamed(context, '/studentattendance',
                                arguments: {
                                  'session': widget.session,
                                  'semester': widget.semester,
                                  'subject_code': widget.subjectCode,
                                  'subject_name': widget.subjectName,
                                  'datetime': updatedt
                                });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text(
                                  "Initialization is in progress. Please wait a second."),
                              backgroundColor: Colors.redAccent[400],
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        }),
                  ),
                ],
              );
            },
          )),
    );
  }
}
