// lib/utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length < 3) return 'Title must be at least 3 characters';
    if (value.trim().length > 100) return 'Title must be under 100 characters';
    return null;
  }
}
