import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Repositories {
  showExitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => exit(0),
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  String toCamelCase(String input) {
    // Split the input into words
    final words = input.split(' ');

    // Convert the first letter of each word to uppercase and join the words
    return words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join('');
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class Course implements Comparable<Course> {
  final String? code;
  final String? name;
  final String? semester;

  Course({
    this.code,
    this.name,
    this.semester,
  });

  @override
  int compareTo(Course other) {
    // Compare courses based on their semester
    return semester!.compareTo(other.semester!);
  }
}