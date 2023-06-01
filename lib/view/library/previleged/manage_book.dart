import 'dart:developer';
import 'package:fiwi/cubits/manage_book/manage_book_cubit.dart';
import 'package:fiwi/cubits/manage_book/manage_book_state.dart';
import 'package:fiwi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController bookName = TextEditingController();
  FocusNode bookNameNode = FocusNode();
  TextEditingController authorName = TextEditingController();
  FocusNode authorNameNode = FocusNode();
  TextEditingController publication = TextEditingController();
  FocusNode publicationNode = FocusNode();
  TextEditingController isbn = TextEditingController();
  FocusNode isbnNode = FocusNode();
  TextEditingController quantity = TextEditingController();
  FocusNode quantityNode = FocusNode();
  TextEditingController bookLocation = TextEditingController();
  FocusNode bookLocationNode = FocusNode();
  List<String> bookCategory = [
    'Computer Science',
    'English',
    'Comic',
    'Mathematics'
  ];
  String? selectedBook;
  bool validation = false;
  bool isView = false;
  bool isUpdate = false;
  List books = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final List bookList =
        await BlocProvider.of<ManageBookCubit>(context).getBooks();
    bookList.sort((a, b) =>
        a['book_name'].toString().compareTo(b['book_name'].toString()));
    setState(() {
      books = bookList;
    });
    log(books.toString());
  }

  _bottomModal(
      {bool isView = false, bool isUpdate = false, String childKey = ''}) {
    showModalBottomSheet(
        backgroundColor: const Color(0x00ffffff),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // double width = MediaQuery.of(context).size.width;
            double height = MediaQuery.of(context).size.height;

            return GestureDetector(
              onTap: () {
                bookNameNode.unfocus();
                authorNameNode.unfocus();
                publicationNode.unfocus();
                isbnNode.unfocus();
                quantityNode.unfocus();
                bookLocationNode.unfocus();
              },
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  height: height * 0.9,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )),
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formKey,
                        child: Column(
                          children: [
                            isView
                                ? const Text(
                                    "",
                                  )
                                : isUpdate
                                    ? const Text("Update Book",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87))
                                    : const Text("Add New Book",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87)),
                            const SizedBox(height: 20),
                            (isView || isUpdate)? Text('Unique id: $childKey'):Container(),
                            const SizedBox(height: 20),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty && validation) {
                                  return 'Please enter a valid Book name';
                                }
                                return null;
                              },
                              enabled: !isView,
                              controller: bookName,
                              focusNode: bookNameNode,
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
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField<String>(
                              validator: (value) {
                                if (value == null && validation) {
                                  return 'Please Select a Category';
                                }
                                return null;
                              },
                              hint: const Text("Book Category"),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                hintStyle:
                                    const TextStyle(color: Colors.black12),
                              ),
                              items: bookCategory.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              value: selectedBook,
                              onChanged: isView
                                  ? null
                                  : (String? value) {
                                      setState(() {
                                        selectedBook = value;
                                      });
                                    },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty && validation) {
                                  return 'Please enter a valid Author Name';
                                }
                                return null;
                              },
                              enabled: !isView,
                              focusNode: authorNameNode,
                              controller: authorName,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Auther Name',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty && validation) {
                                  return 'Please enter a valid Publication';
                                }
                                return null;
                              },
                              enabled: !isView,
                              focusNode: publicationNode,
                              controller: publication,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Publication',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty && validation) {
                                  return 'Please enter a valid ISBN';
                                }
                                return null;
                              },
                              enabled: !isView,
                              focusNode: isbnNode,
                              controller: isbn,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'ISBN',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty && validation) {
                                  return 'Please enter a valid Author Name';
                                }
                                return null;
                              },
                              enabled: !isView,
                              focusNode: bookLocationNode,
                              controller: bookLocation,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Book Location',
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty && validation) {
                                  return 'Please enter a valid Quantity';
                                }
                                return null;
                              },
                              enabled: !isView,
                              focusNode: quantityNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              controller: quantity,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelText: 'Quantity',
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            isView
                                ? Container()
                                : CustomButton(
                                    text: "Submit",
                                    icontext: false,
                                    onPressed: () {
                                      validation = true;

                                      if (_formKey.currentState!.validate()) {
                                        if (isUpdate) {
                                          BlocProvider.of<ManageBookCubit>(
                                                  context)
                                              .updateBook(
                                                  bookName.text,
                                                  selectedBook,
                                                  authorName.text,
                                                  publication.text,
                                                  isbn.text,
                                                  bookLocation.text,
                                                  quantity.text,
                                                  childKey);
                                        } else {
                                          BlocProvider.of<ManageBookCubit>(
                                                  context)
                                              .addBook(
                                                  bookName.text,
                                                  selectedBook,
                                                  authorName.text,
                                                  publication.text,
                                                  isbn.text,
                                                  bookLocation.text,
                                                  quantity.text);
                                        }
                                        _loadData();
                                        Navigator.pop(context);
                                      }
                                    })
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _bottomModal(),
          tooltip: 'Add New Books',
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87),
          ),
          title: const Text(
            'Manage Books',
            style: TextStyle(color: Colors.black87, fontSize: 20),
            textAlign: TextAlign.start,
          ),
        ),
        body: BlocListener<ManageBookCubit, ManageBookState>(
            listener: (context, state) {
              if (state is AddBookSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Book details added successfully."),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
              } else if (state is UpdateBookSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Book details updated successfully."),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
              } else if (state is DeleteBookSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Book details deleted successfully"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
              } else if (state is ManageBookErrorState) {
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
                        onTap: () {
                          bookName.text = books[index]['book_name'];
                          selectedBook = books[index]['book_category'];
                          authorName.text = books[index]['author_name'];
                          publication.text = books[index]['publication'];
                          isbn.text = books[index]['isbn'];
                          bookLocation.text = books[index]['book_location'];
                          quantity.text = books[index]['quantity'];
                          _bottomModal(
                              isView: true, childKey: books[index]['key']);
                        },
                        onLongPress: () {
                          showMenu(
                            context: context,
                            position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                            items: const [
                              PopupMenuItem(
                                value: 1,
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text('Delete'),
                              ),
                            ],
                            elevation: 8.0,
                          ).then((value) {
                            if (value == 1) {
                              bookName.text = books[index]['book_name'];
                              selectedBook = books[index]['book_category'];
                              authorName.text = books[index]['author_name'];
                              publication.text = books[index]['publication'];
                              isbn.text = books[index]['isbn'];
                              bookLocation.text = books[index]['book_location'];
                              quantity.text = books[index]['quantity'];

                              _bottomModal(
                                  isUpdate: true,
                                  childKey: books[index]['key']);
                            } else if (value == 2) {
                              BlocProvider.of<ManageBookCubit>(context)
                                  .deleteBook(books[index]['key']);
                              _loadData();
                            }
                          });
                        },
                        title: Text(
                            '${books[index]['book_name']}(${books[index]['quantity']})'),
                        subtitle: Text(
                            '${books[index]['publication']}(${books[index]['author_name']})'),
                      ));
                    })
                : const Center(
                    child: CircularProgressIndicator(),
                  )));
  }
}
