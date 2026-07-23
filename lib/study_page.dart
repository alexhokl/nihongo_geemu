import 'package:flutter/material.dart';
import 'package:nihongo_geemu/game_state.dart';
import 'package:nihongo_geemu/widgets/button.dart';
import 'package:nihongo_geemu/widgets/jisho_link.dart';
import 'package:nihongo_geemu/widgets/route.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({
    super.key,
    required this.gameState,
  });

  final GameState gameState;

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  String _getTitle(GameState gameState) {
    final currentCount = gameState.shownCount();
    final totalCount = gameState.totalQuestionCount();
    final label = gameState.label;
    final level = gameState.level;
    return '$label at $level [$currentCount/$totalCount]';
  }

  void _onNext() {
    final hasMore = widget.gameState.next();
    if (!hasMore) {
      setState(() {});
      return;
    }
    Navigator.of(context).pushReplacement(createRoute(widget.gameState));
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle(widget.gameState);

    if (widget.gameState.studyCompleted()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Study complete'),
          backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'home',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.menu_book, size: 64),
                const SizedBox(height: 16),
                Text(
                  'You reviewed all ${widget.gameState.totalQuestionCount()} words!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final hasSubEntry = widget.gameState.currentSubEntry() != null;
    final progress =
        widget.gameState.shownCount() / widget.gameState.totalQuestionCount();

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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (hasSubEntry) ...[
                        _Prompt(
                          label: 'intransitive',
                          text: widget.gameState.firstEnglish(),
                        ),
                        _Prompt(
                          label: 'transitive',
                          text: widget.gameState.subEntryEnglish()!,
                        ),
                      ] else
                        _Prompt(
                          label: 'English',
                          text: widget.gameState.firstEnglish(),
                        ),
                      const SizedBox(height: 32),
                      if (hasSubEntry) ...[
                        _Answer(
                          label: 'Intransitive verb',
                          text: widget.gameState.answerFOrMainEntryDisplay(),
                        ),
                        _Answer(
                          label: 'Transitive verb',
                          text: widget.gameState.answerForSubEntryDisplay(),
                        ),
                      ] else
                        _Answer(
                          label: 'Answer',
                          text: widget.gameState.answerFOrMainEntryDisplay(),
                        ),
                      const SizedBox(height: 24),
                      JishoLink(
                        label: hasSubEntry
                            ? 'View intransitive on Jisho'
                            : 'View on Jisho',
                        word: widget.gameState.jishoWordMain(),
                      ),
                      if (hasSubEntry) ...[
                        const SizedBox(height: 8),
                        JishoLink(
                          label: 'View transitive on Jisho',
                          word: widget.gameState.jishoWordSub(),
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
            onPressed: _onNext,
            tooltip: 'next card',
            child: const Icon(Icons.play_arrow),
          ),
        ]),
      ),
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 24,
                color: colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
