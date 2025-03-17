import 'package:flutter/widgets.dart';

/// A class that contains the default form error messages.
///
/// You can override the default messages by providing a custom
/// [FormErrorMessages] instance to the [HookFormScope] widget.
class FormErrorMessages {
  /// Creates a [FormErrorMessages] instance.
  const FormErrorMessages();

  // Common messages

  /// The default required message.
  String get required => 'Required';

  /// The default invalid email message.
  String get invalidEmail => 'Invalid email address';

  /// The default invalid phone message.
  String get invalidPhone => 'Invalid phone number';

  /// The default invalid pattern message.
  String get invalidPattern => 'Invalid pattern';

  // String validation messages

  /// The default minimum length message.
  String minLength(int length) => 'Must be at least $length characters';

  /// The default maximum length message.
  String maxLength(int length) => 'Must be at most $length characters';

  // File validation messages

  /// The default invalid file format message.
  String invalidFileFormat(Set<String> allowedTypes) =>
      'Invalid file format. Allowed types: ${allowedTypes.join(", ")}';

  // Date validation messages

  /// The default date before message.
  String dateBefore(DateTime date) => 'Must be before $date';

  /// The default date after message.
  String dateAfter(DateTime date) => 'Must be after $date';

  // List validation messages

  /// The default minimum items message.
  String minItems(int count) => 'Must have at least $count items';

  /// The default maximum items message.
  String maxItems(int count) => 'Must have at most $count items';

  /// The default parse error code message.
  String? parseErrorCode(String errorCode, dynamic value) => null;
}

/// Add this widget on top of your widget tree to override the default
/// form messages. Useful to translate the form error messages.
class HookFormScope extends InheritedWidget {
  /// Creates a [HookFormScope] instance.
  const HookFormScope({
    super.key,
    required super.child,
    required this.messages,
  });

  /// The form error messages.
  final FormErrorMessages messages;

  /// Returns the [FormErrorMessages] instance from the nearest [HookFormScope].
  static FormErrorMessages of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<HookFormScope>()
            ?.messages ??
        const FormErrorMessages();
  }

  @override
  bool updateShouldNotify(HookFormScope oldWidget) =>
      messages != oldWidget.messages;
}
