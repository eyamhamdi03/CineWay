import 'package:cineway/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:cineway/models/movie.dart';

import '../widgets/common/rating_summary.dart';

class ReviewsScreen extends StatelessWidget {
  final Movie movie;

  const ReviewsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Reviews",style:const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold),),
      ) ,


      body:Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
      Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child:
      RatingSummary(
            averageRating: movie.rating,
            totalReviews: movie.reviews.length,
            percentages: [85, 9, 3, 2, 1], // you can compute these later
          ),),

          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: movie.reviews.length,
            itemBuilder: (context, index) {
              final review = movie.reviews[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 26),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reviewer info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(review.reviewerAvatar),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.reviewerName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
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

                    // Rating stars
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

                    // Comment
                    Text(
                      review.comment,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      )

    );
  }
}
