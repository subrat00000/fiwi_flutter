import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/qr_book_return/qr_book_return_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class QRBookIssueScreen extends StatefulWidget {
  final List books;
  final String userId;
  const QRBookIssueScreen(
      {super.key, required this.books, required this.userId});

  @override
  State<QRBookIssueScreen> createState() => QRBookIssueScreenState();
}

class QRBookIssueScreenState extends State<QRBookIssueScreen> {
  Box box = Hive.box('user');
  final trackRef = FirebaseDatabase.instance.ref('library/track');
  StreamSubscription<DatabaseEvent>? _subscription;

  returnBookInitializeQr() {
    String datetime = DateTime.now().millisecondsSinceEpoch.toString();
    final key = encrypt.Key.fromUtf8(box.get('key'));
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));
    String jsonData = jsonEncode(
        {'datetime': datetime, 'data': widget.books, 'user_id': widget.userId});
    log(jsonData);

    final encrypted = encrypter.encrypt(jsonData, iv: iv);
    return encrypted.base64;
  }

  @override
  void initState() {
    super.initState();
    _subscription = trackRef
        .child(widget.userId)
        .child('all_book_issued')
        .onValue
        .listen((DatabaseEvent event) {
      log(event.snapshot.value.toString());
      if (event.snapshot.value == true) {
        trackRef
            .child(widget.userId)
            .update({'all_book_issued': false}).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Book Status updated Successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription!.cancel();
    super.dispose();
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
        title: Text(
          "Qr Book Return",
          style: const TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      body: Container(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            QrImage(
              data: returnBookInitializeQr(),
              size: 400,
            ),
          ],
        ),
      )),
    );
  }
}
