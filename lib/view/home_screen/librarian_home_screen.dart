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


  @override
  void initState() {
    super.initState();


  }
   Widget float1() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, '/expresscheckout').then((_) {
      }),
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
      onPressed: () => Navigator.pushNamed(context, '/borrowedbook').then((_) {
      }),
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
      onPressed: () => Navigator.pushNamed(context, '/addbooks').then((_) {
      }),
      heroTag: "books",
      tooltip: 'Books',
      child: const Icon(Icons.menu_book_rounded),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: AnimatedFloatingActionButton(
          animatedIconData: AnimatedIcons.menu_close,
          curve: Curves.easeInCubic,
          durationAnimation: 200,
          fabButtons: <Widget>[float1(), float2(),float3()],
        ),
        body: Container());
  }
}
