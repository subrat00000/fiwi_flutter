import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/botttom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageRoleScreen extends StatefulWidget {
  const ManageRoleScreen({super.key});

  @override
  State<ManageRoleScreen> createState() => _ManageRoleScreenState();
}

class _ManageRoleScreenState extends State<ManageRoleScreen> {
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref('manageRole').onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final itemsMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List a = itemsMap.keys.toList();
                List uid = [];
                for (int i = 0; i < a.length; i++) {
                  if (itemsMap[a[i]]['uid'] != null) {
                    uid.add(itemsMap[a[i]]['uid']);
                  }
                }
                // return Text(itemsMap.keys.toList().toString());
                return Column(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            margin: const EdgeInsets.only(left: 30),
                            child: const Text(
                              'Activated',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                              textAlign: TextAlign.start,
                            ))),
                    ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10.0),
                        itemCount: uid.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder(
                              stream: FirebaseDatabase.instance
                                  .ref('users/${uid[index]}')
                                  .onValue,
                              builder: (context, snap) {
                                if (!snap.hasData || snap.data == null) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  final items = snap.data!.snapshot.value
                                      as Map<dynamic, dynamic>;

                                  final itemsList =
                                      Map.fromEntries(items.entries.toList());
                                  // return Text(itemsList.toString());
                                  return Card(
                                    child: ListTile(
                                      title: Text(itemsList['name']),
                                      subtitle: itemsList['emailVerified']
                                          ? Text(itemsList['email'])
                                          : Text(itemsList['phone']),
                                      leading: Container(
                                        width: 55,
                                        height: 55,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: itemsList['photo'] != null &&
                                                itemsList['photo'] != ''
                                            ? CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: itemsList['photo'],
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
                                      onTap: () {
                                        // Navigator.pushNamed(context, itemsMap[a]['route']);
                                      },
                                    ),
                                  );
                                }
                              });
                        }),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            margin: const EdgeInsets.only(left: 30),
                            child: const Text(
                              'Not Activated',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                              textAlign: TextAlign.start,
                            ))),
                    ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10.0),
                        itemCount: a.length,
                        itemBuilder: (context, index) {
                          if (itemsMap[a[index]]['uid'] == null) {
                            return Card(
                              child: ListTile(
                                title: itemsMap[a[index]]['email'] != null
                                    ? Text(itemsMap[a[index]]['email'])
                                    : Text(itemsMap[a[index]]['phone']),
                                // subtitle: Text(itemsMap[a[index]].uid),
                                leading: Container(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Image.asset(
                                      'assets/no_image.png',
                                    )),
                                onTap: () {
                                  // Navigator.pushNamed(context, itemsMap[a]['route']);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ],
                );
              }
            }),
      ),
    );
  }
}
