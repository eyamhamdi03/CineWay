import 'package:flutter/material.dart';

class ChipUI extends StatelessWidget {
  final String text;
  const ChipUI(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      backgroundColor: cs.onSurface.withOpacity(0.12),
      label: Text(text, style: TextStyle(color: cs.onSurface)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}