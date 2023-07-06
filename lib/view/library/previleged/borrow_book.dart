import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BorrowBookScreen extends StatefulWidget {
  const BorrowBookScreen({super.key});

  @override
  State<BorrowBookScreen> createState() => BorrowBookScreenState();
}

class BorrowBookScreenState extends State<BorrowBookScreen> {
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
        title: const Text(
          'Track Books',
          style: TextStyle(color: Colors.black87, fontSize: 20),
          textAlign: TextAlign.start,
        ),
      ),
      body: Container(
          child: StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref('library')
                  .child('track')
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
                  final itemsList = itemsMap.values.toList();
                  itemsList.sort((a, b) => b['last_updated']
                      .toString()
                      .compareTo(a['last_updated'].toString()));
                  return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10.0),
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        final bookData = itemsList[index] as Map;
                        final bookLists =
                            bookData.values.whereType<Map>().toList();
                        return StreamBuilder(
                            stream: FirebaseDatabase.instance
                                .ref('users')
                                .child(itemsList[index]['user_id'])
                                .onValue,
                            builder: (context, snap) {
                              if (!snap.hasData ||
                                  snap.data == null ||
                                  snap.data!.snapshot.value == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                final itemsMap = snap.data!.snapshot.value
                                    as Map<dynamic, dynamic>;
                                return Card(
                                    child: ListTile(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/borrowedbookdetails',
                                      arguments: itemsMap),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: itemsMap['photo'] != null &&
                                            itemsMap['photo'] != ''
                                        ? CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: itemsMap['photo'],
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          )
                                        : Image.asset('assets/no_image.png'),
                                  ),
                                  title: Text(itemsMap['name']),
                                  subtitle: ListView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(10.0),
                                      itemCount: bookLists.length,
                                      itemBuilder: (context, i) {
                                        return StreamBuilder(
                                            stream: FirebaseDatabase.instance
                                                .ref('library')
                                                .child('books')
                                                .child(bookLists[i]['book_id'])
                                                .onValue,
                                            builder: (context, s) {
                                              if (!s.hasData ||
                                                  s.data == null ||
                                                  s.data!.snapshot.value ==
                                                      null) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              } else {
                                                final itemsMap = s
                                                        .data!.snapshot.value
                                                    as Map<dynamic, dynamic>;
                                                return Row(
                                                  children: [
                                                    Text(
                                                        '${itemsMap['book_name']}'),
                                                    bookLists[i][
                                                                'book_borrowed'] ==
                                                            true && bookLists[i]['book_returned']==false
                                                        ? Image.asset(
                                                            'assets/book_borrowed.png',
                                                            cacheHeight: 25,
                                                          )
                                                        : Container(),
                                                    bookLists[i][
                                                                'book_returned'] ==
                                                            true
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.green)
                                                        : Container(),
                                                    bookLists[i][
                                                                'book_issue_rejected'] ==
                                                            true
                                                        ? const Icon(
                                                            Icons.block_rounded,
                                                            color: Colors.red)
                                                        : Container()
                                                  ],
                                                );
                                              }
                                            });
                                      }),
                                ));
                              }
                            });
                      });
                }
              })),
    );
  }
}
