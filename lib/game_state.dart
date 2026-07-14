import 'dart:math';

import 'package:nihongo_geemu/entry.dart';
import 'package:nihongo_geemu/question.dart';

class GameState {
  List<Question> questions;
  String level;
  String label;
  String subUserInput = "";
  final bool studyMode;

  late int questionIndex;
  late final List<int> _studyOrder;
  late int _studyOrderPosition;

  GameState({
    required this.questions,
    required this.level,
    required this.label,
    this.studyMode = false,
  }) {
    if (studyMode) {
      _studyOrder = List.generate(questions.length, (i) => i)..shuffle();
      _studyOrderPosition = 0;
      questionIndex = _studyOrder.isEmpty ? -1 : _studyOrder[0];
    } else {
      questionIndex = _nextQuesitonIndex();
    }
    if (questionIndex < 0) {
      throw Exception('No questions found xx');
    }
    questions[questionIndex].shown = true;
  }

  void answeredCorreclty() {
    questions[questionIndex].correct = true;
    questions[questionIndex].answered = true;
  }

  void skip() {
    questions[questionIndex].correct = false;
    questions[questionIndex].answered = true;
  }

  bool next() {
    if (studyMode) {
      _studyOrderPosition++;
      if (_studyOrderPosition >= _studyOrder.length) {
        return false;
      }
      questionIndex = _studyOrder[_studyOrderPosition];
      questions[questionIndex].shown = true;
      return true;
    }
    questionIndex = _nextQuesitonIndex();
    if (questionIndex != -1) {
      questions[questionIndex].shown = true;
      return true;
    }
    return false;
  }

  bool studyCompleted() {
    return _studyOrderPosition >= _studyOrder.length;
  }

  int shownCount() {
    return questions.where((element) => element.shown).length;
  }

  int totalQuestionCount() {
    return questions.length;
  }

  void updateUserAnswer(String userInput) {
    questions[questionIndex].userInput = userInput.trim();
  }

  void updateSubUserAnswer(String userInput) {
    subUserInput = userInput.trim();
  }

  bool filled() {
    final mainFilled = questions[questionIndex].userInput.isNotEmpty;
    final subEntry = questions[questionIndex].subEntry;
    if (subEntry != null) {
      return mainFilled && subUserInput.isNotEmpty;
    }
    return mainFilled;
  }

  bool isCorrectAnswer() {
    final kana = questions[questionIndex].kana.trim();
    final kanji = questions[questionIndex].kanji.trim();
    final userAnswer = questions[questionIndex].userInput;
    final mainCorrect = userAnswer == kana || userAnswer == kanji;

    final subEntry = questions[questionIndex].subEntry;
    if (subEntry != null) {
      final subKana = subEntry.kana.trim();
      final subKanji = subEntry.kanji.trim();
      final subCorrect = subUserInput == subKana || subUserInput == subKanji;
      return mainCorrect && subCorrect;
    }
    return mainCorrect;
  }

  Entry? currentSubEntry() {
    return questions[questionIndex].subEntry;
  }

  String? subEntryEnglish() {
    return questions[questionIndex].subEntry?.english.first;
  }

  String answerForDisplay() {
    final main = answerFOrMainEntryDisplay();
    if (currentSubEntry() != null) {
      final sub = answerForSubEntryDisplay();
      return '$main / $sub';
    }
    return main;
  }

  String answerFOrMainEntryDisplay() {
    final kana = questions[questionIndex].kana.trim();
    final kanji = questions[questionIndex].kanji.trim();
    if (kana.isNotEmpty && kanji.isNotEmpty) {
      return '$kanji ($kana)';
    }
    if (kanji.isNotEmpty) {
      return kanji;
    }
    return kana;
  }

  String answerForSubEntryDisplay() {
    final subEntry = questions[questionIndex].subEntry;
    if (subEntry == null) {
      return '';
    }
    final kana = subEntry.kana.trim();
    final kanji = subEntry.kanji.trim();
    if (kana.isNotEmpty && kanji.isNotEmpty) {
      return '$kanji ($kana)';
    }
    if (kanji.isNotEmpty) {
      return kanji;
    }
    return kana;
  }

  String firstEnglish() {
    return questions[questionIndex].english.first;
  }

  bool completedAllQuestions() {
    return questions.every((element) => element.answered);
  }

  int _nextQuesitonIndex() {
    if (completedAllQuestions()) {
      return -1;
    }
    Random random = Random();
    int questionIndex = random.nextInt(questions.length);
    while (questions[questionIndex].shown) {
      questionIndex = random.nextInt(questions.length);
    }
    return questionIndex;
  }

  int correctCount() {
    return questions
        .where((element) => element.correct && element.answered)
        .length;
  }

  int incorrectCount() {
    return questions
        .where((element) => !element.correct && element.answered)
        .length;
  }

  List<Question> incorrectAnsweredQuestions() {
    return questions
        .where((element) => !element.correct && element.answered)
        .toList();
  }
}
