import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/qrscan_book/qrscan_book_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class QrScanBookCubit extends Cubit<QrScanBookState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("library");
  var box = Hive.box('user');
  QrScanBookCubit() : super(QrScanBookInitialState());
  issueOrReturnBook(qrValue) async {
    try {
      String datetime = DateTime.now().millisecondsSinceEpoch.toString();
      String uid = box.get('uid');
      final key = encrypt.Key.fromUtf8(box.get('key'));
      final iv = IV.fromLength(16);

      final encrypter = Encrypter(AES(key));

      final decrypted = encrypter.decrypt64(qrValue, iv: iv);
      final value = jsonDecode(decrypted);
      if (value['user_id'] == uid) {
        if (value['action_type'] == 'issue') {
          Map<String, Object?> updates = {};
          for (String i in value['data']) {
            updates["track/$uid/$i/book_issued"] = true;
            updates["track/$uid/$i/book_borrowed"] = true;
            updates["books/$i/quantity"]=ServerValue.increment(-1);
          }
          updates["track/$uid/last_update"]=datetime;
          updates["track/$uid/all_book_issued"] = true;
          await ref.update(updates);
          emit(QrScanBookIssueSuccessState());
        } else if(value['action_type']=='return'){
          String bookId = value['book_id'];
          Map<String, Object?> updates = {};
          updates["track/$uid/$bookId/book_returned"]=true;
          updates["track/$uid/last_update"]=datetime;
          updates["books/$bookId/quantity"]=ServerValue.increment(1);
          await ref.update(updates);
          emit(QrScanReturnBookSuccessState());
        }
      } else {
        emit(QrScanBookInvalidUserState());
      }

      log(value.toString());
    } catch (e) {
      emit(QrScanBookErrorState(e.toString()));
    }
  }
}
