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
///   static const HookedFieldId<SignInFormSchema, String> email = HookedFieldId('email');
///   static const HookedFieldId<SignInFormSchema, String> password = HookedFieldId('password');
/// }
/// ```
abstract class FormSchema {
  /// Creates a [FormSchema] instance.
  const FormSchema();

  /// The form fields.
  Set<HookField> get fields;

  /// Get a form field by its id.
  HookField<F, T>? field<F extends FormSchema, T>(HookField<F, T> hookField) {
    return fields.firstWhereOrNull((e) => e.id == hookField.id)
        as HookField<F, T>?;
  }
}

/// A class that defines a form field.
class HookField<F extends FormSchema, T> {
  /// Creates a [HookField] instance.
  const HookField(
    this.id, {
    this.validators,
  });

  /// The form field id.
  final String id;

  /// The validators.
  final List<Validator<T>>? validators;

  @override
  String toString() => id;
}

/// An extension type that represents an initialized form field.
extension type InitializedField<F extends FormSchema, T>(
    (HookField<F, T>, T?) pair) {
  /// The field id.
  HookField<F, T> get fieldId => pair.$1;

  /// The initial value.
  T? get initialValue => pair.$2;
}

/// Extension methods for [HookedFieldId].
extension HookedFieldIdExtension<F extends FormSchema, T> on HookField<F, T> {
  /// Creates an [InitializedField] with the given initial value.
  InitializedField<F, T> withInitialValue([T? value]) =>
      InitializedField((this, value));
}
