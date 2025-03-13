/// A type alias for a validator function.
typedef ValidatorFn<T> = String? Function(T? value);

/// Base class for all validators.
abstract class Validator<T> {
  /// Creates a [Validator].
  const Validator({
    required this.errorCode,
    this.message,
  });

  /// The error message to display if the validation fails.
  final String? message;

  /// The error code to display if the validation fails.
  final String errorCode;

  /// The validator function.
  ValidatorFn<T> get validator;
}
