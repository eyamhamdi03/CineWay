import 'cast.dart';
import 'review.dart';

class Movie {
  final int id;
  final String title;
  final String description;
  final String bannerUrl;
  final List<String> categories;
  final String duration;
  final int releaseYear;
  final double rating;
  final List<Cast> cast;
  final List<Review> reviews;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.categories,
    required this.duration,
    required this.releaseYear,
    required this.rating,
    required this.cast,
    required this.reviews,
  });
}
