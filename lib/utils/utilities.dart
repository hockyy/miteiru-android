import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadJson(String filename) async {
  String jsonString = await rootBundle.loadString('assets/$filename.json');
  return jsonDecode(jsonString);
}

const platform = MethodChannel('id.hocky.miteiru/clipboard');

Future<void> getClipboardData() async {
  try {
    final String data = await platform.invokeMethod('getClipboardData');
  } on PlatformException catch (e) {
  }
}
