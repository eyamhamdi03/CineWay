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
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rd = DateTime.tryParse((json["release_date"] ?? "").toString());

    return Movie(
      id: json["id"],
      title: json["title"],
      description: json["description"] ?? "",
      bannerUrl: json["image_url"] ?? "",   // should be a URL
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
    };
  }
}
