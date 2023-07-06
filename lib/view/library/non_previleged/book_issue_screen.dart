import 'dart:developer';
import 'package:fiwi/cubits/book_issue/book_issue_cubit.dart';
import 'package:fiwi/cubits/book_issue/book_issue_state.dart';
import 'package:fiwi/cubits/manage_book/manage_book_cubit.dart';
import 'package:fiwi/cubits/manage_book/manage_book_state.dart';
import 'package:fiwi/models/book.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class BookIssueScreen extends StatefulWidget {
  const BookIssueScreen({super.key});

  @override
  State<BookIssueScreen> createState() => _BookIssueScreenState();
}

class _BookIssueScreenState extends State<BookIssueScreen> {
  Box box = Hive.box('user');
  late String userId;
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    userId = box.get('uid');
    List<Book> bookList =
        await BlocProvider.of<ManageBookCubit>(context).getBooks();
    bookList.sort((a, b) => a.bookName.compareTo(b.bookName));
    setState(() {
      books = bookList;
    });
  }

  _modalIssueBook(String userId, Book book) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Issue Book '),
              content: Text(
                  'Book Name: ${book.bookName}\nBook Category: ${book.bookCategory}\nBook Author: ${book.authorName}\nPublication: ${book.publication}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    BlocProvider.of<BookIssueCubit>(context)
                        .issueBook(userId, book.bookId);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Issue'),
                ),
              ],
            ));
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
          title: const Text(
            'Issue Book',
            style: TextStyle(color: Colors.black87, fontSize: 20),
            textAlign: TextAlign.start,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => _loadData(),
          child: BlocListener<BookIssueCubit, BookIssueState>(
              listener: (context, state) {
                if (state is BookIssueSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Book issued successfully."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                } else if (state is BookAlreadyIssueRequestDoneState) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Already request raised to issue book."),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ));
                } else if (state is BookAlreadyBorrowedState) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Book is already taken by you."),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ));
                } else if (state is BookIssueErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error.toString()),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              child: books.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                          onTap: () => _modalIssueBook(userId, books[index]),
                          title: Text(books[index].bookName),
                          subtitle: Text(
                              '${books[index].publication}(${books[index].authorName})'),
                          trailing: Text('Qty: ${books[index].quantity}'),
                        ));
                      })
                  : const Center(
                      child: CircularProgressIndicator(),
                    )),
        ));
  }
}
