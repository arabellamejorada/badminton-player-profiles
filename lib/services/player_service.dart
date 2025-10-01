import '../models/player.dart';
import '../data/mock_player_data.dart';

class PlayerService {
  static List<Player> getMockPlayers() {
    return MockPlayerData.players;
  }

  static Future<List<Player>> getPlayers() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return getMockPlayers();
  }

  static Future<Player?> getPlayerById(String id) async {
    final players = await getPlayers();
    try {
      return players.firstWhere((player) => player.id == id);
    } catch (e) {
      return null;
    }
  }
}
