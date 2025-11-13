class UserSettings {
  final String courtName;
  final double courtRate;
  final double shuttleCockPrice;
  final bool divideCourtEqually;
  final bool divideShuttleCockEqually;

  UserSettings({
    required this.courtName,
    required this.courtRate,
    required this.shuttleCockPrice,
    this.divideCourtEqually = true,
    this.divideShuttleCockEqually = true,
  });

  // Calculate court rate per game (default for settings preview)
  double get courtRatePerGame {
    if (divideCourtEqually) {
      return courtRate / 4; // Default preview divided by 4
    }
    return courtRate;
  }

  // Calculate shuttlecock price per player (default for settings preview)
  double get shuttleCockPricePerPlayer {
    if (divideShuttleCockEqually) {
      return shuttleCockPrice / 4; // Default preview divided by 4
    }
    return shuttleCockPrice;
  }

  UserSettings copyWith({
    String? courtName,
    double? courtRate,
    double? shuttleCockPrice,
    bool? divideCourtEqually,
    bool? divideShuttleCockEqually,
  }) {
    return UserSettings(
      courtName: courtName ?? this.courtName,
      courtRate: courtRate ?? this.courtRate,
      shuttleCockPrice: shuttleCockPrice ?? this.shuttleCockPrice,
      divideCourtEqually: divideCourtEqually ?? this.divideCourtEqually,
      divideShuttleCockEqually:
          divideShuttleCockEqually ?? this.divideShuttleCockEqually,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courtName': courtName,
      'courtRate': courtRate,
      'shuttleCockPrice': shuttleCockPrice,
      'divideCourtEqually': divideCourtEqually,
      'divideShuttleCockEqually': divideShuttleCockEqually,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      courtName: json['courtName'] as String,
      courtRate: (json['courtRate'] as num).toDouble(),
      shuttleCockPrice: (json['shuttleCockPrice'] as num).toDouble(),
      divideCourtEqually: json['divideCourtEqually'] as bool? ?? true,
      divideShuttleCockEqually:
          json['divideShuttleCockEqually'] as bool? ?? true,
    );
  }
}
