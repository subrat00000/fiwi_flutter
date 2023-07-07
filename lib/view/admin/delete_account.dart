import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fiwi/cubits/activate_student/activate_student_cubit.dart';
import 'package:fiwi/cubits/delete_account/delete_account_cubit.dart';
import 'package:fiwi/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final TextEditingController _searchController = TextEditingController();
  bool search = false;
  List filteredUser = [];
  List users = [];
  String? query;
  _activate(user) {
    if (user['active'] == true) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Do you want to delete account. ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: '${user['name']}',
                        style: TextStyle(color: Colors.red[300]),
                      ),
                      const TextSpan(
                        text: '? This is Irreversible.',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      BlocProvider.of<DeleteAccountCubit>(context)
                                      .deleteAccount(
                                          );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ));
    } else {
      BlocProvider.of<ActivateStudentCubit>(context)
          .activateStudent(user['uid'], true);
    }
  }

  // @override
  // void dispose() {
  //   _searchController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (search == true) {
              setState(() {
                search = !search;
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black87,
        ),
        actions: [
          if (search)
            IconButton(
              onPressed: () {
                setState(() {
                  search = false;
                });
              },
              icon: const Icon(
                Icons.close_outlined,
                color: Colors.black87,
              ),
            ),
          if (!search)
            IconButton(
              onPressed: () {
                setState(() {
                  search = true;
                });
              },
              icon: const Icon(Icons.search, color: Colors.black87),
            ),
        ],
        title: search
            ? TextField(
                // controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    query = value;
                    filteredUser = users.where((user) {
                      final nameLower = user['name'].toString().toLowerCase();
                      return nameLower.contains(value);
                    }).toList();
                  });
                  log(filteredUser.toString());
                },
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              )
            : const Text(
                'Delete Account',
                style: TextStyle(color: Colors.black87, fontSize: 20),
                textAlign: TextAlign.start,
              ),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref('users').onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final itemsMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                users = itemsMap.values.toList();

                if (query == null) {
                  filteredUser = users.where((user) {
                    final role = user['uid'];
                    return role != _auth.currentUser!.uid;
                  }).toList();
                }
                return Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10.0),
                        itemCount: filteredUser.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text('${filteredUser[index]['name']}(${toCamelCase(filteredUser[index]['role'])})'),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red[300],
                                ),
                                onPressed: () {
                                  _activate(filteredUser[index]);
                                },
                              ),
                              subtitle: filteredUser[index]['email'] != null
                                  ? Text(filteredUser[index]['email'])
                                  : Text(filteredUser[index]['phone']),
                              leading: Container(
                                width: 55,
                                height: 55,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: filteredUser[index]['photo'] != null &&
                                        filteredUser[index]['photo'] != ''
                                    ? CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: filteredUser[index]['photo'],
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      )
                                    : Image.asset('assets/no_image.png'),
                              ),
                              onTap: () {
                                // Navigator.pushNamed(context, itemsMap[a]['route']);
                              },
                            ),
                          );
                        }),
                  ],
                );
              }
            }),
      ),
    );
  }
}
