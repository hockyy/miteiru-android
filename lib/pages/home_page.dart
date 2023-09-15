import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _inputText = ''; // New variable for storing input text

  Future<void> getProcessedText() async {
    const platform = MethodChannel('id.hocky.miteiru/clipboard');
    String processedText = await platform.invokeMethod('getProcessedText');
    setState(() {
      _inputText = processedText;
      _controller.text = processedText;
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
                    setState(() {
                      _inputText = text;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Type something here',
                  ),
                ),
                Text(_inputText), // New Text widget to display input
              ],
            ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ClipboardData? clipboardData = await Clipboard.getData('text/plain');
          print('Clipboard data: ${clipboardData?.text}');
          if (clipboardData != null) {
            setState(() {
              _controller.text = clipboardData.text ?? '';
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: (_controller.text ?? '').length),
              );
              _inputText = clipboardData.text ?? '';
            });
          }
        },
        tooltip: 'Paste',
        child: const Icon(Icons.content_paste),
      ),
    );
  }
}
