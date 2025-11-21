import 'package:flutter/material.dart';

class ChipUI extends StatelessWidget {
  final String text;
  const ChipUI(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white12,
      label: Text(text, style: const TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}