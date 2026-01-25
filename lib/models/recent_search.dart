class RecentSearch {
  final String id;
  final String query;
  final String type; // 'movie' or 'cinema'
  final DateTime timestamp;
  final String? subtitle; // For cinema: "Cinema • 2.4km away"

  RecentSearch({
    required this.id,
    required this.query,
    required this.type,
    required this.timestamp,
    this.subtitle,
  });

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      id: json['id'] ?? '',
      query: json['query'] ?? '',
      type: json['type'] ?? 'movie',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      subtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'subtitle': subtitle,
    };
  }
}
