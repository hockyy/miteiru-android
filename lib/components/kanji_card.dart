import 'package:flutter/material.dart';
import 'package:miteiru/components/radical_component.dart';

class KanjiCard extends StatelessWidget {
  final String kanji;
  final Map<String, dynamic> kanjiData;
  final List<Map<String, dynamic>> radicalData;

  const KanjiCard({
    Key? key,
    required this.kanji,
    required this.kanjiData,
    required this.radicalData,
  }) : super(key: key);

  TextSpan buildStyledText(String content, Color color, FontWeight fontWeight) {
    return TextSpan(
      text: content,
      style: TextStyle(color: color, fontWeight: fontWeight),
    );
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
    String mnemonic = kanjiData['meaning_mnemonic'] ?? "No mnemonic found";
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
            Divider(),
            Row(
              children: radicalData
                  .map((radical) => RadicalComponent(radicalData: radical))
                  .toList()
                  .expand((widget) => [widget, SizedBox(width: 10)])
                  .toList()
                ..removeLast(), // remove the last added SizedBox
            ),
            const SizedBox(height: 8),
            buildMnemonic(mnemonic),
          ],
        ),
      ),
    );
  }
}
