import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_book/manage_book_state.dart';
import 'package:fiwi/models/book.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ManageBookCubit extends Cubit<ManageBookState> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("library");
  var box = Hive.box('user');
  ManageBookCubit() : super(ManageBookInitialState());

  addBook(bookName, bookCategory, authorName, publication, isbn, bookLocation,
      quantity) async {
    try {
      final newChildRef = ref.child('books').push();
      await newChildRef.set({
        'book_name': bookName,
        'book_category': bookCategory,
        'author_name': authorName,
        'publication': publication,
        'isbn': isbn,
        'book_location': bookLocation,
        'quantity': quantity,
        'id': newChildRef.key
      });
      emit(AddBookSuccessState());
    } catch (e) {
      emit(ManageBookErrorState(e.toString()));
    }
  }

  updateBook(bookName, bookCategory, authorName, publication, isbn,
      bookLocation, quantity, childKey) async {
    try {
      await ref.child('books').child(childKey).update({
        'book_name': bookName,
        'book_category': bookCategory,
        'author_name': authorName,
        'publication': publication,
        'isbn': isbn,
        'book_location': bookLocation,
        'quantity': quantity,
        'id': childKey
      });
      emit(UpdateBookSuccessState());
    } catch (e) {
      emit(ManageBookErrorState(e.toString()));
    }
  }

  getBooks() async {
    DatabaseEvent books = await ref.child('books').once();
    if (books.snapshot.exists) {
      final itemsMap = books.snapshot.value as Map;
      final itemsList = itemsMap.values.toList();
      List<Book> a = itemsList
          .map((e) => Book(
              authorName: e['author_name'],
              bookCategory: e['book_category'],
              bookLocation: e['book_location'],
              bookName: e['book_name'],
              publication: e['publication'],
              quantity: e['quantity'],
              bookId: e['id'],
              isbn: e['isbn']))
          .toList();
      return a;
    } else {
      return <Book>[];
    }
  }

  deleteBook(childKey) async {
    try {
      await ref.child('books').child(childKey).remove();
      emit(DeleteBookSuccessState());
    } catch (e) {
      emit(ManageBookErrorState(e.toString()));
    }
  }
}
