import 'package:flutter/material.dart';
import 'package:nihogo_geemu/cloud_storage.dart';
import 'package:nihogo_geemu/data_operations.dart';
import 'package:nihogo_geemu/database_operation.dart';
import 'package:nihogo_geemu/entry.dart';
import 'package:nihogo_geemu/local_storage.dart';
import 'package:nihogo_geemu/question.dart';
import 'package:nihogo_geemu/question_page.dart';
import 'package:nihogo_geemu/widgets/button.dart';
import 'package:nihogo_geemu/widgets/snack_bar.dart';

void main() {
  runApp(const NihongoGeemu());
}

class NihongoGeemu extends StatelessWidget {
  const NihongoGeemu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japanese-English Translation Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const GameHomePage(title: '日本語ゲーム'),
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
  List<Entry> entries = [];
  final List<String> labels = ['Nouns', 'Verbs', 'Adjectives', 'Adverbs', 'Expressions', 'Conjunctions'];
  final List<String> preSelectedLabels = ["Nouns"];
  List<bool> isSelectedLabel = [];
  final List<String> levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
  final List<String> preSelectedLevels = ['N5'];
  List<bool> isSelectedLevel = [];
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    _loadEntriesAndLabels();
    isSelectedLevel = List.generate(levels.length, (index) => preSelectedLevels.contains(levels[index]));
    isSelectedLabel = List.generate(labels.length, (index) => preSelectedLabels.contains(labels[index]));
  }

  Future<void> _loadEntriesAndLabels() async {
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
    final List<Entry> loadedEntries =
      hasDatabaseFile ? await getAllEntries() : [];

    setState(() {
      if (localDbMD5Hash == null && !hasWiFi) {
        noInternetConnectinoSnackBar(context);
      }
      else if (!hasWiFi) {
        workingOfflineSnackBar(context);
      }
      entries = loadedEntries;
    });
  }

  _onStartGame() {
    List<String> selectedLabels = [];
    for (int i = 0; i < isSelectedLabel.length; i++) {
      if (isSelectedLabel[i]) {
        selectedLabels.add(labels[i]);
      }
    }
    for (int i = 0; i < isSelectedLevel.length; i++) {
      if (isSelectedLevel[i]) {
        selectedLabels.add(levels[i]);
      }
    }
    questions = getEntriesByLabel(entries, selectedLabels).map((entry) => Question(
      kanji: entry.kanji,
      kana: entry.kana,
      english: entry.english,
      labels: entry.labels,
    )).toList();
    if (questions.isEmpty) {
      noQuestionsFoundSnackBar(context);
      return;
    }
    Navigator.of(context).push(_createRoute(questions));
  }

  Route _createRoute(List<Question> questions) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(questions: questions),
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
