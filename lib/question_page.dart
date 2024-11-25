import 'package:flutter/material.dart';
import 'package:nihogo_geemu/question.dart';
import 'package:nihogo_geemu/widgets/button.dart';
import 'dart:math';

import 'package:nihogo_geemu/widgets/snack_bar.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    super.key,
    required this.questions,
    required this.selectedLevel,
    required this.selectedLabel,
  });
  final List<Question> questions;
  final String selectedLevel;
  final String selectedLabel;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int questionIndex = 0;
  int shownCount = 1;
  int totalQuestionCount = 0;
  bool filled = false;
  bool completedAllQuestions = false;

  _onComplete() {
    final kana = widget.questions[questionIndex].kana.trim();
    final kanji = widget.questions[questionIndex].kanji.trim();
    final answer = widget.questions[questionIndex].answer.trim();
    if (answer == kana || answer == kanji) {
      widget.questions[questionIndex].correct = true;
      correctAnswerSnackBar(context);
      Navigator.of(context).push(_createRoute(widget.questions));
      return;
    }

    wrongAnswerSnackBar(context);
  }

  Route _createRoute(List<Question> questions) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
        QuestionPage(
          questions: questions,
          selectedLevel: widget.selectedLevel,
          selectedLabel: widget.selectedLabel
        ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  bool isAllQuestionsAnswered() {
    return widget.questions.every((q) => q.shown);
  }

  int getQuestionIndex() {
    Random random = Random();
    questionIndex = random.nextInt(widget.questions.length);
    while (widget.questions[questionIndex].shown) {
      questionIndex = random.nextInt(widget.questions.length);
    }
    return questionIndex;
  }

  int getShownCount() {
    shownCount = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (widget.questions[i].shown) {
        shownCount++;
      }
    }
    return shownCount;
  }

  @override
  void initState() {
    super.initState();
    if (isAllQuestionsAnswered()) {
      completedAllQuestions = true;
      return;
    }
    questionIndex = getQuestionIndex();
    widget.questions[questionIndex].shown = true;
    shownCount = getShownCount();
    totalQuestionCount = widget.questions.length;
  }

  String _getTitle(int shownCount, int totalQuestionCount, String selectedLabel, String selectedLevel) {
    if (totalQuestionCount == 0) {
      return 'Congratulations!';
    }
    return 'Question $shownCount / $totalQuestionCount of ${widget.selectedLabel} in ${widget.selectedLevel}';
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle(shownCount, totalQuestionCount, widget.selectedLabel, widget.selectedLevel);
    if (completedAllQuestions) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('You have completed all questions!'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          tooltip: 'finish',
          child: const Icon(Icons.stop_rounded),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 100.0, right: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'English: ${widget.questions[questionIndex].english[0]}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Kanji or Kana',
                    ),
                    onSubmitted: (String value) {
                      _onComplete();
                    },
                    onChanged: (String value) {
                      setState(() {
                        filled = value.isNotEmpty;
                        widget.questions[questionIndex].answer = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          )
        ),
      ),
      floatingActionButton: getButtonStack([
        FloatingActionButton(
          heroTag: 'next',
          onPressed: filled ? _onComplete : null,
          tooltip: 'next question',
          child: const Icon(Icons.play_arrow),
        ),
        FloatingActionButton(
          heroTag: 'finish',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          tooltip: 'finish',
          child: const Icon(Icons.stop_rounded),
        ),
      ]),
    );
  }
}
