import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/track_book/track_book_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AcceptIssueRequestScreen extends StatefulWidget {
  final Map data;
  const AcceptIssueRequestScreen({super.key, required this.data});

  @override
  State<AcceptIssueRequestScreen> createState() =>
      AcceptIssueRequestScreenState();
}

class AcceptIssueRequestScreenState extends State<AcceptIssueRequestScreen> {
  List<Map>? itemsListData;
  List books = [];
  List bookIds = [];
  void getBookDetails(List<Map> bookList) async {
    List localBooks = [];
    List localBookIds = [];
    for (var element in bookList) {
      if (element['book_issue_rejected'] == false) {
        localBookIds.add(element['book_id']);
      }
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
    setState(() {
      books = localBooks; //books
      bookIds = localBookIds; //only book ids
      itemsListData = bookList; //track
    });
    // log(itemsListData.toString());
  }

  alertDialot(String uid, String bookId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                  'Do you want to Reject Book Issue? This operation is irreversible.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    BlocProvider.of<TrackBookCubit>(context)
                        .rejectBook(uid, bookId);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code_2_rounded,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/qrbookissue',
                  arguments: {'books': bookIds, 'user_id': widget.data['uid']});
            },
          )
        ],
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
                            element['id'] == itemsList[index]['book_id'] &&
                            itemsList[index]['book_issued'] == false &&
                            itemsList[index]['book_borrowed'] == false &&
                            itemsList[index]['book_issue_rejected'] == false);
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
                                        'Issue Request Date: ${DateFormat('yyyy-MMM-d hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(itemsList[index]['issue_request_date'])))}'),
                                    Text(
                                        'Issue Date: ${itemsList[index]['issue_date'] != null ? DateFormat('yyyy-MMM-d hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(itemsList[index]['issue_date']))) : 'Not Applicable'}'),
                                    Text(
                                        'Borrow Date: ${itemsList[index]['borrow_date'] != null ? DateFormat('yyyy-MMM-d hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(itemsList[index]['borrow_date']))) : 'Not Applicable'}'),
                                    Text(
                                        'Return Date: ${itemsList[index]['return_date'] != null ? DateFormat('yyyy-MMM-d hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(itemsList[index]['return_date']))) : 'Not Applicable'}'),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.white)),
                                      onPressed: () => alertDialot(
                                          widget.data['uid'],
                                          itemsList[index]['book_id']),
                                      child: const Text(
                                        'Reject',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
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
                                        child: itemsList[index]
                                                        ['book_borrowed'] ==
                                                    true &&
                                                itemsList[index]
                                                        ['book_returned'] ==
                                                    false
                                            ? Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/book_borrowed.png',
                                                    cacheHeight: 25,
                                                  ),
                                                  const Text('Borrowed')
                                                ],
                                              )
                                            : itemsList[index]
                                                        ['book_returned'] ==
                                                    true
                                                ? const Column(
                                                    children: [
                                                      Icon(
                                                        Icons.check,
                                                        color: Colors.green,
                                                      ),
                                                      Text('Returned')
                                                    ],
                                                  )
                                                : itemsList[index]
                                                            ['book_issued'] ==
                                                        false
                                                    ? Text('Requested')
                                                    : Container())
                                  ],
                                ),
                              ],
                            ),
                          ));
                        } else {
                          return Container();
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
