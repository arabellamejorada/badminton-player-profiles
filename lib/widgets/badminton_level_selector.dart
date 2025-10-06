import 'package:flutter/material.dart';

class BadmintonLevelSelector extends StatefulWidget {
  final String initialLevel;
  final String initialStrength;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<String> onStrengthChanged;

  const BadmintonLevelSelector({
    super.key,
    required this.initialLevel,
    required this.initialStrength,
    required this.onLevelChanged,
    required this.onStrengthChanged,
  });

  @override
  State<BadmintonLevelSelector> createState() => _BadmintonLevelSelectorState();
}

class _BadmintonLevelSelectorState extends State<BadmintonLevelSelector> {
  static const List<String> levels = [
    'Beginners',
    'Intermediate',
    'Level G',
    'Level F',
    'Level E',
    'Level D',
    'Open Player'
  ];

  static const List<String> strengths = ['Weak', 'Mid', 'Strong'];

  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    // Start with Intermediate (Strong) to Level F (Strong) as default range
    _currentRange =
        const RangeValues(4.0, 8.0); // Intermediate(Strong) to Level F(Strong)

    // Defer callback updates until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCallbacks();
    });
  }

  // Convert range values to level and strength
  String _getLevelFromPosition(double position) {
    final levelIndex = (position / 3).floor().clamp(0, levels.length - 1);
    return levels[levelIndex];
  }

  String _getStrengthFromPosition(double position) {
    final strengthIndex = (position % 3).floor();
    return strengths[strengthIndex];
  }

  void _updateCallbacks() {
    final startLevel = _getLevelFromPosition(_currentRange.start);
    final startStrength = _getStrengthFromPosition(_currentRange.start);

    // For now, we'll use the start position for the callbacks
    widget.onLevelChanged(startLevel);
    widget.onStrengthChanged(startStrength);
  }

  @override
  Widget build(BuildContext context) {
    final startLevel = _getLevelFromPosition(_currentRange.start);
    final startStrength = _getStrengthFromPosition(_currentRange.start);
    final endLevel = _getLevelFromPosition(_currentRange.end);
    final endStrength = _getStrengthFromPosition(_currentRange.end);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From/To display
          Text(
            'From: $startLevel ($startStrength)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'To: $endLevel ($endStrength)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Range Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: const Color(0xFF004E89),
              inactiveTrackColor: Colors.grey[300],
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 2,
              ),
              rangeValueIndicatorShape:
                  const PaddleRangeSliderValueIndicatorShape(),
              overlayColor: const Color(0xFF004E89).withOpacity(0.1),
              thumbColor: const Color(0xFF004E89),
            ),
            child: RangeSlider(
              values: _currentRange,
              min: 0,
              max: 20, // 7 levels * 3 strengths - 1
              divisions: 20,
              labels: RangeLabels(
                '$startLevel ($startStrength)',
                '$endLevel ($endStrength)',
              ),
              onChanged: (values) {
                setState(() {
                  _currentRange = values;
                });
                _updateCallbacks();
              },
            ),
          ),

          // Level labels
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLevelLabel('Beginners'),
                _buildLevelLabel('Intermediate'),
                _buildLevelLabel('Level G'),
                _buildLevelLabel('Level F'),
                _buildLevelLabel('Level E'),
                _buildLevelLabel('Level D'),
                _buildLevelLabel('Open Player'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelLabel(String level) {
    return Text(
      level,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.black54,
      ),
    );
  }
}
