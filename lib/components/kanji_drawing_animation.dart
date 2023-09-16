import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_drawing_animation/svg_drawing_animation.dart';

class KanjiDrawingAnimation extends StatelessWidget {
  const KanjiDrawingAnimation(this.filename,
      {this.speed = 80, this.curve = Curves.decelerate, Key? key})
      : super(key: key);

  final String filename;
  final double speed;
  final Curve curve;

  Future<String> getSvgContent() async {
    return rootBundle.loadString('assets/kanji/$filename.svg');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getSvgContent(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return SvgDrawingAnimation(
            SvgProvider.string(snapshot.data!),
            repeats: true,
            speed: speed,
            curve: curve,
            errorWidgetBuilder: (context, error, stackTrace) =>
                Text('No kanji stroke information for $filename'),
            penRenderer: CirclePenRenderer(
                radius: 5,
                paint: Paint()..color = Colors.redAccent.withAlpha(200)),
          );
        }
      },
    );
  }
}
