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

