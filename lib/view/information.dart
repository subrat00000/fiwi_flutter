import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Information extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Your account is successfully created. \n Please wait until your account gets activated.',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
