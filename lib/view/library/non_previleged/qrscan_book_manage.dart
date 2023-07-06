import 'dart:developer';
import 'package:fiwi/cubits/qrscan_book/qrscan_book_cubit.dart';
import 'package:fiwi/cubits/qrscan_book/qrscan_book_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanBookManage extends StatefulWidget {
  const QrScanBookManage({super.key});

  @override
  State<QrScanBookManage> createState() => _QrScanBookManageState();
}

class _QrScanBookManageState extends State<QrScanBookManage> {
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
          'QR Book Issue',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
      ),
      body: BlocConsumer<QrScanBookCubit, QrScanBookState>(
        listener: (context, state) {
          if (state is QrScanBookIssueSuccessState) {
            message = "Books are issued successfully and You can take the books.";
          } else if (state is QrScanReturnBookSuccessState) {
            message = "Book returned successfully.";
          } else if (state is QrScanBookInvalidUserState) {
            error = "Invalid Qr Code.";
          }else if (state is QrScanBookErrorState) {
            error = state.error.toString();
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
                                    BlocProvider.of<QrScanBookCubit>(
                                            context)
                                        .issueOrReturnBook(barcode.rawValue!);
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
                          style: const TextStyle(color: Colors.green, fontSize: 17),
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
