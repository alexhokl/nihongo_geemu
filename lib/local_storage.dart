import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> getDatabaseLocalPath() async {
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  return p.join(appDocumentsDir.path, "databases", "vocab.db");
}

Future<String?> getMD5HashFromLocalFile(String localPath) async {
  final file = File(localPath);
  if (!file.existsSync()) {
    debugPrint('local database file does not exist: $localPath');
    return null;
  }

  try {
    final bytes = await file.readAsBytes();
    final digest = md5.convert(bytes);
    return digest.toString();
  } catch (e) {
    debugPrint('Error in calculating MD5 hash: $e');
    return null;
  }
}


