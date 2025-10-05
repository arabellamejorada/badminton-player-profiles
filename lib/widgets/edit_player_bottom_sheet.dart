import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../constants/app_constants.dart';
import '../services/player_service.dart';
import '../utils/form_validator.dart';
import 'badminton_level_selector.dart';

class EditPlayerBottomSheet extends StatefulWidget {
  final String playerId;
  
  const EditPlayerBottomSheet({
    super.key, 
    required this.playerId,
  });

  static Future<bool?> show(BuildContext context, String playerId) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditPlayerBottomSheet(playerId: playerId),
    );
  }

  @override
  State<EditPlayerBottomSheet> createState() => _EditPlayerBottomSheetState();
}

class _EditPlayerBottomSheetState extends State<EditPlayerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarksController = TextEditingController();
  
  // Selected values
  String _selectedGender = AppConstants.genderOptions[0];
  String _selectedLevel = AppConstants.badmintonLevels[0];
  String _selectedStrength = AppConstants.strengthLevels[1]; // Default to Mid
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }
  
  Future<void> _loadPlayerData() async {
    try {
      final player = await PlayerService.getPlayerById(widget.playerId);
      if (player != null) {
        setState(() {
          // Populate form fields
          _nicknameController.text = player.nickname;
          _fullNameController.text = player.fullName;
          _contactNumberController.text = player.contactNumber ?? '';
          _emailController.text = player.email ?? '';
          _addressController.text = player.address ?? '';
          _remarksController.text = player.remarks ?? '';
          
          _selectedGender = player.gender;
          
          if (player.badmintonLevel != null) {
            _selectedLevel = player.badmintonLevel!.level;
            _selectedStrength = player.badmintonLevel!.strength;
          } else {
            _selectedLevel = player.skillLevel;
            _selectedStrength = player.skillLevelStrength ?? 'Mid';
          }
          
          _isLoading = false;
        });
      } else {
        _showErrorAndNavigateBack('Player not found');
      }
    } catch (e) {
      _showErrorAndNavigateBack('Error loading player: $e');
    }
  }
  
  void _showErrorAndNavigateBack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _updatePlayer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final badmintonLevel = BadmintonLevel(
          level: _selectedLevel,
          strength: _selectedStrength,
        );
        
        // Create updated player
        final updatedPlayer = Player(
          id: widget.playerId,
          nickname: _nicknameController.text,
          fullName: _fullNameController.text,
          gender: _selectedGender,
          skillLevel: _selectedLevel,
          skillLevelStrength: _selectedStrength,
          contactNumber: _contactNumberController.text,
          email: _emailController.text,
          address: _addressController.text,
          remarks: _remarksController.text,
          badmintonLevel: badmintonLevel,
        );
        
        // Update player using service
        await PlayerService.updatePlayer(updatedPlayer);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player updated successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating player: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Calculate the height of the bottom sheet (80% of the screen height)
    final bottomSheetHeight = MediaQuery.of(context).size.height * 0.9;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: bottomSheetHeight + bottomPadding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // App Bar with Title
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF004E89),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle indicator
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      
                      // App Bar with Title
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Edit Player',
                                style: TextStyle(
                                  color: Color(0xFFEFEFD0),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFFEFEFD0)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form content with scrolling
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Info Section
                          _buildSectionTitle('Basic Information'),
                          _buildTextFormField(
                            controller: _nicknameController,
                            labelText: 'Nickname',
                            validator: (value) => FormValidator.validateRequired(value, 'nickname'),
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _fullNameController,
                            labelText: 'Full Name',
                            validator: (value) => FormValidator.validateRequired(value, 'full name'),
                          ),
                          const SizedBox(height: 16),
                          
                          // Gender Selection
                          _buildSectionTitle('Gender'),
                          _buildGenderSelection(),
                          const SizedBox(height: 24),
                          
                          // Contact Information Section
                          _buildSectionTitle('Contact Information'),
                          _buildTextFormField(
                            controller: _contactNumberController,
                            labelText: 'Contact Number',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: FormValidator.validatePhoneNumber,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _emailController,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: FormValidator.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _addressController,
                            labelText: 'Address',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          
                          // Badminton Level Section
                          _buildSectionTitle('Badminton Level'),
                          BadmintonLevelSelector(
                            initialLevel: _selectedLevel,
                            initialStrength: _selectedStrength,
                            onLevelChanged: (level) {
                              setState(() {
                                _selectedLevel = level;
                              });
                            },
                            onStrengthChanged: (strength) {
                              setState(() {
                                _selectedStrength = strength;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Remarks Section
                          _buildSectionTitle('Additional Information'),
                          _buildTextFormField(
                            controller: _remarksController,
                            labelText: 'Remarks',
                            maxLines: 4,
                            hintText: 'Enter any additional notes or remarks about the player',
                          ),
                          const SizedBox(height: 32),
                          
                          // Action Buttons
                          _buildActionButtons(),
                          // Extra space at bottom for keyboard
                          SizedBox(height: bottomPadding > 0 ? 20 : 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF004E89),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: AppConstants.genderOptions.map((gender) {
        final String displayText = gender == 'male' ? 'Male' : 'Female';
        return Expanded(
          child: RadioListTile<String>(
            title: Text(displayText),
            value: gender,
            groupValue: _selectedGender,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedGender = value;
                });
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Player'),
          content: const Text('Are you sure you want to delete this player? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deletePlayer() async {
    final confirm = await _confirmDelete();
    if (confirm) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final success = await PlayerService.deletePlayer(widget.playerId);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Player deleted successfully')),
            );
            Navigator.pop(context, true); // Return true to indicate success and refresh list
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete player')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting player: $e')),
          );
        }
      }
    }
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Update and Cancel buttons row
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _updatePlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004E89),
                  foregroundColor: const Color(0xFFEFEFD0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Update Player'),
              ),
            ),
          ],
        ),
        
        // Delete button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _deletePlayer,
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text('Delete Player'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}