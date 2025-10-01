class Player {
  final String id;
  final String nickname;
  final String fullName;
  final String gender; // 'male' or 'female'
  final String skillLevel; // e.g., 'Beginner', 'Intermediate', 'Advanced', 'Professional'

  Player({
    required this.id,
    required this.nickname,
    required this.fullName,
    required this.gender,
    required this.skillLevel,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      nickname: json['nickname'],
      fullName: json['fullName'],
      gender: json['gender'],
      skillLevel: json['skillLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'fullName': fullName,
      'gender': gender,
      'skillLevel': skillLevel,
    };
  }
}
