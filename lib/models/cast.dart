class Cast {
  final String name;
  final String imageUrl;

  Cast({
    required this.name,
    required this.imageUrl,
  });

  // ----------- FROM JSON -----------
  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      name: json["name"],
      imageUrl: json["imageUrl"],
    );
  }

  // ----------- TO JSON -----------
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "imageUrl": imageUrl,
    };
  }
}
