import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/qr_book_return/qr_book_return_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class QrBookReturneCubit extends Cubit<QrBookReturnState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("users");
  var box = Hive.box('user');
  QrBookReturneCubit() : super(QrBookReturnInitialState());

  returnBookInitializeQr(Map trackBook) {
    try {
      

    } catch (e) {
      emit(QrBookReturnErrorState(e.toString()));
    }
  }
  returnBook(){
    try{

    }catch(e){
       emit(QrBookReturnErrorState(e.toString()));
    }
  }
}
