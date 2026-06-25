class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value.trim());
    if (number == null || number <= 0) {
      return '$fieldName must be a positive number';
    }
    return null;
  }

  static String? dateNotInPast(DateTime? date, [String fieldName = 'Date']) {
    if (date == null) return '$fieldName is required';
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return '$fieldName cannot be in the past';
    }
    return null;
  }

  static String? endAfterStart(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (!end.isAfter(start)) {
      return 'End date must be after start date';
    }
    return null;
  }
}
