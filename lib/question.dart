import 'package:nihogo_geemu/entry.dart';

class Question extends Entry {
  String userInput = "";
  bool correct = false;
  bool shown = false;
  bool answered = false;

  // optional sub entry for verb pairs
  Entry? subEntry;

  Question({
    required super.kanji,
    required super.kana,
    required super.english,
    required super.labels,
    required super.linkedKanji,
  });
}
