import 'package:flutter/material.dart';


class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  var internet = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white38,
          
        ),
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              tooltip: "Issue Book Scanner",
              heroTag: "issue_book_scanner",
              backgroundColor: Colors.purple[100],
              onPressed: () => Navigator.pushNamed(context, '/qrscanbookmanage'),
              child: const Icon(Icons.qr_code_2_rounded,color: Colors.white,size: 30),
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
              child: Image.asset('assets/book_issue.png',cacheHeight: 35,),
            ),
          ),
      ],
    );
  }
}
