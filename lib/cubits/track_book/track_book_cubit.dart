import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/track_book/track_book_state.dart';
import 'package:fiwi/models/book.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class TrackBookCubit extends Cubit<TrackBookState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("library");
  var box = Hive.box('user');
  TrackBookCubit() : super(TrackBookInitialState());

  expressCheckout(){
    
  }


}
