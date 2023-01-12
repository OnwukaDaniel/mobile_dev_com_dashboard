import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final EdgeInsetsGeometry padding;

  const CustomText({
    Key? key,
    required this.text,
    this.style = const TextStyle(),
    this.padding = const EdgeInsets.all(0.0),
  }) : super(key: key);

  static EdgeInsetsGeometry innerPadding = const EdgeInsets.all(0.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text, style: style),
    );
  }
}
