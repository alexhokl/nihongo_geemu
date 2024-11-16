import 'package:flutter/material.dart';
import 'package:nihogo_geemu/cloud_storage.dart';
import 'package:nihogo_geemu/data_operations.dart';
import 'package:nihogo_geemu/database_operation.dart';
import 'package:nihogo_geemu/entry.dart';
import 'package:nihogo_geemu/local_storage.dart';
import 'package:nihogo_geemu/question.dart';
import 'package:nihogo_geemu/question_page.dart';

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
      home: const GameHomePage(title: 'Japanese-English Translation Test'),
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
    List<Entry> loadedEntries = [];
    if (hasWiFi) {
      const bucketName = 'alexhokl_public';
      const bucketPath = 'japanese_vocab.db';
      if (localDbMD5Hash != null) {
        final remoteDbMD5Hash = await getMD5HashFromBucket(bucketName, bucketPath);
        if (remoteDbMD5Hash == null) {
          debugPrint('Failed to get MD5 hash from the remote database file');
          loadedEntries = await getAllEntries();
        }
        if (remoteDbMD5Hash == localDbMD5Hash) {
          debugPrint('Database file is up-to-date');
          loadedEntries = await getAllEntries();
        }
      }
      await downloadFile(bucketName, bucketPath, databaseLocalPath);
      debugPrint('Downloaded database file from $bucketPath to $databaseLocalPath');
      loadedEntries = await getAllEntries();
    }
    else if (localDbMD5Hash != null) {
      loadedEntries = await getAllEntries();
    }
    else {
      loadedEntries = [];
    }
    setState(() {
      if (localDbMD5Hash == null && !hasWiFi) {
        const warningMessage = 'Please connect to the internet to download the question database.';
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text(warningMessage)));
      }
      else if (!hasWiFi) {
        const infoMessage = 'No internet connection. Using cached question database.';
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text(infoMessage)));
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
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Sorry no questions found for the selected labels')));
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
            ToggleButtons(
              isSelected: isSelectedLevel,
              borderRadius: BorderRadius.circular(8.0),
              children: levels.map((level) => Text(level)).toList(),
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < isSelectedLevel.length; i++) {
                     if (i == index) {
                        isSelectedLevel[i] = !isSelectedLevel[index];
                     }
                     else {
                        isSelectedLevel[i] = false;
                     }
                  }
                });
              },
            ),
            ToggleButtons(
              isSelected: isSelectedLabel,
              borderRadius: BorderRadius.circular(8.0),
              children: labels.map((label) => Text(label)).toList(),
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < isSelectedLabel.length; i++) {
                     if (i == index) {
                        isSelectedLabel[i] = !isSelectedLabel[index];
                     }
                     else {
                        isSelectedLabel[i] = false;
                     }
                  }
                });
              },
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
