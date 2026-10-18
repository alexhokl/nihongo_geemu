import 'package:flutter/material.dart';
import 'package:flutter_helper/ui.dart';

void noInternetConnectinoSnackBar(BuildContext context) {
  showMessage(
    context,
    'Please connect to the internet to download the question database.',
    kind: MessageKind.error,
  );
}

void workingOfflineSnackBar(BuildContext context) {
  showMessage(
    context,
    'No internet connection. Using cached question database.',
    kind: MessageKind.warning,
  );
}

void noQuestionsFoundSnackBar(BuildContext context) {
  showMessage(
    context,
    'Sorry no questions found for the selected labels',
    kind: MessageKind.error,
  );
}

void correctAnswerSnackBar(BuildContext context) {
  showMessage(context, 'Correct!', kind: MessageKind.success);
}

void wrongAnswerSnackBar(BuildContext context) {
  showMessage(context, 'Sorry keep trying!', kind: MessageKind.warning);
}
