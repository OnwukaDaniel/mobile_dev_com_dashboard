import 'package:flutter/material.dart';

class PieIndicators extends StatelessWidget {
  final Text textWidget;
  final Color color;

  const PieIndicators({
    Key? key,
    required this.textWidget,
    required this.color,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Material(
            color: color,
            borderRadius: BorderRadius.circular(12.0),
            child: const SizedBox(
              width: 50,
              height: 30,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: textWidget,
            ),
          ),
        ],
      ),
    );
  }
}
