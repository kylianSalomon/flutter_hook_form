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
  const FormSchema({
    required this.fields,
  });

  final Set<FormFieldScheme> fields;

  FormFieldScheme<T>? field<T>(TypedId<T> id) {
    return fields.firstWhereOrNull((e) => e.id == id) as FormFieldScheme<T>?;
  }
}

class FormFieldScheme<T> {
  const FormFieldScheme(
    this.id, {
    this.validators,
  });

  final TypedId<T> id;
  final ValidatorFn<T>? validators;
}

class TypedId<T> {
  const TypedId(this.id);

  final String id;
}
