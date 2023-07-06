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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Library Page',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            ElevatedButton(
              onPressed: () {
                // context.read<BottomNavCubit>().getHome();
              },
              child: const Text('GO TO HOME'),
            )
          ]),
        ),
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              tooltip: "Issue Book",
              backgroundColor: Colors.purple[100],
              onPressed: () => Navigator.pushNamed(context, '/bookissue'),
              child: Image.asset('assets/book_issue.png',cacheHeight: 35,),
            ),
          ),
      ],
    );
  }
}
