import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miteiru/components/kanji_card.dart';
import 'package:miteiru/utils/utilities.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _inputText = ''; // New variable for storing input text

  List<Widget> kanjiContainer = [];
  final kanjiJson = <String, dynamic>{};

  final radicalJson = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    getProcessedText();

    Future.wait([
      loadJson("kanji"),
      loadJson("radical"),
    ]).then((List<Map<String, dynamic>> loadedFiles) {
      setState(() {
        kanjiJson.addAll(loadedFiles[0]);
        radicalJson.addAll(loadedFiles[1]);
      });
    });
  }

  void processAndSetThemKanjis(String text) {
    setState(() {
      _inputText = text;
      List<Widget> newKanjiContainer = [];

      for (int i = 0; i < text.length; i++) {
        var meaning = kanjiJson[text[i]] as Map<String, dynamic>?;

        if (meaning != null) {
          List<Map<String, dynamic>> radicals = [];
          var componentIds = meaning['component_subject_ids'];

          if (componentIds != null) {
            for (var radicalId in componentIds) {
              var radicalInfo = radicalJson[radicalId] as Map<String, dynamic>?;
              if (radicalInfo != null) {
                radicalInfo["radicalId"] = radicalId;
                radicals.add(radicalInfo);
              }
            }
          }

          newKanjiContainer.add(KanjiCard(
            kanji: text[i],
            kanjiData: meaning,
            radicalData: radicals,
          ));
        }
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
                  Text(_inputText),
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
            SizedBox(width: 10), // Add a gap between buttons
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
