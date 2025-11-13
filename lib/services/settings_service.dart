import '../models/user_settings.dart';

class SettingsService {
  // In-memory storage for now - in production, use SharedPreferences or similar
  static UserSettings? _cachedSettings;

  // Get current settings or return defaults
  static Future<UserSettings> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    // Return default settings
    return UserSettings(
      courtName: 'Main Court',
      courtRate: 400.0,
      shuttleCockPrice: 50.0,
      divideCourtEqually: true,
      divideShuttleCockEqually: true,
    );
  }

  // Save settings
  static Future<bool> saveSettings(UserSettings settings) async {
    try {
      _cachedSettings = settings;
      return true;
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  // Clear settings (for testing or logout)
  static Future<void> clearSettings() async {
    _cachedSettings = null;
    // TODO: Clear from SharedPreferences
  }
}
