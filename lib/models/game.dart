class CourtSchedule {
  final int courtNumber;
  final DateTime startTime;
  final DateTime endTime;

  CourtSchedule({
    required this.courtNumber,
    required this.startTime,
    required this.endTime,
  });

  // Calculate duration in hours
  double get durationInHours {
    final duration = endTime.difference(startTime);
    return duration.inMinutes / 60.0;
  }

  CourtSchedule copyWith({
    int? courtNumber,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return CourtSchedule(
      courtNumber: courtNumber ?? this.courtNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courtNumber': courtNumber,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory CourtSchedule.fromJson(Map<String, dynamic> json) {
    return CourtSchedule(
      courtNumber: json['courtNumber'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );
  }

  @override
  String toString() {
    return 'Court $courtNumber: ${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

class Game {
  final String id;
  final String? title; // Can be null, will use scheduled date as default
  final String courtName;
  final List<CourtSchedule> schedules;
  final double courtRate;
  final double shuttleCockPrice;
  final bool divideCourtEqually;
  final bool divideShuttleCockEqually;
  final List<String> playerIds; // List of player IDs
  final String?
      payingPlayerId; // Player who pays court when not dividing equally
  final String?
      payingShuttleCockPlayerId; // Player who pays shuttlecock when not dividing equally
  final DateTime createdAt;

  Game({
    required this.id,
    this.title,
    required this.courtName,
    required this.schedules,
    required this.courtRate,
    required this.shuttleCockPrice,
    required this.divideCourtEqually,
    this.divideShuttleCockEqually = true,
    List<String>? playerIds,
    this.payingPlayerId,
    this.payingShuttleCockPlayerId,
    DateTime? createdAt,
  })  : playerIds = playerIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Get display title (use title or format first schedule date)
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    if (schedules.isNotEmpty) {
      final date = schedules.first.startTime;
      return '${_formatDate(date)} Game';
    }
    return 'Untitled Game';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Calculate total hours across all schedules
  double get totalHours {
    return schedules.fold(
        0.0, (sum, schedule) => sum + schedule.durationInHours);
  }

  // Calculate total cost
  double get totalCourtCost {
    return courtRate * totalHours;
  }

  double get totalCost {
    return totalCourtCost + shuttleCockPrice;
  }

  double get courtCostPerPlayer {
    if (divideCourtEqually && playerIds.isNotEmpty) {
      return totalCourtCost / playerIds.length;
    }
    return totalCourtCost;
  }

  double get shuttleCockCostPerPlayer {
    if (divideShuttleCockEqually && playerIds.isNotEmpty) {
      return shuttleCockPrice / playerIds.length;
    }
    return shuttleCockPrice;
  }

  double get totalCostPerPlayer {
    return courtCostPerPlayer + shuttleCockCostPerPlayer;
  }

  Game copyWith({
    String? id,
    String? title,
    String? courtName,
    List<CourtSchedule>? schedules,
    double? courtRate,
    double? shuttleCockPrice,
    bool? divideCourtEqually,
    bool? divideShuttleCockEqually,
    List<String>? playerIds,
    String? payingPlayerId,
    String? payingShuttleCockPlayerId,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      courtName: courtName ?? this.courtName,
      schedules: schedules ?? this.schedules,
      courtRate: courtRate ?? this.courtRate,
      shuttleCockPrice: shuttleCockPrice ?? this.shuttleCockPrice,
      divideCourtEqually: divideCourtEqually ?? this.divideCourtEqually,
      divideShuttleCockEqually:
          divideShuttleCockEqually ?? this.divideShuttleCockEqually,
      playerIds: playerIds ?? this.playerIds,
      payingPlayerId: payingPlayerId ?? this.payingPlayerId,
      payingShuttleCockPlayerId:
          payingShuttleCockPlayerId ?? this.payingShuttleCockPlayerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'courtName': courtName,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'courtRate': courtRate,
      'shuttleCockPrice': shuttleCockPrice,
      'divideCourtEqually': divideCourtEqually,
      'divideShuttleCockEqually': divideShuttleCockEqually,
      'playerIds': playerIds,
      'payingPlayerId': payingPlayerId,
      'payingShuttleCockPlayerId': payingShuttleCockPlayerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String?,
      courtName: json['courtName'] as String,
      schedules: (json['schedules'] as List)
          .map((s) => CourtSchedule.fromJson(s as Map<String, dynamic>))
          .toList(),
      courtRate: (json['courtRate'] as num).toDouble(),
      shuttleCockPrice: (json['shuttleCockPrice'] as num).toDouble(),
      divideCourtEqually: json['divideCourtEqually'] as bool,
      divideShuttleCockEqually:
          json['divideShuttleCockEqually'] as bool? ?? true,
      playerIds: json['playerIds'] != null
          ? List<String>.from(json['playerIds'] as List)
          : [],
      payingPlayerId: json['payingPlayerId'] as String?,
      payingShuttleCockPlayerId: json['payingShuttleCockPlayerId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
