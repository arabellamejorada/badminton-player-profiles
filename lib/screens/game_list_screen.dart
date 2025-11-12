import 'package:flutter/material.dart';
import 'dart:async';
import '../models/game.dart';
import '../services/game_service.dart';
import '../widgets/game_card.dart';
import '../widgets/view_game_bottom_sheet.dart';
import 'add_game_screen.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  List<Game> games = [];
  List<Game> filteredGames = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadGames() async {
    try {
      final loadedGames = await GameService.getGamesSortedByDate();
      setState(() {
        games = loadedGames;
        filteredGames = loadedGames;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading games: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await GameService.searchGames(query);
        setState(() {
          filteredGames = results;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching games: $e')),
          );
        }
      }
    });
  }

  Future<bool> _confirmDelete(BuildContext context, Game game) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: Text(
                  'Are you sure you want to delete "${game.displayTitle}"?'),
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

  Future<void> _deleteGame(String gameId) async {
    try {
      final success = await GameService.deleteGame(gameId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadGames();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete game'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting game: $e')),
        );
      }
    }
  }

  void _navigateToAddGame() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGameScreen()),
    );

    if (result == true) {
      _loadGames();
    }
  }

  void _openGameDetails(Game game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ViewGameBottomSheet(
        game: game,
        onGameUpdated: _loadGames,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Games'),
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
                hintText: 'Search by name or date...',
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

          // Game List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadGames,
              child: ListView.builder(
                itemCount: filteredGames.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final game = filteredGames[index];
                  return Dismissible(
                    key: Key(game.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Colors.white, size: 32),
                          SizedBox(height: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) =>
                        _confirmDelete(context, game),
                    onDismissed: (direction) {
                      _deleteGame(game.id);
                    },
                    child: GameCard(
                      game: game,
                      onTap: () => _openGameDetails(game),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGame,
        backgroundColor: const Color(0xFF004E89),
        foregroundColor: const Color(0xFFEFEFD0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
