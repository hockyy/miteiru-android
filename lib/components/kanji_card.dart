import 'package:flutter/material.dart';
import 'package:miteiru/background/hive_database.dart';
import 'package:miteiru/components/radical_component.dart';
import 'group_component.dart';

class KanjiCard extends StatelessWidget {
  final String kanji;
  final Map<String, dynamic> kanjiData;
  final List<Map<String, dynamic>> radicalData;
  final Map<String, dynamic> kanjiAnalysis;

  const KanjiCard({
    Key? key,
    required this.kanji,
    required this.kanjiData,
    required this.radicalData,
    required this.kanjiAnalysis,
  }) : super(key: key);

  TextSpan buildStyledText(String content, Color color, FontWeight fontWeight) {
    return TextSpan(
      text: content,
      style: TextStyle(color: color, fontWeight: fontWeight),
    );
  }

  List<Widget> generateBubbleBox(Map<String, dynamic> kanjiAnalysis) {
    final jlpt = kanjiAnalysis['misc']['jlptLevel'];
    final grade = kanjiAnalysis['misc']['grade'];
    final frequency = kanjiAnalysis['misc']['frequency'];
    final strokeCounts = kanjiAnalysis['misc']['strokeCounts']?[0];

    return [
      if (jlpt != null) Chip(label: Text('JLPT N$jlpt')),
      if (grade != null) Chip(label: Text('Grade $grade')),
      if (frequency != null) Chip(label: Text('Top $frequency kanji')),
      if (strokeCounts != null)
        Chip(label: Text('$strokeCounts writing strokes')),
    ];
  }

  List<Map<String, dynamic>> generateGroups(
      Map<String, dynamic> kanjiAnalysis) {
    final List<dynamic> groups = kanjiAnalysis['readingMeaning']['groups'];

    return groups.map((group) {
      final onyomi = (group['readings'] as List)
          .where((val) => val['type'] == 'ja_on')
          .map((val) =>
              "${val['value']}『${HiveDatabase.toHiragana(val['value'])}』")
          .toList();

      final kunyomi = (group['readings'] as List)
          .where((val) => val['type'] == 'ja_kun')
          .map((val) => val['value'])
          .toList();

      final meanings = (group['meanings'] as List)
          .where((val) => val['lang'] == 'en')
          .map((val) => val['value'])
          .toList();

      // You will need to implement how you want to open these external links in Flutter
      final urls = [
        'https://jisho.org/search/${kanjiAnalysis['literal']}%20%23kanji',
        'https://www.wanikani.com/kanji/${kanjiAnalysis['literal']}',
        'https://tangorin.com/kanji/${kanjiAnalysis['literal']}',
        'https://kanji.koohii.com/study/kanji/${kanjiAnalysis['literal']}',
      ];
      return {
        'Meanings': meanings,
        '音読み (Onyomi)': onyomi,
        '訓読み (Kunyomi)': kunyomi,
        'Urls': urls,
      };
    }).toList();
  }

  Widget buildMnemonic(String mnemonic) {
    List<InlineSpan> parsedText = [];
    final RegExp regex = RegExp(r'<(\w+)>(.*?)</\1>');
    var matches = regex.allMatches(mnemonic);
    int lastIndex = 0;

    for (var match in matches) {
      final tag = match.group(1) ?? "";
      final innerContent = match.group(2) ?? "";

      parsedText
          .add(TextSpan(text: mnemonic.substring(lastIndex, match.start)));

      if (tag == "radical") {
        parsedText
            .add(buildStyledText(innerContent, Colors.blue, FontWeight.bold));
      } else if (tag == "kanji") {
        parsedText.add(buildStyledText(innerContent,
            const Color.fromRGBO(225, 49, 160, 1), FontWeight.bold));
      }

      lastIndex = match.end;
    }

    parsedText.add(TextSpan(text: mnemonic.substring(lastIndex)));

    return RichText(
      text: TextSpan(
        children: parsedText,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String mnemonic = kanjiData.isNotEmpty ? kanjiData['meaning_mnemonic'] : "";
    var bubbleBox = generateBubbleBox(kanjiAnalysis);
    var groups = generateGroups(kanjiAnalysis);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              // Take the maximum width its parent can give
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(186, 237, 255, 0.3),
                border: Border.all(
                  color: Colors.blue,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  kanji,
                  style: const TextStyle(fontSize: 70),
                ),
              ),
            ),
            const Divider(),
            Container(
              alignment: AlignmentDirectional.topStart,
              child: Wrap(spacing: 10, children: bubbleBox),
            ),
            const Divider(),
            Container(
              alignment: AlignmentDirectional.topStart,
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.start,
                  spacing: 10,
                  children: radicalData
                      .map((radical) => RadicalComponent(radicalData: radical))
                      .toList()),
            ),
            const SizedBox(height: 8),
            buildMnemonic(mnemonic),
            ...groups.map((group) => GroupComponent(groupData: group)).toList()
          ],
        ),
      ),
    );
  }
}
