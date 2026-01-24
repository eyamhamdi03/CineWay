import 'package:cineway/models/cast.dart';
import 'package:cineway/models/review.dart';

class Movie {
  final int id;
  final String title;
  final String description;
  final String bannerUrl;
  final List<String> categories;
  final String duration;
  final DateTime? releaseDate;
  final int releaseYear;
  final String rating;
  final List<Cast> cast;
  final List<Review> reviews;
  final int? voteCount;
  final String? director;
  final List<String>? writers;
  final String? language;
  final String? trailerUrl;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.categories,
    required this.duration,
    required this.releaseDate,
    required this.releaseYear,
    required this.rating,
    required this.cast,
    required this.reviews,
    this.voteCount,
    this.director,
    this.writers,
    this.language,
    this.trailerUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rd = DateTime.tryParse((json["release_date"] ?? "").toString());

    return Movie(
      id: json["id"],
      title: json["title"],
      description: json["description"] ?? "",
      bannerUrl: json["image_url"] ?? "",
      categories: List<String>.from(json["genre"] ?? []),
      duration: json["duration_minutes"]?.toString() ?? "",
      releaseDate: rd,
      releaseYear: rd?.year ?? 0,
      rating: (json["rating"] ?? "").toString(),
      cast: (json["cast"] as List? ?? []).map((c) {
        if (c is Map<String, dynamic>) return Cast.fromJson(c);
        return Cast(name: c.toString(), imageUrl: "");
      }).toList(),
      reviews: [],
      voteCount: json["vote_count"],
      director: json["director"],
      writers: json["writers"] is List ? List<String>.from(json["writers"] as List) : null,
      language: json["language"],
      trailerUrl: json["trailer_url"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "bannerUrl": bannerUrl,
      "categories": categories,
      "duration": duration,
      "releaseYear": releaseYear,
      "rating": rating,
      "cast": cast,
      "reviews": reviews.map((r) => r.toJson()).toList(),
      "voteCount": voteCount,
      "director": director,
      "writers": writers,
      "language": language,
      "trailerUrl": trailerUrl,
    };
  }
}
