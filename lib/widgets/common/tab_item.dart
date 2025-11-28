import 'package:cineway/core/colors.dart';
import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const TabItem({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: active
            ? BoxDecoration(
          color: AppColors.cerulean,
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
