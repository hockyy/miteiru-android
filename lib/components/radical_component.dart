import 'package:flutter/material.dart';

class RadicalComponent extends StatelessWidget {
  final Map<String, dynamic> radicalData;

  const RadicalComponent({super.key, required this.radicalData});

  @override
  Widget build(BuildContext context) {
    String? character = radicalData['character'];
    String meaning = radicalData['meaning'];
    String radicalId = radicalData['radicalId'];

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(249, 227, 225, 1),
          border: Border.all(
            color: Colors.red,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          children: [
            Text(meaning,
                style: const TextStyle(
                    fontSize: 15.0, color: Color.fromRGBO(170, 49, 41, 1))),
            SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: character != null
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          character,
                          style: const TextStyle(fontSize: 70),
                        ),
                      )
                    : Image.asset(
                        'assets/radical/$radicalId.png',
                        fit: BoxFit.scaleDown,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
