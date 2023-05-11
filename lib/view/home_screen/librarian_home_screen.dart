import 'dart:developer';

import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:fiwi/cubits/change_semester/change_semester_cubit.dart';
import 'package:fiwi/models/chartdata.dart';
import 'package:fiwi/models/timetable.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LibrarianHomeScreen extends StatefulWidget {
  const LibrarianHomeScreen({super.key});

  @override
  State<LibrarianHomeScreen> createState() => LibrarianHomeScreenState();
}

class LibrarianHomeScreenState extends State<LibrarianHomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode book = FocusNode();
  FocusNode student = FocusNode();
  final bookRef = FirebaseDatabase.instance.ref('library');
  final userRef = FirebaseDatabase.instance.ref('users');
  List<Map<dynamic, dynamic>> booksList = [];
  List<Map<dynamic,dynamic>> userList = [];
  String selectedBook = '';
  String selectedStudent = '';

  void _searchBooks(String searchText) {
    bookRef
        .orderByChild("book_name")
        .startAt(searchText)
        .endAt(searchText + "\uf8ff")
        .once()
        .then((snapshot) {
      booksList.clear();
      if (snapshot.snapshot.exists) {
        var values = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        if (values.isNotEmpty) {
          values.forEach((key, value) {
            booksList.add(value);
          });
        }
        setState(() {});
      }
      setState(() {});
    });
  }
  void _searchStudent(String searchText) {
    userRef
        .orderByChild("name")
        .startAt(searchText)
        .endAt(searchText + "\uf8ff")
        .once()
        .then((snapshot) {
      userList.clear();
      if (snapshot.snapshot.exists) {
        var values = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        if (values.isNotEmpty) {
          values.forEach((key, value) {
            userList.add(value);
          });
        }
        setState(() {});
      }
      setState(() {});
    });
  }

  Widget float1() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, '/borrowedbook'),
      heroTag: "student_borrowed",
      tooltip: 'Student Borrowed',
      child: Image.asset(
        'assets/borrow.png',
        cacheHeight: 35,
      ),
    );
  }

  Widget float2() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/addbooks'),
      heroTag: "books",
      tooltip: 'Books',
      child: const Icon(Icons.menu_book_rounded),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
        onTap: () {
          setState(() {
            book.unfocus();
            student.unfocus();
          });
          log(book.hasFocus.toString());
          log(book.hasPrimaryFocus.toString());
        },
        child: Scaffold(
            floatingActionButton: AnimatedFloatingActionButton(
              animatedIconData: AnimatedIcons.menu_close,
              curve: Curves.easeInCubic,
              durationAnimation: 200,
              fabButtons: <Widget>[float1(), float2()],
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                        child: Text(
                      'Accept Book Issue',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    )),
                    const SizedBox(height: 20),
                    selectedBook == ''
                        ? TextField(
                            // autofocus: true,
                            focusNode: book,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Book Name',
                            ),
                            onChanged: (value) => _searchBooks(value),
                          )
                        : Text(selectedBook),
                    book.hasFocus
                        ? Card(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: booksList.length,
                              itemBuilder: (BuildContext context, int index) {
                                log(booksList[index].toString());
                                return ListTile(
                                  title: Text(booksList[index]["book_name"]),
                                  subtitle:
                                      Text(booksList[index]["author_name"]),
                                  onTap: () {
                                    setState(() {
                                      book.unfocus();
                                      selectedBook = 'Book Name: ${booksList[index]['book_name']}\nCategory: ${booksList[index]['book_category']}\nAuthor: ${booksList[index]['author_name']}\nPublication: ${booksList[index]['publication']}\nLocation: ${booksList[index]['book_location']}\nQuantity: ${booksList[index]['quantity']}';
                                    });
                                  },
                                );
                              },
                            ),
                          )
                        : Container(),
                        TextField(
                            // autofocus: true,
                            focusNode: student,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black12),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Issuer Name',
                            ),
                            onChanged: (value) => _searchStudent(value),
                          ),
                          // SizedBox(height: 400,),
                          student.hasFocus
                        ? Card(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: userList.length,
                              itemBuilder: (BuildContext context, int index) {
                                log(userList[index].toString());
                                return ListTile(
                                  title: Text(userList[index]["name"]),
                                  subtitle:
                                      Text(userList[index]["role"]),
                                  onTap: () {
                                    setState(() {
                                      student.unfocus();
                                      // selectedStudent = 'Book Name: ${booksList[index]['book_name']}\nCategory: ${booksList[index]['book_category']}\nAuthor: ${booksList[index]['author_name']}\nPublication: ${booksList[index]['publication']}\nLocation: ${booksList[index]['book_location']}\nQuantity: ${booksList[index]['quantity']}';
                                    });
                                  },
                                );
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            )));
  }
}
