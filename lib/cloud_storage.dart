import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String?> getMD5HashFromBucket(String bucketName, String bucketPath) async {
  final url = 'https://storage.googleapis.com/storage/v1/b/$bucketName/o/$bucketPath?fields=md5Hash';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception('Failed to load metadata from GCP Cloud Storage: ${response.statusCode}');
  }

  final data = json.decode(response.body);
  final md5Hash = data['md5Hash'];
  if (md5Hash == null) {
    return null;
  }

  // decode base64 string
  final bytes = base64.decode(md5Hash);
  // convert bytes to hex string
  final hexString = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return hexString;
}

Future<String?> getMD5HashFromLocalFile(String localPath) async {
  final file = File(localPath);
  if (!file.existsSync()) {
    throw Exception('File does not exist: $localPath');
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

Future<void> downloadFile(String bucketName, String bucketPath, String localPath) async {
  final url = 'https://storage.googleapis.com/$bucketName/$bucketPath';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception('Failed to download file from GCP Cloud Storage: ${response.statusCode}');
  }

  File(localPath).writeAsBytesSync(response.bodyBytes);
}

Future<bool> hasConnection() async {
  final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
  return !connectivityResult.contains(ConnectivityResult.none);
}
