import 'dart:developer';

import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/manage_book/manage_book_cubit.dart';
import 'package:fiwi/cubits/track_book/track_book_cubit.dart';
import 'package:fiwi/cubits/track_book/track_book_state.dart';
import 'package:fiwi/models/book.dart';
import 'package:fiwi/models/user.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibrarianHomeScreen extends StatefulWidget {
  const LibrarianHomeScreen({super.key});

  @override
  State<LibrarianHomeScreen> createState() => LibrarianHomeScreenState();
}

class LibrarianHomeScreenState extends State<LibrarianHomeScreen> {
  FocusNode book = FocusNode();
  FocusNode student = FocusNode();
  final bookRef = FirebaseDatabase.instance.ref('library');
  final userRef = FirebaseDatabase.instance.ref('users');
  List<Map<dynamic, dynamic>> booksList = [];
  List<Map<dynamic, dynamic>> userList = [];
  List<User> _userOptions = [];
  List<Book> _bookOptions = [];
  String? selectedPhoto;
  String? selectedName;
  String? selectedUid;
  String? selectedBookName;
  String? selectedBookCategory;
  String? selectedBookAuthorName;
  String? selectedBookPublication;
  String? selectedBookLocation;
  String? selectedBookQuantity;
  String? selectedBookId;
  static String _displayStringForOption(User option) => option.name;

  @override
  void initState() {
    super.initState();

    getUser();
    getBook();
  }

  void getBook() async {
    List<Book> book =
        await BlocProvider.of<ManageBookCubit>(context).getBooks();
    setState(() {
      _bookOptions = book;
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
      onPressed: () => Navigator.pushNamed(context, '/borrowedbook').then((_) {
        getUser();
        getBook();
      }),
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
      onPressed: () => Navigator.pushNamed(context, '/addbooks').then((_) {
        getUser();
        getBook();
      }),
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
            body: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(const Duration(microseconds: 1), () {
                  getUser();
                  getBook();
                });
              },
              child: ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Center(
                            child: Text(
                          'Express Book Checkout',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        )),
                        const SizedBox(height: 20),
                        selectedBookId == null
                            ? Autocomplete<Book>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return const Iterable.empty();
                                  } else {
                                    var a = _bookOptions.where((Book option) {
                                      return option.bookName
                                          .toString()
                                          .toLowerCase()
                                          .contains(textEditingValue.text
                                              .toLowerCase());
                                    }).toList();

                                    log(a.length.toString());
                                    return a;
                                  }
                                },
                                fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted) {
                                  book = focusNode;
                                  return TextField(
                                    onSubmitted: (value) => onFieldSubmitted,
                                    focusNode: book,
                                    controller: textEditingController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.black12),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelText: 'Book Name(Author) - Quantity',
                                    ),
                                  );
                                },
                                displayStringForOption: (Book option) =>
                                    '${option.bookName}(${option.authorName}) - ${option.quantity}',
                                onSelected: (Book selection) {
                                  setState(() {
                                    selectedBookName = selection.bookName;
                                    selectedBookCategory =
                                        selection.bookCategory;
                                    selectedBookAuthorName =
                                        selection.authorName;
                                    selectedBookPublication =
                                        selection.publication;
                                    selectedBookLocation =
                                        selection.bookLocation;
                                    selectedBookQuantity = selection.quantity;
                                    selectedBookId = selection.bookId;
                                  });
                                  debugPrint(
                                      'You just selected ${selection.bookName}');
                                },
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 30),
                                    child: Column(
                                      children: [
                                        Text('Book: $selectedBookName'),
                                        Text('Category: $selectedBookCategory'),
                                        Text('Author: $selectedBookAuthorName'),
                                        Text(
                                            'Publication: $selectedBookPublication'),
                                        Text('Quantity: $selectedBookQuantity'),
                                        Text('Location: $selectedBookLocation'),
                                      ],
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedBookName = null;
                                              selectedBookCategory = null;
                                              selectedBookAuthorName = null;
                                              selectedBookPublication = null;
                                              selectedBookLocation = null;
                                              selectedBookQuantity = null;
                                              selectedBookId = null;
                                            });
                                          },
                                          icon:
                                              const Icon(Icons.clear_rounded))),
                                ],
                              ),
                        const SizedBox(height: 20),
                        selectedUid == null
                            ? Autocomplete<User>(
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 7.0,
                                      child: Container(
                                        color: Colors.white,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.all(10.0),
                                          itemCount: options.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
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
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: option.photo != ''
                                                        ? CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl:
                                                                option.photo,
                                                            progressIndicatorBuilder: (context,
                                                                    url,
                                                                    downloadProgress) =>
                                                                CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          )
                                                        : Image.asset(
                                                            'assets/no_image.png'),
                                                  ),
                                                  title: Text(option.name,
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.black87)),
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
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: Image.asset(
                                                        'assets/no_image.png'),
                                                  ),
                                                  title: Text(
                                                      "${option.name} (new)",
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.black87)),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted) {
                                  student = focusNode;
                                  return TextField(
                                    onSubmitted: (value) => onFieldSubmitted,
                                    focusNode: student,
                                    controller: textEditingController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.black12),
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
                                          .contains(textEditingValue.text
                                              .toLowerCase());
                                    }).toList();
                                    a.add(User(
                                        photo: '',
                                        name: toCamelCaseWithSpace(
                                            textEditingValue.text),
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
                                  debugPrint(
                                      'You just selected ${selection.name}');
                                },
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: selectedUid == ''
                                          ? Text("${selectedName!} (new)")
                                          : Text(selectedName!),
                                      leading: Container(
                                        width: 55,
                                        height: 55,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: selectedPhoto != ''
                                            ? CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: selectedPhoto!,
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              )
                                            : Image.asset(
                                                'assets/no_image.png'),
                                      ),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedPhoto = null;
                                              selectedName = null;
                                              selectedUid = null;
                                            });
                                          },
                                          icon:
                                              const Icon(Icons.clear_rounded))),
                                ],
                              ),
                        const SizedBox(height: 20),
                        BlocConsumer<TrackBookCubit, TrackBookState>(
                          listener: (context, state) {
                            if (state is ExpressCheckoutSuccessState) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Query updated successfully"),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ));
                            } else if (state
                                is ExpressCheckoutBookAlreadyAllotedState) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Book is already alloted"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ));
                            } else if (state is TrackBookErrorState) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(state.error),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          },
                          builder: (context, state) {
                            if (state is ExpressCheckoutLoadingState) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return CustomButton(
                                text: 'Submit',
                                onPressed: () {
                                  if (selectedBookId != null &&
                                      selectedUid != '') {
                                    BlocProvider.of<TrackBookCubit>(context)
                                        .expressCheckout(
                                            selectedBookId, 'borrowed',
                                            userId: selectedUid,
                                            userName: null);
                                  } else if (selectedUid == '') {
                                    BlocProvider.of<TrackBookCubit>(context)
                                        .expressCheckout(
                                            selectedBookId, 'borrowed',
                                            userId: null,
                                            userName: selectedName);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Please select all the fields before submit"),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  }
                                },
                                icontext: false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
