import 'package:collection/collection.dart';

import 'validator.dart';

/// A schema that defines the form fields and their validators.
///
/// ```dart
/// class SignInFormSchema extends FormSchema {
///   SignInFormSchema()
///       : super(
///           fields: {
///             FormFieldScheme<String>(
///               email,
///               validators: (_, __) {}.email().required(),
///             ),
///             FormFieldScheme<String>(
///               password,
///               validators: (String ? value, __) {
///                 // You can specify custom validation function like that.
///                 if(value == 'password'){
///                   return '"password" not allowed.'
///                 }
///               }.required(),
///             ),
///           },
///         );
///
///   static const HookedFieldId<String> email = HookedFieldId('email');
///   static const HookedFieldId<String> password = HookedFieldId('password');
/// }
/// ```
abstract class FormSchema {
  /// Creates a [FormSchema] instance.
  const FormSchema({
    required this.fields,
  });

  /// The form fields.
  final Set<FormFieldScheme> fields;

  /// Get a form field by its id.
  FormFieldScheme<T>? field<T>(HookedFieldId<T> id) {
    return fields.firstWhereOrNull((e) => e.id == id) as FormFieldScheme<T>?;
  }
}

/// A class that defines a form field.
class FormFieldScheme<T> {
  /// Creates a [FormFieldScheme] instance.
  const FormFieldScheme(
    this.id, {
    this.validators,
  });

  /// The form field id.
  final HookedFieldId<T> id;

  /// The validators.
  final List<Validator<T>>? validators;
}

/// A class that defines a form field id. This allows for type safety
/// when accessing form fields and integrates with the hooked form ecosystem.
class HookedFieldId<T> {
  /// Creates a [HookedFieldId] instance.
  const HookedFieldId(String id) : _id = id;

  /// The id to be used in the form controller. There is no need to use this
  /// class directly, it is used internally by the hooked form ecosystem.
  final String _id;

  @override
  String toString() => _id;
}
