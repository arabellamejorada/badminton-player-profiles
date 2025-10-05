import 'package:flutter/material.dart';

class BadmintonLevelSelector extends StatefulWidget {
  final String initialLevel;
  final String initialStrength;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<String> onStrengthChanged;
  final ValueChanged<RangeValues>? onRangeChanged;
  
  const BadmintonLevelSelector({
    super.key,
    required this.initialLevel,
    required this.initialStrength,
    required this.onLevelChanged,
    required this.onStrengthChanged,
    this.onRangeChanged,
  });

  @override
  State<BadmintonLevelSelector> createState() => _BadmintonLevelSelectorState();
}

class _BadmintonLevelSelectorState extends State<BadmintonLevelSelector> {
  // We're skipping 'Beginners' in this implementation to match the reference design
  static const List<String> displayLevels = [
    'INTERMEDIATE',
    'LEVEL G',
    'LEVEL F',
    'LEVEL E',
    'LEVEL D',
    'OPEN'
  ];
  
  static const List<String> strengthLabels = ['W', 'M', 'S'];
  
  // Maximum value for the slider (total number of positions)
  // Each level has 3 strengths (W,M,S), and we have 6 levels
  static const double maxValue = 17; // (6 * 3 - 1)
  
  // Range values for the RangeSlider (start and end positions)
  late RangeValues _currentRange;
  
  @override
  void initState() {
    super.initState();
    // Initialize the range based on the initial level and strength
    final levelIndex = _getLevelIndex(widget.initialLevel);
    final strengthIndex = _getStrengthIndex(widget.initialStrength);
    
    // Calculate the start value (for this example, we'll set the range to cover a few positions)
    final startValue = (levelIndex * 3 + strengthIndex - 1).clamp(0.0, maxValue).toDouble();
    final endValue = (levelIndex * 3 + strengthIndex + 1).clamp(0.0, maxValue).toDouble();
    
    _currentRange = RangeValues(startValue, endValue);
  }
  
  // Helper methods to convert between level names and indices
  int _getLevelIndex(String level) {
    switch (level) {
      case 'Intermediate': return 0;
      case 'Level G': return 1;
      case 'Level F': return 2;
      case 'Level E': return 3;
      case 'Level D': return 4;
      case 'Open Player': return 5;
      default: return 0; // Default to Intermediate
    }
  }
  
  int _getStrengthIndex(String strength) {
    switch (strength) {
      case 'Weak': return 0;
      case 'Mid': return 1;
      case 'Strong': return 2;
      default: return 1; // Default to Mid
    }
  }
  
  // Convert slider position to level and strength
  String _getLevelFromPosition(double position) {
    final levelIndex = (position / 3).floor();
    switch (levelIndex) {
      case 0: return 'Intermediate';
      case 1: return 'Level G';
      case 2: return 'Level F';
      case 3: return 'Level E';
      case 4: return 'Level D';
      case 5: return 'Open Player';
      default: return 'Intermediate';
    }
  }
  
  String _getStrengthFromPosition(double position) {
    final strengthIndex = position.round() % 3;
    switch (strengthIndex) {
      case 0: return 'Weak';
      case 1: return 'Mid';
      case 2: return 'Strong';
      default: return 'Mid';
    }
  }
  
  // Update the callbacks when the range changes
  void _updateFromRangeValues(RangeValues values) {
    setState(() {
      _currentRange = values;
    });
    
    // Get the level and strength from the start handle position
    final startLevel = _getLevelFromPosition(values.start);
    final startStrength = _getStrengthFromPosition(values.start);
    
    // Notify the parent widget
    widget.onLevelChanged(startLevel);
    widget.onStrengthChanged(startStrength);
    
    // If range changed callback is provided, notify with the full range
    if (widget.onRangeChanged != null) {
      widget.onRangeChanged!(values);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    // We don't need to show the current range values in the UI per the design
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEVEL text heading
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          // child: Text(
          //   'LEVEL',
          //   style: TextStyle(
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black87,
          //   ),
          // ),
        ),
        
        // RangeSlider component
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            activeTrackColor: primaryColor,
            inactiveTrackColor: Colors.lightBlue.shade100,
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayColor: primaryColor.withOpacity(0.2),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
          ),
          child: RangeSlider(
            values: _currentRange,
            min: 0,
            max: maxValue,
            divisions: maxValue.toInt(),
            onChanged: (values) {
              _updateFromRangeValues(values);
            },
          ),
        ),
        
        // Strength indicators and level labels
        _buildStrengthAndLevelLabels(),
      ],
    );
  }
  
  Widget _buildStrengthAndLevelLabels() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          // W M S indicators with proper spacing
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 18; // 6 levels * 3 strengths
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    displayLevels.length * strengthLabels.length,
                    (index) {
                      final strengthIndex = index % 3;
                      final strengthLabel = strengthLabels[strengthIndex];
                      
                      return SizedBox(
                        width: itemWidth,
                        child: Text(
                          strengthLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Level labels with responsive width
          LayoutBuilder(
            builder: (context, constraints) {
              final levelWidth = constraints.maxWidth / displayLevels.length;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: displayLevels.map((level) {
                  return SizedBox(
                    width: levelWidth,
                    child: Text(
                      level,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
  

  

}