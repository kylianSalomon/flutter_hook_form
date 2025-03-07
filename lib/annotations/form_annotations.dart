/// Annotation to mark a class as a form schema.
class HookFormSchema {
  const HookFormSchema();
}

/// Annotation to mark a field as a form field.
class HookFormField<T> {
  /// Creates a [FormField] annotation.
  const HookFormField({
    this.validators = const [],
  });

  /// The validators to apply to this field.
  final List<Validator<T>> validators;
}

/// Base class for all validators.
abstract class Validator<T> {
  const Validator();
}

/// Email validator.
class EmailValidator extends Validator<String> {
  const EmailValidator();
}

/// Required field validator.
class RequiredValidator extends Validator<String> {
  const RequiredValidator();
}

/// Minimum length validator.
class MinLengthValidator extends Validator<String> {
  const MinLengthValidator(this.length);
  final int length;
}

/// Maximum length validator.
class MaxLengthValidator extends Validator<String> {
  const MaxLengthValidator(this.length);
  final int length;
}

/// Custom validator.
class CustomValidator<T> extends Validator<T> {
  const CustomValidator(this.validator);
  final String? Function(dynamic value) validator;
}
