import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_state.dart';
import 'package:fiwi/cubits/manage_book/manage_book_state.dart';
import 'package:fiwi/cubits/delete_account/delete_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ManageBookCubit extends Cubit<ManageBookState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("library");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var box = Hive.box('user');
  ManageBookCubit() : super(ManageBookInitialState());

  addBook(bookName, bookCategory, authorName, publication, isbn, bookLocation,
      quantity) async {
    try {
      final newChildRef = ref.push();
      await newChildRef.set({
        'book_name': bookName,
        'book_category': bookCategory,
        'author_name': authorName,
        'publication': publication,
        'isbn': isbn,
        'book_location': bookLocation,
        'quantity': quantity,
        'key': newChildRef.key
      });
      emit(AddBookSuccessState());
    } catch (e) {
      emit(ManageBookErrorState(e.toString()));
    }
  }

  updateBook(bookName, bookCategory, authorName, publication, isbn,
      bookLocation, quantity, childKey) async {
    try {
      await ref.child(childKey).update({
        'book_name': bookName,
        'book_category': bookCategory,
        'author_name': authorName,
        'publication': publication,
        'isbn': isbn,
        'book_location': bookLocation,
        'quantity': quantity,
        'key': childKey
      });
      emit(UpdateBookSuccessState());
    } catch (e) {
      emit(ManageBookErrorState(e.toString()));
    }
  }

  getBooks() async {
    DatabaseEvent books = await ref.once();
    if (books.snapshot.exists) {
      return Map<String, dynamic>.from(books.snapshot.value as Map)
          .values
          .toList();
    } else {
      return [];
    }
  }

  deleteBook(childKey) async {
    try {
      await ref.child(childKey).remove();
      emit(DeleteBookSuccessState());
    } catch (e) {
      emit(ManageBookErrorState(e.toString()));
    }
  }
}
