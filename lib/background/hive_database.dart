import 'package:hive/hive.dart';
import 'package:kana_kit/kana_kit.dart';

import '../utils/utilities.dart';

class HiveDatabase {
  HiveDatabase._();

  static final _waniKanji = Hive.box(name: 'wanikani-kanji');
  static final _waniRadical = Hive.box(name: 'wanikani-radical');
  static final _kanjidic = Hive.box(name: 'kanjidic', maxSizeMiB: 50);
  static const _kanakit = KanaKit();

  static initDatabases() async {
    if (_waniKanji.isEmpty || _waniRadical.isEmpty) {
      await Future.wait([
        loadJson("kanji"),
        loadJson("radical"),
      ]).then((List<Map<String, dynamic>> loadedFiles) {
        _waniKanji.putAll(loadedFiles[0]);
        _waniRadical.putAll(loadedFiles[1]);
      });
    }

    if (_kanjidic.isEmpty) {
      await Future.wait([
        loadJson("kanjidic"),
      ]).then((List<Map<String, dynamic>> loadedFiles) {
        for (var entry in loadedFiles[0]["characters"]) {
          _kanjidic.put(entry["literal"], entry);
        }
      });
    }
  }

  static queryKanji(String kanji) {
    return _waniKanji.get(kanji);
  }

  static queryRadical(String radical) {
    return _waniRadical.get(radical);
  }

  static queryKanjidic(String kanji) {
    return _kanjidic.get(kanji);
  }

  static currentKanjidicSize() {
    return _kanjidic.length;
  }

  static toHiragana(String content) {
    return _kanakit.toHiragana(content);
  }
}
