import 'package:flutter/material.dart';
import 'package:nihongo_geemu/game_state.dart';
import 'package:nihongo_geemu/widgets/button.dart';
import 'package:nihongo_geemu/widgets/route.dart';
import 'package:nihongo_geemu/widgets/score_bar.dart';

import 'package:nihongo_geemu/widgets/snack_bar.dart';

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
      Navigator.of(context).pushReplacement(createRoute(widget.gameState));
      return;
    }

    wrongAnswerSnackBar(context);
  }

  @override
  void initState() {
    super.initState();

    debugPrint('shownCount ${widget.gameState.shownCount()}');
    debugPrint('totalQuestionCount ${widget.gameState.totalQuestionCount()}');
  }

  String _getTitle(GameState gameState) {
    if (gameState.completedAllQuestions()) {
      return 'Congratulations!';
    }
    final label = gameState.label;
    final level = gameState.level;
    return '$label at $level';
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle(widget.gameState);
    final statusFontSize =
        Theme.of(context).textTheme.headlineSmall?.fontSize ?? 20;
    if (widget.gameState.completedAllQuestions()) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'home',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
        body: Column(
          children: <Widget>[
            getScoreBar(widget.gameState, statusFontSize, context),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('You have completed all questions!'),
                    _IncorrectAnswersHeader(gameState: widget.gameState),
                    const SizedBox(height: 8),
                    Expanded(
                      child: getIncorrectAnswers(widget.gameState),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hasSubEntry = widget.gameState.currentSubEntry() != null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'home',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
        body: Column(
          children: [
            getScoreBar(widget.gameState, statusFontSize, context),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.gameState.firstEnglish(),
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
                            // enableSuggestions: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: hasSubEntry
                                  ? 'Kanji or Kana of intransitive verb'
                                  : 'Kanji or Kana',
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
                      if (hasSubEntry) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.gameState.subEntryEnglish()!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 300,
                            child: TextField(
                              autocorrect: false,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Kanji or Kana of transitive verb',
                              ),
                              onSubmitted: (String value) {
                                _onAnswer();
                              },
                              onChanged: (String value) {
                                setState(() {
                                  widget.gameState.updateSubUserAnswer(value);
                                  filled = widget.gameState.filled();
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
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
              final hasSub = widget.gameState.currentSubEntry() != null;
              final mainEnglish = widget.gameState.firstEnglish();
              final subEnglish = widget.gameState.subEntryEnglish();
              final actualAnswer = widget.gameState.answerForDisplay();
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Actual answer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasSub) ...[
                          Text('English (intransitive): $mainEnglish'),
                          Text('English (transitive): $subEnglish'),
                        ] else
                          Text(mainEnglish),
                        const SizedBox(height: 12),
                        Text('Answer: $actualAnswer'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          widget.gameState.skip();
                          widget.gameState.next();
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context)
                              .pushReplacement(createRoute(widget.gameState));
                        },
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: "I don't know",
            child: const Icon(Icons.question_mark),
          ),
        ]),
      ),
    );
  }

  Widget getIncorrectAnswers(GameState gameState) {
    if (gameState.incorrectCount() == 0) {
      return const Text('You got it all correct!');
    }

    final incorrectAnsweredQuestions = gameState.incorrectAnsweredQuestions();
    final List<ListTile> tiles = incorrectAnsweredQuestions.map((question) {
      return ListTile(
        tileColor: Theme.of(context).colorScheme.errorContainer,
        title: Center(
            child: Text(
                '${question.english.first} - ${question.kanji} (${question.kana})')),
      );
    }).toList();

    return Scrollbar(
      child: ListView.separated(
        itemCount: tiles.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => tiles[index],
      ),
    );
  }
}

class _IncorrectAnswersHeader extends StatelessWidget {
  const _IncorrectAnswersHeader({required this.gameState});
  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final count = gameState.incorrectCount();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Text('Incorrect answers ($count)'),
        ],
      ),
    );
  }
}
