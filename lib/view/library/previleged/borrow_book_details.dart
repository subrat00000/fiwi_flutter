import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BorrowBookDetailsScreen extends StatefulWidget {
  final Map data;
  const BorrowBookDetailsScreen({super.key, required this.data});

  @override
  State<BorrowBookDetailsScreen> createState() =>
      BorrowBookDetailsScreenState();
}

class BorrowBookDetailsScreenState extends State<BorrowBookDetailsScreen> {
  List books = [];
  void getBookDetails(List<Map> bookList) async {
    List localBooks = [];
    for (var element in bookList) {
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .ref('library/books')
          .child(element['book_id'])
          .once();
      if (snapshot.snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        localBooks.add(data);
      }
    }
    if (!mounted) {
      return;
    }
    log(localBooks.toString());
    setState(() {
      books = localBooks;
    });
  }

  @override
  void initState() {
    super.initState();
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
        title: Text(
          widget.data['name'],
          style: const TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      body: Container(
          child: StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref('library')
                  .child('track')
                  .child(widget.data['uid'])
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  // final data = snapshot.data!.snapshot.value as Map;
                  final itemsMap = Map<String, dynamic>.from(
                          snapshot.data!.snapshot.value as Map)
                      .values
                      .toList();
                  final itemsList = itemsMap.whereType<Map>().toList();
                  if (books.isEmpty) {
                    getBookDetails(itemsList);
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10.0),
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        final bookData = books.where((element) =>
                            element['id'] == itemsList[index]['book_id']);
                        if (bookData.isNotEmpty) {
                          final book = bookData.first;
                          return Card(
                              child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Book Name: ${book['book_name']}'),
                                    Text('Author Name: ${book['author_name']}'),
                                    Text('Publication: ${book['publication']}'),
                                    Text(
                                        'Book Category: ${book['book_category']}'),
                                    Text('ISBN: ${book['isbn']}'),
                                    Text(
                                        'Issue Date: ${DateFormat('yyyy-MMM-d hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(itemsList[index]['issue_date'])))}'),
                                    Text(
                                        'Borrow Date: ${DateFormat('yyyy-MMM-d hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(itemsList[index]['borrow_date'])))}'),
                                    Text(
                                        'Return Date: ${book['return_date'] != null ? DateFormat('yyyy-MMM-d hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(itemsList[index]['return_date']))) : 'Not Applicable'}')
                                  ],
                                ),
                                Column(
                                  children: [
                                    Card(
                                        elevation: 8,
                                        child: IconButton(
                                          icon: Icon(Icons.qr_code_2_rounded),
                                          onPressed: () {getBookDetails(itemsList);},
                                          tooltip: 'Open QR for Book Return',
                                        )),
                                    const Text('Status'),
                                    Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2.0,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8.0)),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'assets/book_borrowed.png',
                                              cacheHeight: 25,
                                            ),
                                            const Text('Borrowed')
                                          ],
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ));
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // return Row(
                        //   children: [
                        //     Expanded(child: Text(book.toString())),
                        //   ],
                        // );
                      });
                }
              })),
    );
  }
}
