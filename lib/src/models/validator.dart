import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

/// A type alias for a validator function.
typedef FieldValidatorFn<T> = String? Function(T? value);

/// A type alias for a cross field validator function.
typedef CrossFieldValidatorFn<T> = String? Function(
  T? value,
  BuildContext context,
);

/// Base class for all validators.
sealed class const Validator<T>({
  /// The error code to display if the validation fails.
  required final String errorCode,

  /// The error message to display if the validation fails.
  final String? message,
});

/// A validator that validates a single field.
abstract class const FieldValidator<T>({
  required super.errorCode,
  super.message,
  // required this.validator,
}) extends Validator<T> {
  /// The validator function.
  FieldValidatorFn<T> get validator;
}

/// A validator that validates a cross field.
abstract class const CrossFieldValidator<T>({
  required super.errorCode,

  /// The field to compare with.
  required final FieldSchema<dynamic> field,
  super.message,
}) extends Validator<T> {
  /// Asserts that the value is of the correct type.
  void assertValueIsOfType(BuildContext context) {
    final form = useFormContext(context);
    final value = form.getValue<dynamic>(field);

    assert(
      value is T?,
      'Cross field validator must be of type $T, but got ${value?.runtimeType},',
    );
  }

  /// The validator function.
  CrossFieldValidatorFn<T> get validator;
}
