import 'package:flutter/material.dart';

void noInternetConnectinoSnackBar(BuildContext context) {
  const msg = 'Please connect to the internet to download the question database.';
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
    ));
}

void workingOfflineSnackBar(BuildContext context) {
  const msg = 'No internet connection. Using cached question database.';
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(msg),
        backgroundColor: Colors.amberAccent,
    ));
}

void noQuestionsFoundSnackBar(BuildContext context) {
  const msg = 'Sorry no questions found for the selected labels';
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
    ));
}

void correctAnswerSnackBar(BuildContext context) {
  const msg = 'Correct!';
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(msg),
        backgroundColor: Colors.greenAccent,
    ));
}

void wrongAnswerSnackBar(BuildContext context) {
  const msg = 'Sorry keep trying!';
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(msg),
        backgroundColor: Colors.amberAccent,
    ));
}
