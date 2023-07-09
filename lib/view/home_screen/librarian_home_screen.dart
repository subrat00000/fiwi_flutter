import 'dart:developer';

import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LibrarianHomeScreen extends StatefulWidget {
  const LibrarianHomeScreen({super.key});

  @override
  State<LibrarianHomeScreen> createState() => LibrarianHomeScreenState();
}

class LibrarianHomeScreenState extends State<LibrarianHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget float1() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () =>
          Navigator.pushNamed(context, '/expresscheckout').then((_) {}),
      heroTag: "expresscheckout",
      tooltip: 'Express Checkout',
      child: Image.asset(
        'assets/borrow_book.png',
        cacheHeight: 35,
      ),
    );
  }

  Widget float2() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () =>
          Navigator.pushNamed(context, '/borrowedbook').then((_) {}),
      heroTag: "student_borrowed",
      tooltip: 'Student Borrowed',
      child: Image.asset(
        'assets/borrow.png',
        cacheHeight: 35,
      ),
    );
  }

  Widget float3() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/addbooks').then((_) {}),
      heroTag: "books",
      tooltip: 'Books',
      child: const Icon(Icons.menu_book_rounded),
    );
  }

  void checkBookIssueRequest(List<Map<String, dynamic>> bookData) {
    for (var studentData in bookData) {
      if (studentData.containsKey('book_issue_request') &&
          studentData['book_issue_request'] == true &&
          studentData['book_issued'] == false) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: AnimatedFloatingActionButton(
          animatedIconData: AnimatedIcons.menu_close,
          curve: Curves.easeInCubic,
          durationAnimation: 200,
          fabButtons: <Widget>[float1(), float2(), float3()],
        ),
        body: StreamBuilder(
            stream:
                FirebaseDatabase.instance.ref('library').child('track').onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.snapshot.value == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final itemsList = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map)
                    .values
                    .toList();

                final itemsList2 = itemsList
                    .map((student) => (student as Map)
                        .values
                        .whereType<Map>()
                        .where((element) =>
                            element['book_issue_request'] == true &&
                            element['book_issued'] == false &&
                            element['book_borrowed'] == false &&
                            element['book_issue_rejected'] == false))
                    .expand((element) => element)
                    .toList();
                final users = [];
                for (var element in itemsList2) {
                  if (!users.contains(element['user_id'])) {
                    users.add(element['user_id']);
                  }
                }
                log(users.toString());
                return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder(
                          stream: FirebaseDatabase.instance
                              .ref('users')
                              .child(users[index])
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
                                    context, '/acceptissuerequest',
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
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        )
                                      : Image.asset('assets/no_image.png'),
                                ),
                                title: Text(itemsMap['name']),
                                subtitle: ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(10.0),
                                    itemCount: itemsList2.length,
                                    itemBuilder: (context, i) {
                                      if (users[index] ==
                                          itemsList2[i]['user_id']) {
                                        return StreamBuilder(
                                            stream: FirebaseDatabase.instance
                                                .ref('library')
                                                .child('books')
                                                .child(itemsList2[i]['book_id'])
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
                                                return Text(
                                                    '${itemsMap['book_name']}');
                                              }
                                            });
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ));
                            }
                          });
                    });
              }
            }));
  }
}
