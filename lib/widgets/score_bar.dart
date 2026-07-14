import 'package:flutter/material.dart';
import 'package:nihongo_geemu/game_state.dart';

Widget getScoreBar(GameState gameState, double fontSize, BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final correct = gameState.correctCount();
  final incorrect = gameState.incorrectCount();
  final total = gameState.totalQuestionCount();
  final remaining = total - gameState.shownCount();

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _SegmentedProgressBar(
        correct: correct,
        incorrect: incorrect,
        remaining: remaining,
        colorScheme: colorScheme,
      ),
      const SizedBox(height: 8),
      _PillRow(
        correct: correct,
        incorrect: incorrect,
        total: total,
        fontSize: fontSize,
        colorScheme: colorScheme,
      ),
    ],
  );
}

class _SegmentedProgressBar extends StatelessWidget {
  const _SegmentedProgressBar({
    required this.correct,
    required this.incorrect,
    required this.remaining,
    required this.colorScheme,
  });

  final int correct;
  final int incorrect;
  final int remaining;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            if (correct > 0)
              Expanded(
                flex: correct,
                child:
                    ColoredBox(color: colorScheme.primary, child: SizedBox.expand()),
              ),
            if (incorrect > 0)
              Expanded(
                flex: incorrect,
                child:
                    ColoredBox(color: colorScheme.error, child: SizedBox.expand()),
              ),
            if (remaining > 0)
              Expanded(
                flex: remaining,
                child: ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: SizedBox.expand(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PillRow extends StatelessWidget {
  const _PillRow({
    required this.correct,
    required this.incorrect,
    required this.total,
    required this.fontSize,
    required this.colorScheme,
  });

  final int correct;
  final int incorrect;
  final int total;
  final double fontSize;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Pill(
          icon: Icons.check,
          count: correct,
          label: 'correct',
          iconColor: colorScheme.primary,
          background: colorScheme.surfaceContainerLow,
          fontSize: fontSize,
        ),
        _Pill(
          icon: Icons.close,
          count: incorrect,
          label: 'incorrect',
          iconColor: colorScheme.error,
          background: colorScheme.surfaceContainerLow,
          fontSize: fontSize,
        ),
        _Pill(
          icon: Icons.stars,
          count: total,
          label: 'total',
          iconColor: colorScheme.onSurfaceVariant,
          background: colorScheme.surfaceContainerLow,
          fontSize: fontSize,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.count,
    required this.label,
    required this.iconColor,
    required this.background,
    required this.fontSize,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color iconColor;
  final Color background;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize * 0.9, color: iconColor),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: fontSize * 0.7)),
        ],
      ),
    );
  }
}
