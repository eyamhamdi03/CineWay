import 'package:cineway/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:cineway/models/movie.dart';

import '../models/review.dart';
import '../widgets/common/rating_summary.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final Movie movie;

  const ReviewsScreen({super.key, required this.movie});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  Map<int, bool> userLikes = {};
  Map<int, bool> userDislikes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nileBlue2,

      appBar: AppBar(
        backgroundColor: AppColors.nileBlue2,
        title: const Text(
          "Reviews",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Stack(
        children: [
          // MAIN COLUMN
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RatingSummary(
                  averageRating: widget.movie.rating,
                  totalReviews: widget.movie.reviews.length,
                  percentages: [85, 9, 3, 2, 1],
                ),
              ),

              const SizedBox(height: 20),

              // REVIEWS LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.movie.reviews.length,
                  itemBuilder: (context, index) {
                    final review = widget.movie.reviews[index];
                    final reviewId = index; // Always safe

                    final isLiked = userLikes[reviewId] == true;
                    final isDisliked = userDislikes[reviewId] == true;

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
                              const SizedBox(width: 12),
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
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
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

                          // Review comment
                          Text(
                            review.comment,
                            style: const TextStyle(
                                color: Colors.white70, height: 1.3),
                          ),

                          const SizedBox(height: 6),

                          // LIKE + DISLIKE
                          Row(
                            children: [
                              // LIKE
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (!isLiked) {
                                      review.likes++;
                                      userLikes[reviewId] = true;
                                      userDislikes.remove(reviewId);
                                    } else {
                                      review.likes--;
                                      userLikes.remove(reviewId);
                                    }
                                  });
                                },
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
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 20),

                              // DISLIKE
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (!isDisliked) {
                                      review.dislikes++;
                                      userDislikes[reviewId] = true;
                                      userLikes.remove(reviewId);
                                    } else {
                                      review.dislikes--;
                                      userDislikes.remove(reviewId);
                                    }
                                  });
                                },
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
                                      style: const TextStyle(
                                          color: Colors.white),
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

          // FIXED BUTTON
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
                onTap: () async {
                  final result = await showDialog<NewReviewData>(
                    context: context,
                    builder: (context) => AddReviewScreen(),
                  );

                  if (result != null) {
                    setState(() {
                      widget.movie.reviews.add(
                        Review(
                          reviewId: widget.movie.reviews.length,
                          reviewerName: "You",
                          reviewerAvatar: "assets/images/default_avatar.png",
                          rating: result.rating,
                          comment: result.comment,
                          timeAgo: "Just now",
                          likes: 0,
                          dislikes: 0,
                        ),
                      );
                    });
                  }
                },

              child: Container(
                height: 55,
                width: 150, // fixed width
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cerulean,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Add Review",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
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
