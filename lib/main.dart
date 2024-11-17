import 'package:flutter/material.dart';
import 'package:nihogo_geemu/cloud_storage.dart';
import 'package:nihogo_geemu/data_operations.dart';
import 'package:nihogo_geemu/database_operation.dart';
import 'package:nihogo_geemu/entry.dart';
import 'package:nihogo_geemu/local_storage.dart';
import 'package:nihogo_geemu/question.dart';
import 'package:nihogo_geemu/question_page.dart';
import 'package:nihogo_geemu/theme.dart';
import 'package:nihogo_geemu/widgets/button.dart';
import 'package:nihogo_geemu/widgets/snack_bar.dart';

void main() {
  runApp(const NihongoGeemu());
}

class NihongoGeemu extends StatelessWidget {
  const NihongoGeemu({super.key});

  @override
  Widget build(BuildContext context) {
    const title = '日本語ゲーム';
    return MaterialApp(
      title: title,
      home: const GameHomePage(title: title),
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: ThemeMode.light,
    );
  }
}

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key, required this.title});

  final String title;

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  final List<String> preSelectedLabels = ["Nouns"];
  final List<String> preSelectedLevels = ['N5'];
  List<Entry> entries = [];
  List<Question> questions = [];
  List<String> labels = [];
  List<bool> isSelectedLabel = [];
  List<String> levels = [];
  List<bool> isSelectedLevel = [];

  @override
  void initState() {
    super.initState();
    _setDatabase();
  }

  // Future<void> _loadLevels() async {
  //   await Future.delayed(Duration(seconds: 5));
  //   setState(() {
  //     levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
  //     isSelectedLevel =
  //       List.generate(
  //         levels.length,
  //         (index) => preSelectedLevels.contains(levels[index]));
  //   });
  // }
  //
  // Future<void> _loadLabels() async {
  //   await Future.delayed(Duration(seconds: 5));
  //   setState(() {
  //     labels = ['Nouns', 'Verbs', 'Adjectives', 'Adverbs', 'Expressions', 'Conjunctions'];
  //     isSelectedLabel =
  //       List.generate(
  //         labels.length,
  //         (index) => preSelectedLabels.contains(labels[index]));
  //   });
  // }

  Future<void> _setDatabase() async {
    final databaseLocalPath = await getDatabaseLocalPath();
    final localDbMD5Hash = await getMD5HashFromLocalFile(databaseLocalPath);
    final hasWiFi = await hasConnection();
    final hasDatabaseFile =
      await ensureDatabaseFile(
        databaseLocalPath,
        localDbMD5Hash,
        hasWiFi,
        'alexhokl_public',
        'japanese_vocab.db');

    await _loadEntries(hasDatabaseFile, localDbMD5Hash, hasWiFi);
    // await _loadLevels();
    // await _loadLabels();
  }

  Future<void> _loadEntries(bool hasDatabaseFile, String? localDbMD5Hash, bool hasWiFi) async {
    final hasWiFi = await hasConnection();
    final List<Entry> loadedEntries =
      hasDatabaseFile ? await getAllEntries() : [];

    final loadedLevels = getLevelsFromEntries(loadedEntries);
    final loadedLabels = getLabelFromEntries(loadedEntries);
    final isSelectedLevel =
      List.generate(
        loadedLevels.length,
        (index) => preSelectedLevels.contains(loadedLevels[index]));
    final isSelectedLabel =
      List.generate(
        loadedLabels.length,
        (index) => preSelectedLabels.contains(loadedLabels[index]));

    setState(() {
      if (localDbMD5Hash == null && !hasWiFi) {
        noInternetConnectinoSnackBar(context);
      }
      else if (!hasWiFi) {
        workingOfflineSnackBar(context);
      }
      entries = loadedEntries;
      levels = loadedLevels;
      labels = loadedLabels;
      this.isSelectedLevel = isSelectedLevel;
      this.isSelectedLabel = isSelectedLabel;
    });
  }

  List<String> getLevelsFromEntries(List<Entry> entries) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    return
      entries
        .map((entry) => entry.labels)
        .expand((element) => element)
        .toSet()
        .where((element) => levels.contains(element))
        .toList();
  }

  List<String> getLabelFromEntries(List<Entry> entries) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    return
      entries
        .map((entry) => entry.labels)
        .expand((element) => element)
        .toSet()
        .where((element) => !levels.contains(element))
        .toList();
  }

  _onStartGame() {
    String selectedLabel = labels[isSelectedLabel.indexOf(true)];
    String selectedLevel = levels[isSelectedLevel.indexOf(true)];
    questions = getEntriesByLabel(entries, [selectedLevel, selectedLabel]).map((entry) => Question(
      kanji: entry.kanji,
      kana: entry.kana,
      english: entry.english,
      labels: entry.labels,
    )).toList();
    if (questions.isEmpty) {
      noQuestionsFoundSnackBar(context);
      return;
    }
    Navigator.of(context).push(_createRoute(questions, selectedLevel, selectedLabel));
  }

  Route _createRoute(List<Question> questions, String selectedLevel, String selectedLabel) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
        QuestionPage(
          questions: questions,
          selectedLevel: selectedLevel,
          selectedLabel: selectedLabel
        ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('JLPT Level: '),
                  createToggleButtons(levels, isSelectedLevel, (int index) {
                    setState(() {
                      setSelected(isSelectedLevel, index);
                    });
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: createToggleButtons(labels, isSelectedLabel, (int index) {
                setState(() {
                  setSelected(isSelectedLabel, index);
                });
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onStartGame,
        tooltip: 'start game',
        child: const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
