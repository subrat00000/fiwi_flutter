import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Box box = Hive.box('user');
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white38,
          child: StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref('library')
                  .child('track')
                  .child(box.get('uid'))
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final itemsMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final itemsList = itemsMap.values.whereType<Map>().toList();
                  return ListView.builder(
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                            stream: FirebaseDatabase.instance
                                .ref('library')
                                .child('books')
                                .child(itemsList[index]['book_id'])
                                .onValue,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data == null ||
                                  snapshot.data!.snapshot.value == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                final book = snapshot.data!.snapshot.value
                                    as Map<dynamic, dynamic>;
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
                                    const SizedBox(height: 20,),
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
                                                : itemsList[index][
                                                            'book_issue_rejected'] ==
                                                        true
                                                    ? const Column(
                                                        children: [
                                                          Icon(
                                                            Icons.block_rounded,
                                                            color: Colors.red,
                                                          ),
                                                          Text(
                                                            'Rejected',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ],
                                                      )
                                                    : itemsList[index][
                                                                'book_issued'] ==
                                                            false
                                                        ? const Column(
                                                            children: [
                                                              Text('Requested'),
                                                            ],
                                                          )
                                                        : Container())
                                  ],
                                ),
                                
                              ],
                            ),
                          ));
                              }
                            });
                      });
                }
              }),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            tooltip: "Issue Book Scanner",
            heroTag: "issue_book_scanner",
            backgroundColor: Colors.purple[100],
            onPressed: () => Navigator.pushNamed(context, '/qrscanbookmanage'),
            child: const Icon(Icons.qr_code_2_rounded,
                color: Colors.white, size: 30),
          ),
        ),
        Positioned(
          bottom: 16.0,
          left: 16.0,
          child: FloatingActionButton(
            heroTag: "library_books",
            tooltip: "Library Books",
            backgroundColor: Colors.purple[100],
            onPressed: () => Navigator.pushNamed(context, '/bookissue'),
            child: Image.asset(
              'assets/book_issue.png',
              cacheHeight: 35,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(),
        ),
      ],
    );
  }
}
