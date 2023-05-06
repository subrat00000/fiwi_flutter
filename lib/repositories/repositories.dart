import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Repositories {
  Future<bool> showExitDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context,false),
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

String toCamelCase(String input) {
  // Split the input into words
  final words = input.split(' ');

  // Convert the first letter of each word to uppercase and join the words
  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join('');
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

String getTimeAgo(DateTime date) {
  final duration = DateTime.now().difference(date);
  if (duration < Duration(minutes: 1)) {
    return 'just now';
  } else if (duration < Duration(hours: 1)) {
    final minutes = duration.inMinutes;
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  } else if (duration < Duration(days: 1)) {
    final hours = duration.inHours;
    return '$hours hour${hours == 1 ? '' : 's'} ago';
  } else if (duration < Duration(days: 7)) {
    final days = duration.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  } else {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
