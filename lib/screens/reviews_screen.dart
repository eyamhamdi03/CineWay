import 'package:cineway/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../viewmodel/movie/movie_review_viewmodel.dart';
import '../widgets/common/rating_summary.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatelessWidget {
  final Movie movie;

  const ReviewsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    return Scaffold(
      backgroundColor: AppColors.mirage,
      appBar: AppBar(
        backgroundColor: AppColors.mirage,
        title: const Text(
          "Reviews",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RatingSummary(
                  averageRating: 4,
                  totalReviews: movie.reviews.length,
                  percentages: [85, 9, 3, 2, 1],
                ),
              ),
              const SizedBox(height: 20),

              // Reviews list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: movie.reviews.length,
                  itemBuilder: (context, index) {
                    final review = movie.reviews[index];
                    final reviewId = review.reviewId ?? index;

                    final isLiked = vm.userLikes[reviewId] == true;
                    final isDisliked = vm.userDislikes[reviewId] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reviewer info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                AssetImage(review.reviewerAvatar),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.reviewerName,
                                    style:
                                    const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    review.timeAgo,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Star rating
                          Row(
                            children: List.generate(
                              5,
                                  (i) => Icon(
                                i < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: AppColors.cerulean,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            review.comment,
                            style: const TextStyle(
                                color: Colors.white70, height: 1.3),
                          ),

                          const SizedBox(height: 6),

                          // LIKE / DISLIKE
                          Row(
                            children: [
                              InkWell(
                                onTap: () => vm.toggleLike(reviewId),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.thumb_up_alt
                                          : Icons.thumb_up_alt_outlined,
                                      size: 20,
                                      color: isLiked
                                          ? Colors.grey
                                          : Colors.white54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      review.likes.toString(),
                                      style:
                                      const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),

                              InkWell(
                                onTap: () => vm.toggleDislike(reviewId),
                                child: Row(
                                  children: [
                                    Icon(
                                      isDisliked
                                          ? Icons.thumb_down_alt
                                          : Icons.thumb_down_alt_outlined,
                                      size: 20,
                                      color: isDisliked
                                          ? Colors.grey
                                          : Colors.white54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      review.dislikes.toString(),
                                      style:
                                      const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // ADD REVIEW BUTTON
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final result = await showDialog<NewReviewData>(
                  context: context,
                  builder: (_) => AddReviewScreen(),
                );

                if (result != null) {
                  vm.addReview(result.rating, result.comment);
                }
              },
              child: Container(
                height: 55,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.cerulean,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text("Add Review",
                        style:
                        TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
