import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/book_issue/book_issue_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class BookIssueCubit extends Cubit<BookIssueState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("library");
  var box = Hive.box('user');
  BookIssueCubit() : super(BookIssueInitialState());

  issueBook(String userId, String bookId) async {
    try {
      DatabaseEvent book =
          await ref.child('track').child(userId).child(bookId).once();
      if (book.snapshot.exists) {
        final data = Map<String, dynamic>.from(book.snapshot.value as Map);
        if (data['book_issue_request'] == true &&
            data['book_issued'] == false &&
            data['book_borrowed'] == false) {
          emit(BookAlreadyIssueRequestDoneState());
        } else if (data['book_issued'] == true &&
            data['book_borrowed'] == true) {
          emit(BookAlreadyBorrowedState());
        }
      } else {
        String datetime = DateTime.now().millisecondsSinceEpoch.toString();
        final postData = {
          'user_id': userId,
          'book_id': bookId,
          'book_issue_request': true,
          'book_issued': false,
          'book_borrowed': false,
          'book_returned': false,
          'book_issue_rejected': false,
          'issue_request_date': datetime,
          'issue_date': null,
          'borrow_date': null,
          'return_date': null
        };
        final Map<String, Object?> updates = {};
        updates['/track/$userId/$bookId'] = postData;
        updates['/track/$userId/last_update'] = datetime;
        updates['/track/$userId/user_id'] = userId;
        updates['/track/$userId/all_book_issued'] = false;
        await ref.update(updates);
        emit(BookIssueSuccessState());
      }
    } catch (e) {
      emit(BookIssueErrorState(e.toString()));
    }
  }
}
