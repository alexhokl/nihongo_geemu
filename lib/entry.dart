class Entry {
  final String kanji;
  final String kana;
  final List<String> english;
  final List<String> labels;
  final String linkedKanji;

  const Entry({
    required this.kanji,
    required this.kana,
    required this.english,
    required this.labels,
    required this.linkedKanji,
  });

  @override
    String toString() {
      return 'Entry{kanji: $kanji, kana: $kana, english: $english, labels: $labels, linked_kanji: $linkedKanji}';
    }
}
