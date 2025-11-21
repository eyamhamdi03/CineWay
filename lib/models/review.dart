class Review {
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final String timeAgo;
  final int likes;
  final int comments;

  Review({
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.likes,
    required this.comments,
  });
}
