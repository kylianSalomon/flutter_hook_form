import 'package:flutter/widgets.dart' show BuildContext;

/// A type alias for a validator function.
typedef ValidatorFn<T> = String? Function(T? value, BuildContext context);

/// Base class for all validators.
abstract class Validator<T> {
  const Validator([this.message]);

  final String? message;

  ValidatorFn<T> get validator;
}
