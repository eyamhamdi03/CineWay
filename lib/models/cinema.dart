import 'movie.dart';

class Cinema {
  final int id;
  final String name;
  final String imageUrl;
  final String address;

  // Backend new field
  final String city;

  // For GPS distance calculation
  final double latitude;
  final double longitude;

  final String phone;
  final bool hasParking;
  final bool isAccessible;

  /// Amenities like: ["3D", "IMAX", "Snack", "VIP"]
  final List<String> amenities;

  /// Backend creation date
  final DateTime createdAt;

  Cinema({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.hasParking,
    required this.isAccessible,
    required this.amenities,
    required this.createdAt,
  });

  // ----------------- FROM JSON -----------------
  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? "",  // backend does not have it, but safe
      address: json['address'] ?? "",
      city: json['city'] ?? "",
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: json['phone'] ?? "",
      hasParking: json['hasParking'] ?? false,
      isAccessible: json['isAccessible'] ?? false,
      amenities: List<String>.from(json['amenities'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] ?? "") ?? DateTime.now(),
    );
  }

  // ----------------- TO JSON -----------------
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
      "address": address,
      "city": city,
      "latitude": latitude,
      "longitude": longitude,
      "phone": phone,
      "hasParking": hasParking,
      "isAccessible": isAccessible,
      "amenities": amenities,
      "created_at": createdAt.toIso8601String(),
    };
  }
}
