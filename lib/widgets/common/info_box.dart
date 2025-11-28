import 'package:cineway/core/colors.dart';
import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoBox({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.onSurface.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.cerulean),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(color: cs.onSurface, fontSize: 14)),
        ],
      ),
    );
  }
}