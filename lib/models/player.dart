class Player {
  final String id;
  final String nickname;
  final String fullName;
  final String gender; // 'male' or 'female'
  final String skillLevel; // e.g., 'Beginner', 'Intermediate', 'Advanced', 'Professional'
  final String? contactNumber;
  final String? email;
  final String? address;
  final String? remarks;
  final String? skillLevelStrength; // e.g., 'Weak', 'Mid', 'Strong'
  final BadmintonLevel? badmintonLevel;

  Player({
    required this.id,
    required this.nickname,
    required this.fullName,
    required this.gender,
    required this.skillLevel,
    this.contactNumber,
    this.email,
    this.address,
    this.remarks,
    this.skillLevelStrength,
    this.badmintonLevel,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      nickname: json['nickname'],
      fullName: json['fullName'],
      gender: json['gender'],
      skillLevel: json['skillLevel'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      address: json['address'],
      remarks: json['remarks'],
      skillLevelStrength: json['skillLevelStrength'],
      badmintonLevel: json['badmintonLevel'] != null 
          ? BadmintonLevel.fromJson(json['badmintonLevel']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'fullName': fullName,
      'gender': gender,
      'skillLevel': skillLevel,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'remarks': remarks,
      'skillLevelStrength': skillLevelStrength,
      'badmintonLevel': badmintonLevel?.toJson(),
    };
  }
}

class BadmintonLevel {
  final String level;
  final String strength;

  BadmintonLevel({
    required this.level,
    required this.strength,
  });

  factory BadmintonLevel.fromJson(Map<String, dynamic> json) {
    return BadmintonLevel(
      level: json['level'],
      strength: json['strength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'strength': strength,
    };
  }

  static List<String> get levels => [
    'Beginners',
    'Intermediate',
    'Level G',
    'Level F',
    'Level E', 
    'Level D',
    'Open Player',
  ];

  static List<String> get strengths => [
    'Weak',
    'Mid',
    'Strong',
  ];
}
