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

  /// The initial value for the field.
  dynamic get initialValue;
}
