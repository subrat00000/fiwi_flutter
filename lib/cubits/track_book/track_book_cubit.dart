import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/track_book/track_book_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class TrackBookCubit extends Cubit<TrackBookState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("library");
  var box = Hive.box('user');
  TrackBookCubit() : super(TrackBookInitialState());

  expressCheckout(bookId, bookStatus, {userId, userName}) async {
    emit(ExpressCheckoutLoadingState());
    try {
      DatabaseEvent book =
          await ref.child('track').child(userId).child(bookId).once();
      if (book.snapshot.exists) {
        emit(ExpressCheckoutBookAlreadyAllotedState());
      } else {
        String datetime = DateTime.now().millisecondsSinceEpoch.toString();
        await ref.child('track').child(userId).child(bookId).set({
          'user_id': userId,
          'book_id': bookId,
          'book_status': bookStatus,
          'issue_date': datetime,
          'borrow_date': datetime,
          'user_name': userName,
          'return_date': null
        });
        await ref
            .child('books')
            .child(bookId)
            .update({'quantity': ServerValue.increment(-1)});
        emit(ExpressCheckoutSuccessState());
      }
    } catch (e) {
      await ref.child('track').child(userId).child(bookId).remove();
      emit(TrackBookErrorState(e.toString()));
    }
  }
}
