import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JishoLink extends StatelessWidget {
  const JishoLink({
    super.key,
    required this.label,
    required this.word,
  });

  final String label;
  final String word;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse('https://jisho.org/word/$word');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Error launching Jisho URL: $e');
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}