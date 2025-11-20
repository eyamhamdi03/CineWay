import 'package:flutter/material.dart';
import '../../core/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onTap;

  const CustomSearchBar({
    super.key,
    required this.placeholder,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mineShaft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: AppColors.jumbo, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: AppColors.jumbo),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
