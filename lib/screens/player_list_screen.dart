import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/player_service.dart';
import '../widgets/player_card.dart';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  List<Player> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      final loadedPlayers = await PlayerService.getPlayers();
      setState(() {
        players = loadedPlayers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading players: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Players'),
        backgroundColor: const Color(0xFF004E89),
        foregroundColor: const Color(0xFFEFEFD0),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF004E89),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search players...',
                hintStyle: const TextStyle(color: Color(0xFFEFEFD0)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFEFEFD0),
                ),
                suffixIcon: const Icon(
                  Icons.filter_list,
                  color: Color(0xFFEFEFD0),
                ),
              ),
              style: const TextStyle(color: Color(0xFFEFEFD0)),
            ),
          ),
          
          // Player List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : players.isEmpty
                    ? const Center(
                        child: Text('No players found'),
                      )
                    : ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return PlayerCard(
                            player: player,
                            onTap: () {
                              // TODO: Navigate to player details
                              print('Tapped on ${player.nickname}');
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add player screen
          print('Add new player');
        },
        backgroundColor: const Color(0xFF004E89),
        child: const Icon(Icons.add, color: Color(0xFFEFEFD0)),
      ),
    );
  }
}
