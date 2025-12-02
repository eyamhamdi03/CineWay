import 'package:flutter/material.dart';
import '../../models/cinema.dart';

class CinemaCardResume extends StatelessWidget {
  final Cinema cinema;
  final VoidCallback onTap;

  const CinemaCardResume({super.key, required this.cinema, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                cinema.imageUrl,
                width: 90,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cinema.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(cinema.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54)),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.movie, color: Colors.white54, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "now showing movies",
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
