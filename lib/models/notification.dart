class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'booking', 'rating', 'movie_release', 'promo', 'payment'
  final bool isRead;
  final DateTime timestamp;
  final String? movieOrCinemaName;
  final String? icon;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.movieOrCinemaName,
    this.icon,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'booking',
      isRead: json['isRead'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      movieOrCinemaName: json['movieOrCinemaName'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'movieOrCinemaName': movieOrCinemaName,
      'icon': icon,
    };
  }
}
