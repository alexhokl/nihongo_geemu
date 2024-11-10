import 'package:nihogo_geemu/entry.dart';

class Question extends Entry {
  String answer = "";
  bool correct = false;
  bool shown = false;

  Question({
    required super.kanji,
    required super.kana,
    required super.english,
    required super.labels,
  });
}
