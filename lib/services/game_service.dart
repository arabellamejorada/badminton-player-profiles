import '../models/game.dart';

class GameService {
  // In-memory storage for games (in production, use a database)
  static final List<Game> _games = [];
  static int _nextId = 1;

  // Get all games
  static Future<List<Game>> getGames() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_games);
  }

  // Get a single game by ID
  static Future<Game?> getGameById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new game
  static Future<Game> addGame(Game game) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate ID if not provided
    final gameWithId =
        game.id.isEmpty ? game.copyWith(id: (_nextId++).toString()) : game;

    _games.add(gameWithId);
    return gameWithId;
  }

  // Update an existing game
  static Future<bool> updateGame(Game updatedGame) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _games.indexWhere((game) => game.id == updatedGame.id);
    if (index != -1) {
      _games[index] = updatedGame;
      return true;
    }
    return false;
  }

  // Delete a game
  static Future<bool> deleteGame(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final initialLength = _games.length;
    _games.removeWhere((game) => game.id == id);
    return _games.length < initialLength;
  }

  // Search games by title or date
  static Future<List<Game>> searchGames(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (query.isEmpty) {
      return List.from(_games);
    }

    final lowerQuery = query.toLowerCase();
    return _games.where((game) {
      // Search by title
      final titleMatch = game.displayTitle.toLowerCase().contains(lowerQuery);

      // Search by date
      final dateMatch = game.schedules.any((schedule) {
        final dateStr = _formatDate(schedule.startTime).toLowerCase();
        return dateStr.contains(lowerQuery);
      });

      // Search by court name
      final courtMatch = game.courtName.toLowerCase().contains(lowerQuery);

      return titleMatch || dateMatch || courtMatch;
    }).toList();
  }

  static String _formatDate(DateTime date) {
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

  // Get games sorted by date (most recent first)
  static Future<List<Game>> getGamesSortedByDate() async {
    final games = await getGames();
    games.sort((a, b) {
      final aDate =
          a.schedules.isNotEmpty ? a.schedules.first.startTime : a.createdAt;
      final bDate =
          b.schedules.isNotEmpty ? b.schedules.first.startTime : b.createdAt;
      return bDate.compareTo(aDate); // Descending order
    });
    return games;
  }

  // Clear all games (for testing)
  static Future<void> clearAllGames() async {
    _games.clear();
    _nextId = 1;
  }
}
