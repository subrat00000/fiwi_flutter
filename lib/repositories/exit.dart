import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Exit {
  showExitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => exit(0),
                  child: const Text('Yes'),
                ),
              ],
            ));
  }
}