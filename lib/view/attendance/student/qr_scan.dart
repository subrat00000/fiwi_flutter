import 'dart:developer';
import 'dart:typed_data';

import 'package:fiwi/cubits/student_attendance/attendance_cubit.dart';
import 'package:fiwi/cubits/student_attendance/attendance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  State<QrScan> createState() => _QrScan();
}

class _QrScan extends State<QrScan> {
  bool isQrCode = true;
  MobileScannerController cameraController = MobileScannerController();
  String? message;
  String? error;

  @override
  void initState() {
    super.initState();
    cameraController.stop();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.stop();
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
        ),
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
      ),
      body: BlocConsumer<StudentAttendanceCubit, StudentAttendanceState>(
        listener: (context, state) {
          if (state is StudentAttendanceSuccessState) {
            message = state.data.toString();
          } else if (state is StudentAttendanceErrorState) {
            error = state.error.toString();
          } else if (state is StudentLocationPermissionErrorState) {
            openDialogAppSettings();
          } else if (state is StudentLocationServiceErrorState) {
            openDialogLocationSettings();
          }
        },
        builder: (context, state) {
          return Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              width: 300,
              height: 300,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: error == null
                  ? message == null
                      ? isQrCode
                          ? MobileScanner(
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  if (isQrCode) {
                                    log('Barcode 3! ${barcode.rawValue}');
                                    BlocProvider.of<StudentAttendanceCubit>(
                                            context)
                                        .submitAttendance(barcode.rawValue!);
                                    setState(() {
                                      isQrCode = false;
                                    });
                                  }
                                }
                              },
                              controller: cameraController)
                          : const Center(child: CircularProgressIndicator())
                      : Center(
                          child: Text(
                          message.toString(),
                          style: TextStyle(color: Colors.green, fontSize: 17),
                        ))
                  : Center(
                      child: Text(
                      error.toString(),
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 17),
                    )),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            (message == null && error == null)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Colors.black45,
                        icon: ValueListenableBuilder(
                          valueListenable: cameraController.cameraFacingState,
                          builder: (context, state, child) {
                            switch (state) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => cameraController.switchCamera(),
                      ),
                      IconButton(
                        color: Colors.black87,
                        icon: ValueListenableBuilder(
                          valueListenable: cameraController.torchState,
                          builder: (context, state, child) {
                            switch (state) {
                              case TorchState.off:
                                return const Icon(Icons.flash_off,
                                    color: Colors.grey);
                              case TorchState.on:
                                return const Icon(Icons.flash_on,
                                    color: Colors.yellow);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () {
                          cameraController.toggleTorch();
                        },
                      ),
                    ],
                  )
                : Container(),
          ]);
        },
      ),
    );
  }
}
