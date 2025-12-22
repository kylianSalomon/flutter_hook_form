import 'package:flutter_hook_form/flutter_hook_form.dart';

/// Custom form error messages that override the default messages.
///
/// This allows you to customize validation messages for your entire app,
/// including translations for different locales.
class CustomFormMessages extends FormErrorMessages {
  @override
  String get required => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String minLength(int length) => 'Must be at least $length characters long';

  @override
  String maxLength(int length) => 'Cannot exceed $length characters';

  @override
  String dateAfter(DateTime date) =>
      'Date must be after ${_formatDate(date)}';

  @override
  String dateBefore(DateTime date) =>
      'Date must be before ${_formatDate(date)}';

  /// Parse custom error codes into localized messages.
  ///
  /// This is useful for handling server-side validation errors or
  /// custom validators with unique error codes.
  @override
  String? parseErrorCode(String errorCode, dynamic value) {
    return switch (errorCode) {
      'password_mismatch' => 'Passwords do not match',
      'username_taken' => 'This username is already taken',
      'weak_password' => 'Password is too weak. Use a mix of letters, numbers, and symbols',
      'invalid_age' when value is int => 'You must be at least $value years old',
      _ => null,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
