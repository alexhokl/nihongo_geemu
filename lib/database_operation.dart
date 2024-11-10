import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:nihogo_geemu/cloud_storage.dart';
import 'package:nihogo_geemu/entry.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

Future<List<Entry>> getAllEntries() async {
  final hasWiFi = await hasConnection();
  if (hasWiFi) {
    const bucketName = 'alexhokl_public';
    const bucketPath = 'japanese_vocab.db';
    final databaseLocalPath = await _getDatabaseLocalPath();
    final localDbMD5Hash = await getMD5HashFromLocalFile(databaseLocalPath);
    final remoteDbMD5Hash = await getMD5HashFromBucket(bucketName, bucketPath);
    if (localDbMD5Hash != remoteDbMD5Hash) {
      await downloadFile(bucketName, bucketPath, databaseLocalPath);
      debugPrint('Downloaded database file from $bucketPath to $databaseLocalPath');
    } else {
      debugPrint('Database file is up-to-date');
    }

  }

  final Database db = await _getDatabaseConnection();
  final List<Map<String, dynamic>> maps = await db.query('entries');
  await db.close();
  return List.generate(maps.length, (i) {
    return Entry(
      kanji: maps[i]['kanji'],
      kana: maps[i]['kana'],
      english: _parseArrayInJson(maps[i]['english']),
      labels: _parseArrayInJson(maps[i]['labels']),
    );
  });
}

Future<List<String>> getLabels() async {
  final Database db = await _getDatabaseConnection();
  final List<Map<String, Object?>> maps =
    await db.rawQuery(
      'SELECT DISTINCT l.value AS LabelName FROM Entries e, json_each(e.labels) l ORDER BY Value ASC');
  await db.close();
  return List.generate(maps.length, (i) {
    return maps[i]['LabelName'].toString();
  });
}

Future<Database> _getDatabaseConnection() async {
  var databaseFactory = databaseFactoryFfi;
  String dbPath = await _getDatabaseLocalPath();
  final isDbExist = await io.File(dbPath).exists();
  if (!isDbExist) {
    throw Exception("Database file does not exist: $dbPath");
  }
  return databaseFactory.openDatabase(
    dbPath,
  );
}

Future<String> _getDatabaseLocalPath() async {
  final io.Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  return p.join(appDocumentsDir.path, "databases", "vocab.db");
}

List<String> _parseArrayInJson(String jsonStr) {
  List<dynamic> listObject = json.decode(jsonStr);
  List<String> items = listObject.map((e) => e.toString()).toList();
  return items;
}

