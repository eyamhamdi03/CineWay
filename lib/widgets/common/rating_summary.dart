import 'package:flutter/material.dart';

class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final List<double> percentages; // [85, 9, 3, 2, 1]

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.percentages,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 46,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Stars
            Row(
              children: List.generate(
                5,
                    (i) => Icon(Icons.star, color: colorScheme.primary, size: 20),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "$totalReviews reviews",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),

        const SizedBox(width: 24),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(5, (i) {
            final star = 5 - i; // 5, 4, 3, 2, 1
            final percent = percentages[i];

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  // Star number
                  SizedBox(
                    width: 18,
                    child: Text(
                      star.toString(),
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),

                  // Progress bar
                    Container(
                    width: 120,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percent / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Percentage
                  Text(
                    "${percent.toInt()}%",
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
