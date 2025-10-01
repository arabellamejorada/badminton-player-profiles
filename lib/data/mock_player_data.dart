import '../models/player.dart';

class MockPlayerData {
  static const List<Map<String, dynamic>> playersJson = [
    {
      "id": "1",
      "nickname": "Thunder",
      "fullName": "Marcus Johnson",
      "gender": "male",
      "skillLevel": "Professional"
    },
    {
      "id": "2",
      "nickname": "Lightning",
      "fullName": "Sarah Chen",
      "gender": "female",
      "skillLevel": "Advanced"
    },
    {
      "id": "3",
      "nickname": "Phoenix",
      "fullName": "David Martinez",
      "gender": "male",
      "skillLevel": "Intermediate"
    },
    {
      "id": "4",
      "nickname": "Ace",
      "fullName": "Emma Thompson",
      "gender": "female",
      "skillLevel": "Professional"
    },
    {
      "id": "5",
      "nickname": "Rookie",
      "fullName": "Alex Kim",
      "gender": "male",
      "skillLevel": "Beginner"
    }
  ];

  static List<Player> get players {
    return playersJson.map((json) => Player.fromJson(json)).toList();
  }
}
