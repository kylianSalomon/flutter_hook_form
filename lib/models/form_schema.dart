import 'package:collection/collection.dart';

import 'types.dart';

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
///   static const TypedId<String> email = TypedId('email');
///   static const TypedId<String> password = TypedId('password');
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
  FormFieldScheme<T>? field<T>(TypedId<T> id) {
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
  final TypedId<T> id;

  /// The validators.
  final ValidatorFn<T>? validators;
}

/// A class that defines a form field id. This allow to have type safety
/// when accessing the form field.
class TypedId<T> {
  /// Creates a [TypedId] instance.
  const TypedId(this.id);

  /// The id.
  final String id;
}
