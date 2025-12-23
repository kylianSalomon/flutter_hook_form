import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/validators/validators.dart';

import 'validator.dart';

/// This is a contract for a field schema. It is used to define the schema of a form field.
/// Implement this interface to define the schema of a form field.
///
/// ```dart
///  enum MyFieldSchema<T> implements FieldSchema {
///    email<String>(validators: [RequiredValidator(), EmailValidator()], initialValue: ''),
///    password<String>(validators: [RequiredValidator(), MinLengthValidator(8)], initialValue: '');
///
///    const MyFieldSchema({this.validators, this.initialValue});
///
///    /// Don't forget to override the initial value and validators.
///    @override
///    final T initialValue;
///
///    @override
///    final List<Validator<T>>? validators;
///  }
/// ```
abstract interface class FieldSchema implements Enum {
  /// The validators for the field.
  List<Validator<dynamic>>? get validators;
}

/// Extension methods for [FieldSchema].
extension FieldSchemaExtension on FieldSchema {
  /// Resolves the message error for the field. A shortcut for
  /// [MessageResolver.resolveMessage].
  FieldValidatorFn<T>? resolveMessage<T>(BuildContext context) {
    return validators?.resolveMessage<T>(context);
  }
}
