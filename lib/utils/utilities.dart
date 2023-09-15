import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadJson() async {
  String jsonString = await rootBundle.loadString('assets/my_data.json');
  return jsonDecode(jsonString);
}

const platform = MethodChannel('id.hocky.miteiru/clipboard');

Future<void> getClipboardData() async {
  try {
    final String data = await platform.invokeMethod('getClipboardData');
    print("Received clipboard data: $data");
  } on PlatformException catch (e) {
    print("Failed to get clipboard data: '${e.message}'.");
  }
}
