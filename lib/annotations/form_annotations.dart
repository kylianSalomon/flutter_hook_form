import '../models/validator.dart';

/// Annotation to mark a class as a form schema.
class HookFormSchema {
  const HookFormSchema();
}

class ValidatorAnnotation<T> {
  const ValidatorAnnotation();
}

/// Annotation to mark a field as a form field.
class HookFormField<T> {
  /// Creates a [FormField] annotation.
  const HookFormField({
    this.validators,
  });

  /// The validators to apply to this field.
  final List<Validator<T>>? validators;
}
