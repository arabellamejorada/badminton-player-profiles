class UserSettings {
  final String courtName;
  final double courtRate;
  final double shuttleCockPrice;
  final bool divideCourtEqually;

  UserSettings({
    required this.courtName,
    required this.courtRate,
    required this.shuttleCockPrice,
    this.divideCourtEqually = true,
  });

  // Calculate court rate per game (assuming 4 players for doubles)
  double get courtRatePerGame {
    if (divideCourtEqually) {
      return courtRate / 4;
    }
    return courtRate;
  }

  // Calculate shuttlecock price per player (assuming 4 players)
  double get shuttleCockPricePerPlayer {
    return shuttleCockPrice / 4;
  }

  UserSettings copyWith({
    String? courtName,
    double? courtRate,
    double? shuttleCockPrice,
    bool? divideCourtEqually,
  }) {
    return UserSettings(
      courtName: courtName ?? this.courtName,
      courtRate: courtRate ?? this.courtRate,
      shuttleCockPrice: shuttleCockPrice ?? this.shuttleCockPrice,
      divideCourtEqually: divideCourtEqually ?? this.divideCourtEqually,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courtName': courtName,
      'courtRate': courtRate,
      'shuttleCockPrice': shuttleCockPrice,
      'divideCourtEqually': divideCourtEqually,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      courtName: json['courtName'] as String,
      courtRate: (json['courtRate'] as num).toDouble(),
      shuttleCockPrice: (json['shuttleCockPrice'] as num).toDouble(),
      divideCourtEqually: json['divideCourtEqually'] as bool? ?? true,
    );
  }
}
