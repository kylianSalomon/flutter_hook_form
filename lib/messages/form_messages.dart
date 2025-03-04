import 'package:flutter/widgets.dart';

class FormErrorMessages {
  const FormErrorMessages();

  // Common messages
  String get required => 'Required';
  String get invalidEmail => 'Invalid email address';
  String get invalidPhone => 'Invalid phone number';

  // String validation messages
  String minLength(int length) => 'Must be at least $length characters';
  String maxLength(int length) => 'Must be at most $length characters';

  // File validation messages
  String invalidFileFormat(Set<String> allowedTypes) =>
      'Invalid file format. Allowed types: ${allowedTypes.join(", ")}';

  // Date validation messages
  String dateBefore(DateTime date) => 'Must be before $date';
  String dateAfter(DateTime date) => 'Must be after $date';

  // List validation messages
  String minItems(int count) => 'Must have at least $count items';
  String maxItems(int count) => 'Must have at most $count items';
}

/// Add this widget on top of your widget tree to override the default
/// form messages. Useful to translate the form error messages.
class HookFormScope extends InheritedWidget {
  const HookFormScope({
    super.key,
    required super.child,
    this.messages = const FormErrorMessages(),
  });

  final FormErrorMessages messages;

  static FormErrorMessages? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HookFormScope>()
        ?.messages;
  }

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
