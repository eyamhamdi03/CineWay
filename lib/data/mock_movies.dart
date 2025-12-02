import '../models/movie.dart';
import '../models/cast.dart';
import '../models/review.dart';

final List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: "Dune: Part Two",
    description:
    "Paul Atreides unites with Chani and the Fremen as he seeks revenge "
        "against the conspirators who destroyed his family.",
    bannerUrl: "assets/dune_banner.png",
    categories: ["Action", "Sci-Fi", "Adventure"],
    duration: "2h 46m",
    releaseYear: 2024,
    rating: "4.8",
    cast: [
      Cast(name: "Timothée Chalamet", imageUrl: "assets/timo.png"),
      Cast(name: "Zendaya", imageUrl: "assets/zen.png"),
      Cast(name: "Rebecca Ferguson", imageUrl: "assets/rebecca.jpg"),
      Cast(name: "Austin Butler", imageUrl: "assets/austin.png"),
    ],
    reviews: [
      Review(
        reviewId: 1,
        reviewerName: "Alex Morgan",
        reviewerAvatar: "user1.png",
        rating: 5,
        comment: "An absolute masterpiece! The cinematography was breathtaking.",
        createdAt: DateTime.now().subtract(Duration(days: 14)), // 2 weeks ago
        likes: 125,
        dislikes: 3,
      ),
      Review(
        reviewId: 2,
        reviewerName: "Casey Lee",
        reviewerAvatar: "user2.png",
        rating: 4,
        comment: "Really great movie, although some parts felt a bit slow.",
        createdAt: DateTime.now().subtract(Duration(days: 30)), // 1 month ago
        likes: 98,
        dislikes: 12,
      ),
      Review(
        reviewId: 3,
        reviewerName: "Jordan Taylor",
        reviewerAvatar: "user3.png",
        rating: 3,
        comment: "It was okay. Good effects but predictable plot.",
        createdAt: DateTime.now().subtract(Duration(days: 90)), // 3 months ago
        likes: 24,
        dislikes: 31,
      ),
      Review(
        reviewId: 4,
        reviewerName: "Jordan Taylor",
        reviewerAvatar: "user3.png",
        rating: 3,
        comment: "It was okay. Good effects but predictable plot.",
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        likes: 24,
        dislikes: 31,
      ),
      Review(
        reviewId: 5,
        reviewerName: "Jordan Taylor",
        reviewerAvatar: "user3.png",
        rating: 3,
        comment: "It was okay. Good effects but predictable plot.",
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        likes: 24,
        dislikes: 31,
      ),
      Review(
        reviewId: 6,
        reviewerName: "Jordan Taylor",
        reviewerAvatar: "user3.png",
        rating: 3,
        comment: "It was okay. Good effects but predictable plot.",
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        likes: 24,
        dislikes: 31,
      ),
    ],
  ),
];
