import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class QRBookReturnedScreen extends StatefulWidget {
  final Map trackBook;
  const QRBookReturnedScreen({super.key, required this.trackBook});

  @override
  State<QRBookReturnedScreen> createState() => QRBookReturnedScreenState();
}

class QRBookReturnedScreenState extends State<QRBookReturnedScreen> {
  Box box = Hive.box('user');
  final trackRef = FirebaseDatabase.instance.ref('library/track');
  StreamSubscription<DatabaseEvent>? _subscription;

  returnBookInitializeQr() {
    String datetime = DateTime.now().millisecondsSinceEpoch.toString();
    final key = encrypt.Key.fromUtf8(box.get('key'));
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));
    String jsonData = jsonEncode({'datetime':datetime,'book_id':widget.trackBook['book_id'],'user_id':widget.trackBook['user_id'],'action_type':'return'});

    final encrypted = encrypter.encrypt(jsonData, iv: iv);
    return encrypted.base64;
  }

  @override
  void initState() {
    super.initState();
    _subscription = trackRef
        .child(widget.trackBook['user_id'])
        .child(widget.trackBook['book_id'])
        .child('book_returned')
        .onValue
        .listen((DatabaseEvent event) {
      log(event.snapshot.value.toString());
      if (event.snapshot.value == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Book Status updated Successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
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
