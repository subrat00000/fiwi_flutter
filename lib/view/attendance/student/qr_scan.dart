import 'dart:developer';
import 'dart:typed_data';

import 'package:fiwi/cubits/student_attendance/attendance_cubit.dart';
import 'package:fiwi/cubits/student_attendance/attendance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  State<QrScan> createState() => _QrScan();
}

class _QrScan extends State<QrScan> {
  bool isQrCode = true;
  MobileScannerController cameraController = MobileScannerController();

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
      body: BlocListener<StudentAttendanceCubit, StudentAttendanceState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        child: Column( children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.2,),
          Container(
            clipBehavior: Clip.hardEdge,
            width: 300,
            height: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: isQrCode? MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (isQrCode) {
                      log('Barcode 3! ${barcode.rawValue}');
                      BlocProvider.of<StudentAttendanceCubit>(context).submitAttendance(barcode.rawValue!);
                      setState(() {
                        isQrCode = false;
                      });
                    }
                  }
                },
                controller: cameraController):const Center(child: CircularProgressIndicator()),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
          Row(
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
                        return const Icon(Icons.flash_off, color: Colors.grey);
                      case TorchState.on:
                        return const Icon(Icons.flash_on, color: Colors.yellow);
                    }
                  },
                ),
                iconSize: 32.0,
                onPressed: () {
                  cameraController.toggleTorch();
                },
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
