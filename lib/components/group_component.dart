import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupComponent extends StatelessWidget {
  final Map<String, dynamic> groupData;

  GroupComponent({Key? key, required this.groupData}) : super(key: key);

  Widget bubbleEntryReading(List<dynamic> readings) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 8.0, // gap between lines
      children: readings.map((dynamic val) {
        final Uri url = Uri.parse(val);
        return InkWell(
          onTap: url.isAbsolute
              ? () async {
                  launchUrl(url);
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(249, 227, 225, 1),
              border: Border.all(
                color: Colors.red,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              val,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(170, 49, 41, 1)),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ...groupData.entries.map<Widget>((entry) {
          final key = entry.key;
          final value = entry.value;

          return Column(
            children: [
              const SizedBox(height: 10),
              Text(
                key,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromRGBO(170, 49, 41, 1)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: bubbleEntryReading(value),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              )
            ],
          );
        }).toList(),
      ],
    );
  }
}
