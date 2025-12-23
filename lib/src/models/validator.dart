import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

/// A type alias for a validator function.
typedef FieldValidatorFn<T> = String? Function(T? value);

/// A type alias for a cross field validator function.
typedef CrossFieldValidatorFn<T> =
    String? Function(T? value, BuildContext context);

/// Base class for all validators.
sealed class Validator<T> {
  /// Creates a [Validator].
  const Validator({required this.errorCode, this.message});

  /// The error message to display if the validation fails.
  final String? message;

  /// The error code to display if the validation fails.
  final String errorCode;
}

/// A validator that validates a single field.
abstract class FieldValidator<T> extends Validator<T> {
  /// Creates a [Validator].
  const FieldValidator({
    required super.errorCode,
    super.message,
    // required this.validator,
  });

  /// The validator function.
  FieldValidatorFn<T> get validator;
}

/// A validator that validates a cross field.
abstract class CrossFieldValidator<T> extends Validator<T> {
  /// Creates a [CrossFieldValidator].
  const CrossFieldValidator({
    required super.errorCode,
    required this.field,
    super.message,
  });

  /// The field to compare with.
  final FieldSchema field;

  /// Asserts that the value is of the correct type.
  void assertValueIsOfType(BuildContext context) {
    final form = useFormContext<FieldSchema>(context);
    final value = form.getValue(field);

    assert(
      value is T?,
      'Cross field validator must be of type $T, but got ${value?.runtimeType},',
    );
  }

  /// The validator function.
  CrossFieldValidatorFn<T> get validator;
}
