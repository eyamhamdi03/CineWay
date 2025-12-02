class Review {
  int? reviewId;
  String reviewerName;
  String reviewerAvatar;
  double rating;
  String comment;
  DateTime createdAt;
  int likes;
  int dislikes;

  Review({
    required this.reviewId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.likes,
    required this.dislikes,
  });

  // ---------------- FROM JSON ----------------
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json["reviewId"],
      reviewerName: json["reviewerName"],
      reviewerAvatar: json["reviewerAvatar"],
      rating: (json["rating"] as num).toDouble(),
      comment: json["comment"],
      createdAt: json["timeAgo"],
      likes: json["likes"],
      dislikes: json["dislikes"],
    );
  }

  // ---------------- TO JSON ----------------
  Map<String, dynamic> toJson() {
    return {
      "reviewId": reviewId,
      "reviewerName": reviewerName,
      "reviewerAvatar": reviewerAvatar,
      "rating": rating,
      "comment": comment,
      "timeAgo": timeAgo,
      "likes": likes,
      "dislikes": dislikes,
    };
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} h ago";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} weeks ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} months ago";

    return "${(diff.inDays / 365).floor()} years ago";
  }

}
