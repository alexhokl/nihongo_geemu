import 'package:nihogo_geemu/entry.dart';

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

