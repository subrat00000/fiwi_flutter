import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/track_book/track_book_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class TrackBookCubit extends Cubit<TrackBookState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("library");
  var box = Hive.box('user');
  TrackBookCubit() : super(TrackBookInitialState());

  expressCheckout(bookId, {userId, userName}) async {
    emit(ExpressCheckoutLoadingState());
    try {
      DatabaseEvent book =
          await ref.child('track').child(userId).child(bookId).once();
      if (book.snapshot.exists) {
        emit(ExpressCheckoutBookAlreadyAllotedState());
      } else {
        String datetime = DateTime.now().millisecondsSinceEpoch.toString();
        final postData = {
          'user_id': userId,
          'book_id': bookId,
          'book_issue_request': true,
          'book_issued': true,
          'book_borrowed':true,
          'book_returned':false,
          'book_issue_rejected':false,
          'issue_request_date':datetime,
          'issue_date': datetime,
          'borrow_date': datetime,
          'user_name': userName,
          'return_date': null
        };
        final Map<String, Object?> updates = {};
        updates['/track/$userId/$bookId'] = postData;
        updates['/track/$userId/last_update'] = datetime;
        updates['/track/$userId/user_id']= userId;
        updates['/books/$bookId/quantity'] = ServerValue.increment(-1);
        await ref.update(updates);
        emit(ExpressCheckoutSuccessState());
      }
    } catch (e) {
      emit(TrackBookErrorState(e.toString()));
    }
  }
  rejectBook(String userId,String bookId)async{
    try{
      await ref.child('track').child(userId).child(bookId).update({'book_issue_rejected':true});
      emit(RejectIssueBookSuccessState());
    }catch(e){
      emit(TrackBookErrorState(e.toString()));
    }
  }
}
