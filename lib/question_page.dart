import 'package:flutter/material.dart';
import 'package:nihogo_geemu/game_state.dart';
import 'package:nihogo_geemu/widgets/button.dart';
import 'package:nihogo_geemu/widgets/route.dart';

import 'package:nihogo_geemu/widgets/snack_bar.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    super.key,
    required this.gameState,
  });
  final GameState gameState;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  bool filled = false;

  _onAnswer() {
    final correct = widget.gameState.isCorrectAnswer();
    if (correct) {
      widget.gameState.answeredCorreclty();
      widget.gameState.next();
      correctAnswerSnackBar(context);
      Navigator.of(context).push(createRoute(widget.gameState));
      return;
    }

    wrongAnswerSnackBar(context);
  }

  @override
  void initState() {
    super.initState();

    debugPrint('shownCount ${widget.gameState.shownCount()}');
  }

  String _getTitle(GameState gameState) {
    if (gameState.completedAllQuestions()) {
      return 'Congratulations!';
    }
    final currentCount = gameState.shownCount();
    final totalCount = gameState.totalQuestionCount();
    final label = gameState.label;
    final level = gameState.level;
    return 'Question $currentCount / $totalCount of $label in $level';
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle(widget.gameState);
    if (widget.gameState.completedAllQuestions()) {
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
                  'English: ${widget.gameState.firstEnglish()}',
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
                      _onAnswer();
                    },
                    onChanged: (String value) {
                      setState(() {
                        widget.gameState.updateUserAnswer(value);
                        filled = widget.gameState.filled();
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
          onPressed: filled ? _onAnswer : null,
          tooltip: 'confirm my answer',
          child: const Icon(Icons.play_arrow),
        ),
        FloatingActionButton(
          heroTag: 'skip',
          onPressed: () {
            final actualAnswer = widget.gameState.answerForDisplay();
            actualAnswerSnackBar(context, widget.gameState.firstEnglish(), actualAnswer);
            widget.gameState.skip();
            widget.gameState.next();
            Navigator.of(context).push(createRoute(widget.gameState));
          },
          tooltip: "I don't know",
          child: const Icon(Icons.question_mark),
        ),
        FloatingActionButton(
          heroTag: 'finish',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          tooltip: 'finish',
          child: const Icon(Icons.home),
        ),
      ]),
    );
  }
}
