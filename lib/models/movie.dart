import 'package:cineway/models/cast.dart';
import 'package:cineway/models/review.dart';

class Movie {
  final int id;
  final String title;
  final String description;

  final String bannerUrl;

  final List<String> categories; // from genre
  final String duration;         // from duration_minutes → string
  final int releaseYear;         // parsed from release_date
  final String rating;           // String, not double
  final List<Cast> cast;       // simple list
  final List<Review> reviews;    // empty for now

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

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json["id"],
      title: json["title"],
      description: json["description"] ?? "",
      bannerUrl: json["image_url"] ?? "",
      categories: List<String>.from(json["genre"] ?? []),
      duration: json["duration_minutes"]?.toString() ?? "",
      releaseYear:
      DateTime.tryParse(json["release_date"] ?? "")?.year ?? 0,
      rating: json["rating"] ?? "",
      cast: (json["cast"] as List? ?? []).map((c) {
        if (c is Map<String, dynamic>) {
          return Cast.fromJson(c);
        } else {
          return Cast(name: c.toString(), imageUrl: "");
        }
      }).toList(),
      reviews: [], // backend does not send reviews yet
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
    };
  }
}
