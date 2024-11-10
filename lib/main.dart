import 'package:flutter/material.dart';
import 'package:nihogo_geemu/data_operations.dart';
import 'package:nihogo_geemu/database_operation.dart';
import 'package:nihogo_geemu/entry.dart';
import 'package:nihogo_geemu/question.dart';
import 'package:nihogo_geemu/question_page.dart';

void main() {
  runApp(const NihongoGeemu());
}

class NihongoGeemu extends StatelessWidget {
  const NihongoGeemu({super.key});

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    List<Entry> loadedEntries = await getAllEntries();
    setState(() {
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ToggleButtons(
              isSelected: isSelectedLevel,
              borderRadius: BorderRadius.circular(8.0),
              children: levels.map((level) => Text(level)).toList(),
              onPressed: (int index) {
                setState(() {
                  isSelectedLevel[index] = !isSelectedLevel[index];
                });
              },
            ),
            ToggleButtons(
              isSelected: isSelectedLabel,
              borderRadius: BorderRadius.circular(8.0),
              children: labels.map((label) => Text(label)).toList(),
              onPressed: (int index) {
                setState(() {
                  isSelectedLabel[index] = !isSelectedLabel[index];
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
