import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/qrscan_book/qrscan_book_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class QrScanBookCubit extends Cubit<QrScanBookState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  var box = Hive.box('user');
  QrScanBookCubit() : super(QrScanBookInitialState());

  issueBook(qrValue) async {
    try {
      final key = encrypt.Key.fromUtf8(box.get('key'));
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key));

      final decrypted = encrypter.decrypt64(qrValue, iv: iv);
      final value = json.decode(decrypted);
      log(value['data'][0]);
    } catch (e) {
      emit(QrScanBookErrorState(e.toString()));
    }
  }
}
