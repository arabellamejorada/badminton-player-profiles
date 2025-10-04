import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../constants/app_constants.dart';
import '../services/player_service.dart';
import '../utils/form_validator.dart';
import '../widgets/badminton_level_selector.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
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
  
  bool _isLoading = false;
  
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

  Future<void> _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final badmintonLevel = BadmintonLevel(
          level: _selectedLevel,
          strength: _selectedStrength,
        );
        
        final newPlayer = Player(
          id: PlayerService.generateId(),
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
        
        await PlayerService.addPlayer(newPlayer);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player added successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding player: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Player'),
        backgroundColor: const Color(0xFF004E89),
        foregroundColor: const Color(0xFFEFEFD0),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                ],
              ),
            ),
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



  Widget _buildActionButtons() {
    return Row(
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
            onPressed: _savePlayer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004E89),
              foregroundColor: const Color(0xFFEFEFD0),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Player'),
          ),
        ),
      ],
    );
  }
}