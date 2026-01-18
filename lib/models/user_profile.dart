class UserProfile {
  String? id;
  String? email;
  String? fullName;
  String? avatarPath;
  DateTime? dob;
  List<String> favoriteGenres = [];
  bool receiveNewsletter = false;

  UserProfile({this.id, this.email, this.fullName});

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'avatarPath': avatarPath,
    'dob': dob?.toIso8601String(),
    'favoriteGenres': favoriteGenres,
    'receiveNewsletter': receiveNewsletter,
  };

  static UserProfile? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    final u = UserProfile(id: j['id'], email: j['email'], fullName: j['fullName']);
    if (j['dob'] != null) {
      try {
        u.dob = DateTime.parse(j['dob']);
      } catch (_) {}
    }
    if (j['favoriteGenres'] is List) {
      u.favoriteGenres = List<String>.from(j['favoriteGenres']);
    }
    u.avatarPath = j['avatarPath'];
    u.receiveNewsletter = j['receiveNewsletter'] == true;
    return u;
  }
}
