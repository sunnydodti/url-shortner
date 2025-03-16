import 'package:flutter/material.dart';

class ColoredTextBox extends StatelessWidget {
  final String text;
  final Color color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int opacity;
  final TextOverflow textOverflow;
  final bool upperCase;

  const ColoredTextBox({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w500,
    this.opacity = 20,
    this.textOverflow = TextOverflow.fade,
    this.upperCase = true,
  });

  // Helper constructors for different colors
  factory ColoredTextBox.green(String text) => ColoredTextBox(
        text: text,
        color: Colors.green,
      );

  factory ColoredTextBox.red(String text) => ColoredTextBox(
        text: text,
        color: Colors.red,
      );

  factory ColoredTextBox.orange(String text) => ColoredTextBox(
        text: text,
        color: Colors.orange,
      );

  factory ColoredTextBox.grey(String text) => ColoredTextBox(
        text: text,
        color: Colors.grey,
      );

  factory ColoredTextBox.blue(String text) => ColoredTextBox(
        text: text,
        color: Colors.blue,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(opacity),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        upperCase ? text.toUpperCase() : text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          overflow: textOverflow,
        ),
      ),
    );
  }
}
