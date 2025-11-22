class Review {
  int? reviewId;

  String reviewerName;
   String reviewerAvatar;
   double rating;
   String comment;
   String timeAgo;
   int likes;
   int dislikes;

  Review({
    required this.reviewId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.likes,
    required this.dislikes,
  });
}
