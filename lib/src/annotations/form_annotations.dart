import '../models/validator.dart';

/// Annotation to mark a class as a form schema.
class HookFormSchema {
  /// Creates a [HookFormSchema] annotation.
  const HookFormSchema();
}

/// Annotation to mark a field as a validator.
class ValidatorAnnotation<T> {
  /// Creates a [ValidatorAnnotation] annotation.
  const ValidatorAnnotation();
}

/// Annotation to mark a field as a form field.
class HookFormField<T> {
  /// Creates a [HookFormField] annotation.
  const HookFormField({
    this.validators,
  });

  /// The validators to apply to this field.
  final List<Validator<T>>? validators;
}
