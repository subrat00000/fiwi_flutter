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
            'Borrowed Books',
            style: TextStyle(color: Colors.black87, fontSize: 20),
            textAlign: TextAlign.start,
          ),
        ),
      body: const Column(
        children: [
          Stack(
            children: [
              
            ],
          ),
        ],
      ),
    );
  }
}
