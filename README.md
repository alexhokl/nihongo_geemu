# nihongo_geemu

This is a simple Japanese learning game.

## Architecture

It loads a dictionary of words from a local SQLite database. When the
application starts, it checks the hash of the local database file and if it is
different from the hash of the remote database file on Google Cloud Storage
bucket, it downloads the remote database file and replaces the local database.
Thus, if the application does not have an internet connection and it has a local
database downloaded previously, it will still work offline.

The SQLite database is created with CLI tool
[japanese-notes-parser](https://github.com/alexhokl/japanese-notes-parser) and
it parses notes on [this
markdown](https://github.com/alexhokl/notes/blob/master/spoken_languages/japanese/vocabulary.md).

## Download APK for Android

- [nihongo_geemu.apk](https://storage.googleapis.com/alexhokl_public/nihongo_geemu.apk)
