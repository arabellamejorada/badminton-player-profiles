import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';
import '../utils/form_validator.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courtNameController = TextEditingController();
  final _courtRateController = TextEditingController();
  final _shuttleCockPriceController = TextEditingController();
  bool _divideCourtEqually = true;
  bool _divideShuttleCockEqually = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _courtNameController.text = settings.courtName;
      _courtRateController.text = settings.courtRate.toString();
      _shuttleCockPriceController.text = settings.shuttleCockPrice.toString();
      _divideCourtEqually = settings.divideCourtEqually;
      _divideShuttleCockEqually = settings.divideShuttleCockEqually;
    });
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttleCockPriceController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = UserSettings(
        courtName: _courtNameController.text.trim(),
        courtRate: double.parse(_courtRateController.text),
        shuttleCockPrice: double.parse(_shuttleCockPriceController.text),
        divideCourtEqually: _divideCourtEqually,
        divideShuttleCockEqually: _divideShuttleCockEqually,
      );

      final success = await SettingsService.saveSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Settings saved successfully!'
                : 'Failed to save settings'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Default Court Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure default values for court bookings and games',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Court Name Field
              TextFormField(
                controller: _courtNameController,
                decoration: InputDecoration(
                  labelText: 'Default Court Name',
                  hintText: 'e.g., Main Court, Court A',
                  prefixIcon: Icon(Icons.stadium),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) =>
                    FormValidator.validateRequired(value, 'court name'),
              ),
              const SizedBox(height: 16),

              // Court Rate Field
              TextFormField(
                controller: _courtRateController,
                decoration: InputDecoration(
                  labelText: 'Default Court Rate (per hour)',
                  hintText: 'e.g., 400',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'PHP/hour',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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

              // Shuttlecock Price Field
              TextFormField(
                controller: _shuttleCockPriceController,
                decoration: InputDecoration(
                  labelText: 'Default Shuttlecock Price (per game)',
                  hintText: 'e.g., 50',
                  prefixIcon: Icon(Icons.sports_tennis),
                  suffixText: 'PHP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                  title:
                      const Text('Divide the court rate equally among players'),
                  subtitle: Text(
                    _divideCourtEqually
                        ? 'Court rate will be divided equally among all players'
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
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),

              // Divide Shuttlecock Equally Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 1,
                  ),
                ),
                child: CheckboxListTile(
                  title: const Text(
                      'Divide shuttlecock price equally among players'),
                  subtitle: Text(
                    _divideShuttleCockEqually
                        ? 'Shuttlecock price will be divided equally among all players'
                        : 'Full shuttlecock price will be charged per game',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  value: _divideShuttleCockEqually,
                  onChanged: (bool? value) {
                    setState(() {
                      _divideShuttleCockEqually = value ?? true;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 24),

              // Cost Preview
              if (_courtRateController.text.isNotEmpty &&
                  _shuttleCockPriceController.text.isNotEmpty)
                _buildCostPreview(),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: Icon(Icons.save),
                  label: Text(
                    'Save Settings',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostPreview() {
    final courtRate = double.tryParse(_courtRateController.text) ?? 0;
    final shuttleCockPrice =
        double.tryParse(_shuttleCockPriceController.text) ?? 0;

    final courtCostPerPlayer = _divideCourtEqually ? courtRate / 4 : courtRate;
    final shuttleCockCostPerPlayer = shuttleCockPrice / 4;
    final totalPerPlayer = courtCostPerPlayer + shuttleCockCostPerPlayer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Cost Preview (per player)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          Divider(height: 16, color: Colors.green[300]),
          _buildCostRow('Court Rate', courtCostPerPlayer),
          _buildCostRow('Shuttlecock', shuttleCockCostPerPlayer),
          Divider(height: 16, color: Colors.green[300]),
          _buildCostRow('Total per Player', totalPerPlayer, isBold: true),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            'PHP ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold ? Colors.green[900] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
