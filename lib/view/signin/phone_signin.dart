import 'package:flutter/material.dart';

class PhoneSignin extends StatefulWidget {
  const PhoneSignin({super.key});

  @override
  State<PhoneSignin> createState() => PhoneSigninState();
}

class PhoneSigninState extends State<PhoneSignin> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child:Text("hello")));
  }

}