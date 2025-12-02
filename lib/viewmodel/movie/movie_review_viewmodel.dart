import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../models/movie.dart';

class ReviewViewModel extends ChangeNotifier {
  Movie movie;

  // Temporary in-memory tracking (for UI-only demo)
  final Map<int, bool> userLikes = {};
  final Map<int, bool> userDislikes = {};

  ReviewViewModel(this.movie);

  // Like review
  void toggleLike(int reviewId) {
    final review = movie.reviews.firstWhere((r) => r.reviewId == reviewId);

    // User already liked → undo like
    if (userLikes[reviewId] == true) {
      review.likes--;
      userLikes.remove(reviewId);
    } else {
      // Add like
      review.likes++;
      userLikes[reviewId] = true;

      // Remove dislike if existed
      if (userDislikes[reviewId] == true) {
        review.dislikes--;
        userDislikes.remove(reviewId);
      }
    }

    notifyListeners();
  }

  // Dislike review
  void toggleDislike(int reviewId) {
    final review = movie.reviews.firstWhere((r) => r.reviewId == reviewId);

    if (userDislikes[reviewId] == true) {
      review.dislikes--;
      userDislikes.remove(reviewId);
    } else {
      review.dislikes++;
      userDislikes[reviewId] = true;

      if (userLikes[reviewId] == true) {
        review.likes--;
        userLikes.remove(reviewId);
      }
    }

    notifyListeners();
  }

  // Add a new review
  void addReview(double rating, String comment) {
    final newId =1;
       // : movie.reviews.map((r) => r.reviewId).reduce((a, b) => a > b ? a : b) + 1;

    movie.reviews.add(
      Review(
        reviewId: newId,
        reviewerName: "You",
        reviewerAvatar: "user1.png",
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        likes: 0,
        dislikes: 0,
      ),
    );

    notifyListeners();
  }
}
