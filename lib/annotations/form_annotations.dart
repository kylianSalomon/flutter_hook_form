/// Annotation to mark a class as a form schema.
class FormSchema {
  const FormSchema();
}

/// Annotation to mark a field as a form field.
class FormField {
  /// Creates a [FormField] annotation.
  const FormField({
    this.validators = const [],
  });

  /// The validators to apply to this field.
  final List<Validator> validators;
}

/// Base class for all validators.
abstract class Validator {
  const Validator();
}

/// Email validator.
class EmailValidator extends Validator {
  const EmailValidator();
}

/// Required field validator.
class RequiredValidator extends Validator {
  const RequiredValidator();
}

/// Minimum length validator.
class MinLengthValidator extends Validator {
  const MinLengthValidator(this.length);
  final int length;
}

/// Maximum length validator.
class MaxLengthValidator extends Validator {
  const MaxLengthValidator(this.length);
  final int length;
}

/// Custom validator.
class CustomValidator extends Validator {
  const CustomValidator(this.validator);
  final String? Function(dynamic value) validator;
}
