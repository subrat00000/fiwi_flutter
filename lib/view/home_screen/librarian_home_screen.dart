import 'dart:developer';

import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class LibrarianHomeScreen extends StatefulWidget {
  const LibrarianHomeScreen({super.key});

  @override
  State<LibrarianHomeScreen> createState() => LibrarianHomeScreenState();
}

@immutable
class User {
  const User({required this.photo, required this.name, required this.uid});

  final String photo;
  final String name;
  final String uid;
}

class LibrarianHomeScreenState extends State<LibrarianHomeScreen> {
  TextEditingController userController = TextEditingController();
  FocusNode book = FocusNode();
  FocusNode student = FocusNode();
  final bookRef = FirebaseDatabase.instance.ref('library');
  final userRef = FirebaseDatabase.instance.ref('users');
  List<Map<dynamic, dynamic>> booksList = [];
  List<Map<dynamic, dynamic>> userList = [];
  String selectedBook = '';
  List<User> _userOptions = [];
  String? selectedPhoto;
  String? selectedName;
  String? selectedUid;
  static String _displayStringForOption(User option) => option.name;

  @override
  void initState() {
    super.initState();

    getUser();
  }

  void _searchBooks(String searchText) {
    bookRef
        .orderByChild("book_name")
        .startAt(searchText)
        .endAt("$searchText\uf8ff")
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

  void getUser() async {
    DatabaseEvent users = await userRef.once();
    final itemsMap = users.snapshot.value as Map;
    final itemsList = itemsMap.values.toList();
    final a = itemsList
        .map((e) => User(
              uid: e['uid'],
              name: e['name'],
              photo: e['photo'] ?? '',
            ))
        .toList();
    setState(() {
      _userOptions = a;
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
                                      selectedBook =
                                          'Book Name: ${booksList[index]['book_name']}\nCategory: ${booksList[index]['book_category']}\nAuthor: ${booksList[index]['author_name']}\nPublication: ${booksList[index]['publication']}\nLocation: ${booksList[index]['book_location']}\nQuantity: ${booksList[index]['quantity']}';
                                    });
                                  },
                                );
                              },
                            ),
                          )
                        : Container(),
                    selectedUid == null
                        ? Autocomplete<User>(
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 7.0,
                                  child: Container(
                                    color: Colors.white,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(10.0),
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final User option =
                                            options.elementAt(index);
                                        if (options.length - 1 != index) {
                                          return GestureDetector(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child: ListTile(
                                              leading: Container(
                                                width: 55,
                                                height: 55,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: option.photo != ''
                                                    ? CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl: option.photo,
                                                        progressIndicatorBuilder: (context,
                                                                url,
                                                                downloadProgress) =>
                                                            CircularProgressIndicator(
                                                                value: downloadProgress
                                                                    .progress),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                      )
                                                    : Image.asset(
                                                        'assets/no_image.png'),
                                              ),
                                              title: Text(option.name,
                                                  style: const TextStyle(
                                                      color: Colors.black87)),
                                            ),
                                          );
                                        } else {
                                          return GestureDetector(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child: ListTile(
                                              leading: Container(
                                                width: 55,
                                                height: 55,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Image.asset(
                                                        'assets/no_image.png'),
                                              ),
                                              title: Text(
                                                  "${option.name} (new)",
                                                  style: const TextStyle(
                                                      color: Colors.black87)),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              student = focusNode;
                              userController = textEditingController;
                              return TextField(
                                onSubmitted: (value) => onFieldSubmitted,
                                focusNode: student,
                                controller: userController,
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
                              );
                            },
                            displayStringForOption: _displayStringForOption,
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable.empty();
                              } else {
                                var a = _userOptions.where((User option) {
                                  return option.name
                                      .toString()
                                      .toLowerCase()
                                      .contains(
                                          textEditingValue.text.toLowerCase());
                                }).toList();
                                a.add(User(
                                    photo: '',
                                    name: toCamelCaseWithSpace(
                                        userController.text),
                                    uid: ''));

                                log(a.length.toString());
                                return a;
                              }
                            },
                            onSelected: (User selection) {
                              setState(() {
                                selectedPhoto = selection.photo;
                                selectedName = selection.name;
                                selectedUid = selection.uid;
                              });
                              debugPrint('You just selected ${selection.name}');
                            },
                          )
                        : ListTile(
                            title: Text(selectedName!),
                            leading: Container(
                              width: 55,
                              height: 55,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: selectedPhoto != ''
                                  ? CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: selectedPhoto!,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : Image.asset('assets/no_image.png'),
                            ),
                          ),
                    CustomButton(
                      text: 'Submit',
                      onPressed: () {},
                      icontext: false,
                    )
                  ],
                ),
              ),
            )));
  }
}
