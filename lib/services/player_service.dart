import '../models/player.dart';
import '../data/mock_players.dart';

class PlayerService {
  static final List<Player> _players = MockPlayers.getMockPlayers();

  // Get players synchronously (for internal use)
  static List<Player> getPlayersList() {
    return _players;
  }

  static Future<List<Player>> getPlayers() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _players;
  }

  static Future<Player?> getPlayerById(String id) async {
    final players = await getPlayers();
    try {
      return players.firstWhere((player) => player.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<Player> addPlayer(Player player) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    _players.add(player);
    return player;
  }

  static Future<Player> updatePlayer(Player player) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final index = _players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      _players[index] = player;
      return player;
    } else {
      throw Exception('Player not found');
    }
  }

  static Future<bool> deletePlayer(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final index = _players.indexWhere((p) => p.id == id);
    if (index != -1) {
      _players.removeAt(index);
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Player>> searchPlayers(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) {
      return _players;
    }

    final lowerCaseQuery = query.toLowerCase();
    return _players
        .where((player) =>
            player.nickname.toLowerCase().contains(lowerCaseQuery) ||
            player.fullName.toLowerCase().contains(lowerCaseQuery))
        .toList();
  }

  static String generateId() {
    // Simple ID generation - in a real app you might want to use a UUID package
    return ((_players.length + 1).toString());
  }
}
