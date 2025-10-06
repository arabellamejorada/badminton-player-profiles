class FormValidator {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Philippine phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }

    // Remove spaces and dashes for validation
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check for Philippine mobile number format: 09XXXXXXXXX (11 digits total)
    if (cleanedValue.startsWith('09')) {
      if (cleanedValue.length != 11) {
        return 'Mobile number starting with 09 must be exactly 11 digits';
      }
      final mobileRegex = RegExp(r'^09\d{9}$');
      if (!mobileRegex.hasMatch(cleanedValue)) {
        return 'Please enter a valid mobile number (09XXXXXXXXX)';
      }
      return null;
    }

    // Check for international format: +639XXXXXXXXX (13 characters total)
    if (cleanedValue.startsWith('+639')) {
      if (cleanedValue.length != 13) {
        return 'International number with +639 must be exactly 13 characters';
      }
      final intlRegex = RegExp(r'^\+639\d{9}$');
      if (!intlRegex.hasMatch(cleanedValue)) {
        return 'Please enter a valid international number (+639XXXXXXXXX)';
      }
      return null;
    }

    // If it doesn't match either format
    return 'Please enter a valid Philippine phone number:\n• Mobile: 09XXXXXXXXX (11 digits)\n• International: +639XXXXXXXXX';
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }

    return null;
  }
}
