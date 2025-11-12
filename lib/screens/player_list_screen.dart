import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/player_service.dart';
import '../widgets/player_card.dart';
import '../widgets/edit_player_bottom_sheet.dart';
import 'add_player_screen.dart';
import 'dart:async';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  List<Player> players = [];
  List<Player> filteredPlayers = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    // fetches all players from playerservice
    try {
      final loadedPlayers = await PlayerService.getPlayers();
      setState(() {
        players = loadedPlayers;
        filteredPlayers = loadedPlayers;
      });
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading players: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    // searches both nickname and full name
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await PlayerService.searchPlayers(query);
        setState(() {
          filteredPlayers = results;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching players: $e')),
          );
        }
      }
    });
  }

  Future<bool> _confirmDelete(BuildContext context, Player player) async {
    // confirmation dialog
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content:
                  Text('Are you sure you want to delete ${player.nickname}?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _deletePlayer(String playerId) async {
    // actual deletion
    try {
      final success = await PlayerService.deletePlayer(playerId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player deleted successfully')),
          );
          _loadPlayers(); // refreshes the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete player')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting player: $e')),
        );
      }
    }
  }

  Future<void> _showEditPlayerBottomSheet(Player player) async {
    final result = await EditPlayerBottomSheet.show(context, player.id);

    if (result == true) {
      // if edit is successful
      _loadPlayers(); // refresh the list to show changes
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
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by nickname or name...',
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFFEFEFD0)),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              style: const TextStyle(color: Color(0xFFEFEFD0)),
            ),
          ),

          // Player List
          Expanded(
            child: filteredPlayers.isEmpty
                ? const Center(
                    child: Text('No players found'),
                  )
                : ListView.builder(
                    itemCount: filteredPlayers.length,
                    itemBuilder: (context, index) {
                      final player = filteredPlayers[index];
                      return Dismissible(
                        key: Key(player.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) =>
                            _confirmDelete(context, player),
                        onDismissed: (direction) {
                          _deletePlayer(player.id);
                        },
                        child: PlayerCard(
                          player: player,
                          onTap: () => _showEditPlayerBottomSheet(player),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlayerScreen()),
          );

          // Reload players if new player was added
          if (result == true) {
            _loadPlayers();
          }
        },
        backgroundColor: const Color(0xFF004E89),
        child: const Icon(Icons.add, color: Color(0xFFEFEFD0)),
      ),
    );
  }
}
