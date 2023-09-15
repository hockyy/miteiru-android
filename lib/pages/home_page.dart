import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miteiru/background/hive_database.dart';
import 'package:miteiru/components/kanji_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  List<Widget> kanjiContainer = [];

  @override
  void initState() {
    super.initState();
    getProcessedText();
  }

  void processAndSetThemKanjis(String text) {
    setState(() {
      List<Widget> newKanjiContainer = [];

      for (int i = 0; i < text.length; i++) {
        var kanjiAnalysis = HiveDatabase.queryKanjidic(text[i]);
        if (kanjiAnalysis == null) continue;
        var meaning = HiveDatabase.queryKanji(text[i]);
        List<Map<String, dynamic>> radicals = [];

        if (meaning != null) {
          var componentIds = meaning['component_subject_ids'];

          if (componentIds != null) {
            for (var radicalId in componentIds) {
              var radicalInfo = HiveDatabase.queryRadical(radicalId);
              if (radicalInfo != null) {
                radicalInfo["radicalId"] = radicalId;
                radicals.add(radicalInfo);
              }
            }
          }
        } else {
          meaning = <String, dynamic>{};
        }

        newKanjiContainer.add(KanjiCard(
            kanji: text[i],
            kanjiData: meaning,
            radicalData: radicals,
            kanjiAnalysis: kanjiAnalysis));
      }

      kanjiContainer = newKanjiContainer;
    });
  }

  Future<void> getProcessedText() async {
    const platform = MethodChannel('id.hocky.miteiru/clipboard');
    String processedText = await platform.invokeMethod('getProcessedText');
    setState(() {
      _controller.text += processedText;
      processAndSetThemKanjis(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onChanged: (text) {
                      processAndSetThemKanjis(text);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Type something here',
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    // <-- Wrap with Expanded
                    child: SingleChildScrollView(
                      child: Column(
                        children: kanjiContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          // Align buttons to the right
          children: [
            FloatingActionButton(
              onPressed: () async {
                ClipboardData? clipboardData =
                    await Clipboard.getData('text/plain');
                if (clipboardData != null) {
                  setState(() {
                    var oldPosition = _controller.selection.end;
                    _controller.text += clipboardData.text ?? '';
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(
                          offset: oldPosition + clipboardData.text!.length),
                    );
                    processAndSetThemKanjis(_controller.text);
                  });
                }
              },
              tooltip: 'Paste',
              child: const Icon(Icons.content_paste),
            ),
            const SizedBox(width: 10), // Add a gap between buttons
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.clear();
                  processAndSetThemKanjis(''); // Clear processed Kanji as well
                });
              },
              tooltip: 'Reset',
              child: const Icon(Icons.clear),
            ),
          ],
        ));
  }
}
