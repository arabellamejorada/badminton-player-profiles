import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../services/game_service.dart';
import '../services/player_service.dart';

class EditGameBottomSheet extends StatefulWidget {
  final Game game;
  final VoidCallback onGameUpdated;

  const EditGameBottomSheet({
    super.key,
    required this.game,
    required this.onGameUpdated,
  });

  @override
  State<EditGameBottomSheet> createState() => _EditGameBottomSheetState();
}

class _EditGameBottomSheetState extends State<EditGameBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courtNameController;
  late TextEditingController _courtRateController;
  late TextEditingController _shuttleCockPriceController;
  late bool _divideCourtEqually;
  late List<CourtSchedule> _schedules;
  late List<String> _selectedPlayerIds;
  List<Player> _availablePlayers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.game.title ?? '');
    _courtNameController = TextEditingController(text: widget.game.courtName);
    _courtRateController =
        TextEditingController(text: widget.game.courtRate.toString());
    _shuttleCockPriceController =
        TextEditingController(text: widget.game.shuttleCockPrice.toString());
    _divideCourtEqually = widget.game.divideCourtEqually;
    _schedules = List.from(widget.game.schedules);
    _selectedPlayerIds = List.from(widget.game.playerIds);
    _loadPlayers();
    _checkExistingOverlaps();
  }

  void _checkExistingOverlaps() {
    // Check if there are any existing overlaps in the loaded schedules
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _schedules.length; i++) {
        final overlap = _checkScheduleOverlap(_schedules[i], i);
        if (overlap != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Warning: $overlap\nPlease fix overlapping schedules.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          break; // Only show first overlap warning
        }
      }
    });
  }

  Future<void> _loadPlayers() async {
    final players = await PlayerService.getPlayers();
    setState(() {
      _availablePlayers = players;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttleCockPriceController.dispose();
    super.dispose();
  }

  void _addSchedule() async {
    final now = DateTime.now();
    final defaultStart =
        DateTime(now.year, now.month, now.day, 18, 0); // 6:00 PM
    final defaultEnd = DateTime(now.year, now.month, now.day, 21, 0); // 9:00 PM

    final schedule = await showDialog<CourtSchedule>(
      context: context,
      builder: (context) => _SchedulePickerDialog(
        courtNumber: _schedules.length + 1,
        initialStartTime: defaultStart,
        initialEndTime: defaultEnd,
      ),
    );

    if (schedule != null) {
      // Check for overlaps before adding
      final overlap = _checkScheduleOverlap(schedule, null);
      if (overlap != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(overlap),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() {
        _schedules.add(schedule);
      });
    }
  }

  void _editSchedule(int index) async {
    final schedule = _schedules[index];
    final editedSchedule = await showDialog<CourtSchedule>(
      context: context,
      builder: (context) => _SchedulePickerDialog(
        courtNumber: schedule.courtNumber,
        initialStartTime: schedule.startTime,
        initialEndTime: schedule.endTime,
      ),
    );

    if (editedSchedule != null) {
      // Check for overlaps before updating (excluding current index)
      final overlap = _checkScheduleOverlap(editedSchedule, index);
      if (overlap != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(overlap),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() {
        _schedules[index] = editedSchedule;
      });
    }
  }

  // Check if a schedule overlaps with existing schedules
  // Returns error message if overlap found, null if no overlap
  String? _checkScheduleOverlap(CourtSchedule newSchedule, int? excludeIndex) {
    for (int i = 0; i < _schedules.length; i++) {
      // Skip the schedule being edited
      if (excludeIndex != null && i == excludeIndex) continue;

      final existing = _schedules[i];

      // Only check if same court number
      if (existing.courtNumber == newSchedule.courtNumber) {
        // Check if dates are the same (ignoring time)
        final existingDate = DateTime(
          existing.startTime.year,
          existing.startTime.month,
          existing.startTime.day,
        );
        final newDate = DateTime(
          newSchedule.startTime.year,
          newSchedule.startTime.month,
          newSchedule.startTime.day,
        );

        if (existingDate.isAtSameMomentAs(newDate)) {
          // Check for time overlap
          // Overlap occurs if: new starts before existing ends AND new ends after existing starts
          if (newSchedule.startTime.isBefore(existing.endTime) &&
              newSchedule.endTime.isAfter(existing.startTime)) {
            final timeFormat = (DateTime time) {
              final hour = time.hour > 12
                  ? time.hour - 12
                  : (time.hour == 0 ? 12 : time.hour);
              final period = time.hour >= 12 ? 'PM' : 'AM';
              final minute = time.minute.toString().padLeft(2, '0');
              return '$hour:$minute $period';
            };

            return 'Schedule overlap detected! Court ${existing.courtNumber} is already booked from ${timeFormat(existing.startTime)} to ${timeFormat(existing.endTime)} on this date.';
          }
        }
      }
    }
    return null; // No overlap found
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  void _removePlayer(String playerId) {
    setState(() {
      _selectedPlayerIds.remove(playerId);
    });
  }

  void _showPlayerSelection() async {
    final selectedIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => _PlayerSelectionDialog(
        availablePlayers: _availablePlayers,
        selectedPlayerIds: List.from(_selectedPlayerIds),
      ),
    );

    if (selectedIds != null) {
      setState(() {
        _selectedPlayerIds = selectedIds;
      });
    }
  }

  void _saveGame() async {
    if (_formKey.currentState!.validate()) {
      if (_schedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one schedule'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      final updatedGame = Game(
        id: widget.game.id,
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        courtName: _courtNameController.text.trim(),
        schedules: _schedules,
        courtRate: double.parse(_courtRateController.text),
        shuttleCockPrice: double.parse(_shuttleCockPriceController.text),
        divideCourtEqually: _divideCourtEqually,
        playerIds: _selectedPlayerIds,
      );

      try {
        final success = await GameService.updateGame(updatedGame);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Game updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onGameUpdated();
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update game'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isSaving = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating game: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  String _formatDate(DateTime date) {
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

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Game',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004E89),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Game Title (Optional)',
                        hintText: 'Leave blank to use scheduled date',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Court Name
                    TextFormField(
                      controller: _courtNameController,
                      decoration: InputDecoration(
                        labelText: 'Court Name',
                        hintText: 'e.g., Main Court, Court A',
                        prefixIcon: const Icon(Icons.stadium),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a court name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Schedules Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Court Schedules',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addSchedule,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004E89),
                            foregroundColor: const Color(0xFFEFEFD0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ..._schedules.asMap().entries.map((entry) {
                      final index = entry.key;
                      final schedule = entry.value;
                      return _buildScheduleCard(schedule, index);
                    }).toList(),

                    const SizedBox(height: 24),

                    // Players Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Players (${_selectedPlayerIds.length}/4)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showPlayerSelection(),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Select Players'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Selected Players Chips
                    if (_selectedPlayerIds.isNotEmpty &&
                        _availablePlayers.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedPlayerIds.map((playerId) {
                          final player = _availablePlayers.firstWhere(
                              (p) => p.id == playerId,
                              orElse: () => Player(
                                    id: playerId,
                                    nickname: 'Unknown',
                                    fullName: 'Unknown Player',
                                    gender: 'male',
                                    skillLevel: 'Beginner',
                                  ));
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: const Color(0xFF004E89),
                              child: Text(
                                player.nickname[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            label: Text(
                              player.nickname,
                              style: const TextStyle(fontSize: 13),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removePlayer(player.id),
                            backgroundColor: Colors.blue[50],
                            deleteIconColor: Colors.red[700],
                          );
                        }).toList(),
                      )
                    else if (_selectedPlayerIds.isNotEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'No players selected',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Court Rate
                    TextFormField(
                      controller: _courtRateController,
                      decoration: InputDecoration(
                        labelText: 'Court Rate (per hour)',
                        hintText: 'e.g., 400',
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: 'PHP/hour',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a court rate';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Shuttlecock Price
                    TextFormField(
                      controller: _shuttleCockPriceController,
                      decoration: InputDecoration(
                        labelText: 'Shuttlecock Price (per game)',
                        hintText: 'e.g., 50',
                        prefixIcon: const Icon(Icons.sports_tennis),
                        suffixText: 'PHP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a shuttlecock price';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Divide Court Equally Checkbox
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                            'Divide the court rate equally among players'),
                        subtitle: Text(
                          _divideCourtEqually
                              ? 'Court rate will be divided equally among 4 players'
                              : 'Full court rate will be charged per game',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        value: _divideCourtEqually,
                        onChanged: (bool? value) {
                          setState(() {
                            _divideCourtEqually = value ?? true;
                          });
                        },
                        activeColor: const Color(0xFF004E89),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004E89),
                  foregroundColor: const Color(0xFFEFEFD0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFEFEFD0)),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(CourtSchedule schedule, int index) {
    // Check if this schedule overlaps with any other
    final hasOverlap = _checkScheduleOverlap(schedule, index) != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: hasOverlap ? Colors.red[50] : null,
      shape: hasOverlap
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.red[300]!, width: 2),
            )
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              hasOverlap ? Colors.red[700] : const Color(0xFF004E89),
          child: hasOverlap
              ? const Icon(Icons.warning, color: Colors.white, size: 20)
              : Text(
                  schedule.courtNumber.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
        ),
        title: Row(
          children: [
            Text('Court ${schedule.courtNumber}'),
            if (hasOverlap) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'OVERLAP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${_formatDate(schedule.startTime)} • ${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
          style: TextStyle(
            color: hasOverlap ? Colors.red[900] : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editSchedule(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeSchedule(index),
            ),
          ],
        ),
      ),
    );
  }
}

// Schedule Picker Dialog (reused from add_game_screen)
class _SchedulePickerDialog extends StatefulWidget {
  final int courtNumber;
  final DateTime initialStartTime;
  final DateTime initialEndTime;

  const _SchedulePickerDialog({
    required this.courtNumber,
    required this.initialStartTime,
    required this.initialEndTime,
  });

  @override
  State<_SchedulePickerDialog> createState() => _SchedulePickerDialogState();
}

class _SchedulePickerDialogState extends State<_SchedulePickerDialog> {
  late int _courtNumber;
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _courtNumber = widget.courtNumber;
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _startTime = DateTime(
          date.year,
          date.month,
          date.day,
          _startTime.hour,
          _startTime.minute,
        );
        _endTime = DateTime(
          date.year,
          date.month,
          date.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );

    if (time != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );

    if (time != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _formatDate(DateTime date) {
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

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _endTime.isAfter(_startTime);

    return AlertDialog(
      title: const Text('Edit Court Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Number
            TextFormField(
              initialValue: _courtNumber.toString(),
              decoration: const InputDecoration(
                labelText: 'Court Number',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final num = int.tryParse(value);
                if (num != null && num > 0) {
                  _courtNumber = num;
                }
              },
            ),
            const SizedBox(height: 16),

            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(_formatDate(_startTime)),
              onTap: _pickDate,
            ),
            const Divider(),

            // Start Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Start Time'),
              subtitle: Text(_formatTime(_startTime)),
              onTap: _pickStartTime,
            ),
            const Divider(),

            // End Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('End Time'),
              subtitle: Text(_formatTime(_endTime)),
              onTap: _pickEndTime,
            ),

            if (!isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'End time must be after start time',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isValid
              ? () {
                  final schedule = CourtSchedule(
                    courtNumber: _courtNumber,
                    startTime: _startTime,
                    endTime: _endTime,
                  );
                  Navigator.pop(context, schedule);
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Player Selection Dialog
class _PlayerSelectionDialog extends StatefulWidget {
  final List<Player> availablePlayers;
  final List<String> selectedPlayerIds;

  const _PlayerSelectionDialog({
    required this.availablePlayers,
    required this.selectedPlayerIds,
  });

  @override
  State<_PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<_PlayerSelectionDialog> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedPlayerIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Players (${_selectedIds.length}/4)'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.availablePlayers.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No players available. Add players first in the Players tab.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availablePlayers.length,
                itemBuilder: (context, index) {
                  final player = widget.availablePlayers[index];
                  final isSelected = _selectedIds.contains(player.id);
                  final canSelect = _selectedIds.length < 4 || isSelected;

                  return CheckboxListTile(
                    value: isSelected,
                    enabled: canSelect,
                    onChanged: canSelect
                        ? (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedIds.add(player.id);
                              } else {
                                _selectedIds.remove(player.id);
                              }
                            });
                          }
                        : null,
                    title: Text(player.nickname),
                    subtitle: Text(player.fullName),
                    secondary: CircleAvatar(
                      backgroundColor: const Color(0xFF004E89),
                      child: Text(
                        player.nickname[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedIds),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
