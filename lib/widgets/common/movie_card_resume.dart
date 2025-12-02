import 'package:flutter/material.dart';
import '../../models/movie.dart';

class MovieCardResume extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCardResume({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                movie.bannerUrl,
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
                  Text(movie.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    movie.categories.join(" • "),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.yellow, size: 18),
                      const SizedBox(width: 4),
                      Text(movie.rating.toString(),
                          style: const TextStyle(color: Colors.white)),
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
