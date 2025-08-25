import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

import 'validator.dart';

/// A schema that defines the form fields and their validators.
///
/// ```dart
/// class SignInFormSchema extends FormSchema {
///   const SignInFormSchema();
///
///   static const email = HookField<SignInFormSchema, String>(
///     'email',
///     validators: [
///       EmailValidator(),
///       RequiredValidator<String>(),
///     ],
///   );
///
///   static const password = HookField<SignInFormSchema, String>(
///     'password',
///     validators: [
///       RequiredValidator<String>(),
///     ],
///   );
///
///   @override
///   Set<HookField<FormSchema, dynamic>> get fields => {email, password};
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
  HookField({this.validators})
    : id = Object.hash(Random().nextInt(1000000), validators).toString();

  /// Creates a [HookField] instance with explicit id. Consider using
  /// [HookField.explicit] for debugging purposes.
  const HookField.explicit(this.id, {this.validators});

  /// The form field id.
  final String id;

  /// The validators.
  final List<Validator<T>>? validators;

  @override
  String toString() => id;
}

/// An extension type that represents an initialized form field.
extension type InitializedField<F extends FormSchema, T>(
  (HookField<F, T>, T?) pair
) {
  /// The field id.
  HookField<F, T> get fieldId => pair.$1;

  /// The initial value.
  T? get initialValue => pair.$2;
}

/// Extension methods for [HookField].
extension HookedFieldIdExtension<F extends FormSchema, T> on HookField<F, T> {
  /// Creates an [InitializedField] with the given initial value.
  InitializedField<F, T> withInitialValue([T? value]) =>
      InitializedField((this, value));
}
