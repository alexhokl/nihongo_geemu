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

## Android Device Setup

### Enable Developer Options

1. On the Android device, go to `Settings` → `About phone`
2. Tap **Build number** 7 times until you see "You are now a developer!"
3. Go back to `Settings` → **Developer options**
4. Enable **USB debugging**

### Pair an Android device using Android Studio

1. On the Android device, go to `Settings` → `Developer options` → enable **Wireless debugging**
2. Tap **Pair device with pairing code** — note the IP address, port, and pairing code shown
3. In Android Studio, open the device dropdown in the toolbar and select **Pair Devices Using Wi-Fi**
4. Click **Pair using pairing code** and enter the IP address, port, and pairing code from the device
5. Once paired, the device will appear in the device list and can be selected for running/debugging

### Uninstall the app from a connected Android device using adb

To remove the existing installation (required when the signing key has changed):

```sh
adb uninstall com.example.nihongo_geemu
```

### Install the app on a connected Android device using adb

Build the APK with `task apk`, then ensure the device is connected via USB with
USB debugging enabled and appears in:

```sh
adb devices
```

Then install the APK:

```sh
adb install build/app/outputs/flutter-apk/app-release.apk
```

If upgrading an existing installation signed with the same key, use the `-r` flag:

```sh
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
