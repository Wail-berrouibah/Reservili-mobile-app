class Validators {
  static String? required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? phone(
      String? value, String requiredMsg, String invalidMsg) {
    if (value == null || value.trim().isEmpty) return requiredMsg;
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(cleaned)) return invalidMsg;
    return null;
  }

  static String? email(String? value, String invalidMsg) {
    if (value == null || value.trim().isEmpty) return null;
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(value.trim());
    return ok ? null : invalidMsg;
  }

  static String? accessCode(String? value, String message) {
    if (value == null || value.trim().length < 4) return message;
    return null;
  }

  static String? positiveNumber(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    final n = num.tryParse(value.trim());
    if (n == null || n <= 0) return message;
    return null;
  }
}
