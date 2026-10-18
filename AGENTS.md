# AGENTS.md — Nihongo Geemu

This file provides guidance for agentic coding tools (AI assistants, bots) working in this repository.

---

## Project Overview

**Nihongo Geemu** is a Flutter application for Japanese vocabulary study. It is a multi-platform app
(Android, iOS, macOS, Linux, Windows) written entirely in Dart using Flutter's Material 3 framework.

- **Language:** Dart (SDK `^3.12.0`)
- **Framework:** Flutter, Material 3 (CI builds with the private `flutter:3.47.7` image)
- **Task runner:** [go-task](https://taskfile.dev/) (`Taskfile.yml`) — use `task <name>`
- **Package manager:** `pub` (`pubspec.yaml`)

---

## Build, Lint, and Test Commands

### Build

```bash
task mac            # flutter build macos and install in /Applications
task apk            # flutter build apk
```

### Run

```bash
task run-flutter    # flutter run on macOS
task run-android    # Run on first connected Android device
```

`mac`, `apk`, `run-flutter`, `run-android`, the APK signing key tasks and
`tag` are included from `../flutter-helper/taskfiles/flutter.yml`, which needs
a sibling checkout of flutter-helper.

### Tests

```bash
# Run all tests with coverage
task test
# Equivalent:
flutter test --no-pub --coverage

# Run a single test FILE
flutter test test/sqflite_ffi_test.dart

# Run a single test by NAME pattern (matches substring)
flutter test --name "simple sqflite example"

# Run a single test file with coverage
flutter test --no-pub --coverage test/sqflite_ffi_test.dart
```

Test files live under `test/`. The test framework is `flutter_test` (part of the Flutter SDK).
Desktop SQLite tests use `sqflite_common_ffi` with an in-memory database.

### Lint and Static Analysis

```bash
task lint           # dart fix --dry-run  (shows suggestions, no changes)
task lint-fix       # dart fix --apply    (applies auto-fixes)
flutter analyze     # static analysis (surfaces warnings/errors)
dart format lib/ test/   # auto-format source files
```

Lint configuration is in `analysis_options.yaml`, which includes the shared
`package:flutter_helper/analysis_options.yaml` (`flutter_lints` 6 plus common
excludes) with no overrides.

### Coverage

```bash
task coverage       # renders lcov HTML and opens it in the browser
```

---

## Code Style Guidelines

### Imports

- Always use `package:` URI scheme — **never** relative paths (`../`).
- Internal package imports: `package:nihongo_geemu/<file>.dart`
- Use `as` aliases when disambiguating packages:
  ```dart
  import 'dart:io' as io;
  import 'package:path/path.dart' as p;
  import 'package:sqflite/sqflite.dart' as sqflite;
  ```
- `dart:` core library imports sit alongside `package:` imports with no enforced ordering.

### Naming Conventions

| Entity | Convention | Example |
|---|---|---|
| Classes | `PascalCase` | `GameState`, `QuestionPage` |
| Private classes / state | `_PascalCase` | `_GameHomePageState` |
| Functions and methods | `camelCase` | `getAllEntries()`, `getButtonStack()` |
| Private methods | `_camelCase` | `_setDatabase()`, `_loadEntries()` |
| Variables and fields | `camelCase` | `selectedLevel`, `questionIndex` |
| Constants | `camelCase` (not `SCREAMING_SNAKE_CASE`) | `const possibleLevels = [...]` |
| Files | `snake_case.dart` | `game_state.dart`, `question_page.dart` |

### Formatting

- Uses `dart format` (no separate config required).
- 2-space indentation (Dart default).
- Trailing commas on multi-line argument lists and collection literals (helps `dart format`).
- `const` constructors wherever possible.

### Types

- Dart's sound null-safety is fully enabled (Dart 3+).
- Prefer explicit return types on public functions and methods.
- Use `late` sparingly — only when initialization is deferred but guaranteed before use.
- Prefer `final` for local variables that are not reassigned.
- Use `List<T>`, `Map<K,V>`, etc. rather than raw `dynamic` where possible.

### Error Handling

- **Fatal / unrecoverable errors:** throw `Exception('descriptive message')` directly.
  ```dart
  throw Exception("Database file does not exist: $dbPath");
  throw Exception('Failed to load metadata: ${response.statusCode}');
  ```
- **Recoverable / optional errors:** return `null` from a nullable return type.
  ```dart
  Future<String?> getMD5HashFromLocalFile(String localPath) async { ... return null; }
  ```
- **Silent failures:** wrap in `try/catch`, log with `debugPrint`, and return `null`.
  ```dart
  try {
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  } catch (e) {
    debugPrint('Error calculating MD5 hash: $e');
    return null;
  }
  ```
- Use `debugPrint` (not `print`) for all development/debug logging.
- No custom exception classes — the built-in `Exception` is sufficient.

---

## File and Directory Organization

```
lib/
├── main.dart               # App entry point + home page StatefulWidget
├── entry.dart              # Data model: Entry (vocabulary word)
├── question.dart           # Data model: Question (extends Entry)
├── game_state.dart         # Business logic: game state management
├── question_page.dart      # UI: question/game screen
├── data_operations.dart    # Pure functions: filtering and building questions
├── database_operation.dart # SQLite DB access layer (platform-aware)
├── cloud_storage.dart      # GCS HTTP client (hash check + download)
├── local_storage.dart      # Local file path + MD5 hash utilities
└── widgets/
    ├── button.dart         # Reusable floating button stack widget
    ├── route.dart          # Slide page transition builder
    └── snack_bar.dart      # Named snack bar helpers (wrap flutter_helper's showMessage)
test/
├── widget_test.dart        # Widget smoke test (WidgetTester)
└── sqflite_ffi_test.dart   # SQLite FFI unit tests (in-memory DB)
```

**Organization principles:**
- One class or one logical group of related functions per file.
- Pages/screens live at `lib/` root level (not in a `screens/` or `pages/` subdirectory).
- Reusable stateless UI helpers go in `lib/widgets/`.
- Business logic, data models, and infrastructure are cleanly separated from each other and from UI.
- No barrel/index files (`index.dart`).
- The `widgets/` subdirectory is currently the only subdirectory under `lib/`.

---

## Architecture Patterns

- **StatefulWidget + State** pattern for screens that manage mutable state.
- **Pure functions** for data transformation (`data_operations.dart`).
- **Async/await** throughout for I/O (database, HTTP, file system).
- **Platform detection** at runtime for SQLite backend selection:
  - Android/iOS → native `sqflite`
  - Desktop → `sqflite_common_ffi`
- Business logic (`GameState`) is a plain Dart class, not tightly coupled to widgets.
- State is propagated via `setState()` — no external state management library (no Provider, Riverpod, Bloc, etc.).

---

## Dependencies

Key runtime packages:

| Package | Purpose |
|---|---|
| `sqflite` / `sqflite_common_ffi` | SQLite (mobile / desktop) |
| `path_provider` | Platform-specific file paths |
| `http` | HTTP client for GCS downloads |
| `crypto` | MD5 hash computation |
| `url_launcher` | Opening Jisho links |
| `flutter_helper` | Shared helpers (see below) |

Connectivity is checked with a DNS lookup of `storage.googleapis.com` in
`cloud_storage.dart`; there is no connectivity package.

### flutter_helper

Shared UI infrastructure comes from the `flutter_helper` package
(github.com/alexhokl/flutter-helper, pinned by tag in `pubspec.yaml`):
`themesFromSeed`, `showMessage`, `GitCommitFooter`/`BuildInfo` and the lint
configuration. Fix or extend those there rather than copying code into this
app.

---

## Notes for AI Agents

- The codebase has a few intentional typos in identifiers that have been left in place
  (e.g., `answeredCorreclty`, `_nextQuesitonIndex`, `noInternetConnectinoSnackBar`).
  Do not rename these without explicit instruction, as it would be a breaking change.
- CI is Google Cloud Build (`cloudbuild.yaml`), triggered by a `0.1.x` tag
  (`task tag`): it builds a signed release APK and uploads it to
  `gs://alexhokl_public/apk/`. It does not run the tests, so run
  `flutter analyze` and `task test` locally before finalising changes.
- The database file (`.db`) is downloaded from Google Cloud Storage at runtime; it is
  not committed to the repository.
