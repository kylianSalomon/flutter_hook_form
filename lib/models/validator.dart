/// A type alias for a validator function.
typedef ValidatorFn<T> = String? Function(T? value);

/// Base class for all validators.
abstract class Validator<T> {
  const Validator({
    required this.errorCode,
    this.message,
  });

  final String? message;
  final String errorCode;

  ValidatorFn<T> get validator;
}
