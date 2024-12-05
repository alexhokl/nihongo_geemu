import 'dart:math';

import 'package:nihogo_geemu/question.dart';

class GameState {
  List<Question> questions;
  String level;
  String label;
  late int questionIndex;

  GameState({
    required this.questions,
    required this.level,
    required this.label,
  }) {
    questionIndex = _nextQuesitonIndex();
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
    questionIndex = _nextQuesitonIndex();
    if (questionIndex != -1) {
      questions[questionIndex].shown = true;
      return true;
    }
    return false;
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

  bool filled() {
    return questions[questionIndex].userInput.isNotEmpty;
  }

  bool isCorrectAnswer() {
    final kana = questions[questionIndex].kana.trim();
    final kanji = questions[questionIndex].kanji.trim();
    final userAnswer = questions[questionIndex].userInput;
    return userAnswer == kana || userAnswer == kanji;
  }

  String answerForDisplay() {
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

  correctCount() {
    return questions.where((element) => element.correct && element.answered).length;
  }

  incorrectCount() {
    return questions.where((element) => !element.correct && element.answered).length;
  }
}
