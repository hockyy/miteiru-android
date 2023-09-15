import 'package:flutter/material.dart';
import 'package:svg_drawing_animation/svg_drawing_animation.dart';

class KanjiDrawingAnimation extends StatelessWidget {
  const KanjiDrawingAnimation(this.filename,
      {this.speed = 80, this.curve = Curves.decelerate, super.key});

  final String filename;
  final double speed;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/kanji/$filename.svg';
    return SvgDrawingAnimation(
      SvgProvider.asset(assetPath),
      repeats: true,
      speed: speed,
      curve: curve,
      errorWidgetBuilder: (context, error, stackTrace) =>
      Text('No kanji stroke information for $filename'),
      penRenderer: CirclePenRenderer(
      radius: 5, paint: Paint()..color = Colors.redAccent.withAlpha(200)),
    );
  }
}
