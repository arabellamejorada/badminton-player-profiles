import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;

  const PlayerCard({
    super.key,
    required this.player,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gender icon (girl or boy)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: player.gender == 'female' 
                      ? Colors.pink.withOpacity(0.1) 
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  player.gender == 'female' ? Icons.woman : Icons.man,
                  size: 30,
                  color: player.gender == 'female' ? Colors.pink : Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              
              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nickname (main text)
                    Text(
                      player.nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Full name
                    Text(
                      player.fullName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Skill level
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSkillLevelColor(player.skillLevel).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getSkillLevelColor(player.skillLevel),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        player.skillLevel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getSkillLevelColor(player.skillLevel),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'professional':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
