import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadJson(String filename) async {
  String jsonString = await rootBundle.loadString('assets/$filename.json');
  return jsonDecode(jsonString);
}
