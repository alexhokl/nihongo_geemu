import 'package:nihogo_geemu/entry.dart';
import 'package:nihogo_geemu/question.dart';

List<Entry> getEntriesByLabel(List<Entry> entries, List<String> selectedLabels) {
  List<Entry> filteredEntries = [];
  for (var entry in entries) {
    // if entry has all specified labels
    if (selectedLabels.every((label) => entry.labels.contains(label))) {
      filteredEntries.add(entry);
    }
  }
  return filteredEntries;
}

List<Question> getQuestionsByVerbPairs(List<Entry> entries, String selectedLevel) {
  final verbPairEntries = entries.where(
    (entry) => entry.labels.contains(selectedLevel) && entry.labels.contains('verb pairs'),
  );

  final transitiveVerbEntries = entries.where(
    (entry) => entry.linkedKanji != '',
  );

  List<Question> questions = [];
  for (var entry in transitiveVerbEntries) {
    // find linked entry
    var linkedEntry = verbPairEntries.where(
      (e) => e.kanji == entry.linkedKanji,
    ).firstOrNull;

    if (linkedEntry == null) {
      continue; // skip if no linked entry found
    }

    var question = Question(
      kanji: linkedEntry.kanji,
      kana: linkedEntry.kana,
      english: linkedEntry.english,
      labels: linkedEntry.labels,
      linkedKanji: linkedEntry.linkedKanji,
    );
    question.subEntry = entry;
    questions.add(question);
  }

  return questions;
}

void setSelected(List<bool> isSelected, int index) {
  for (int i = 0; i < isSelected.length; i++) {
    if (i == index) {
      isSelected[i] = !isSelected[index];
    }
    else {
      isSelected[i] = false;
    }
  }
}

