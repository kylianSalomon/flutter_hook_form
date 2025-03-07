import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';

import '../models/types.dart';
import '../models/validator.dart';
import 'validators.dart';

/// An extension on the [ValidatorFn] type.
extension CommonValidators<T> on ValidatorFn<T> {
  ValidatorFn<T> _applyValidator(ValidatorFn<T> validator) {
    return (T? value, BuildContext context) {
      final error = validator(value, context);

      if (error != null) {
        return error;
      }

      return this.call(value, context);
    };
  }

  /// Localize the validator function.
  ValidatorFn2<T> localize(BuildContext context) =>
      (T? value) => this.call(value, context);

  /// A required validator.
  ValidatorFn<T> required([String? message]) {
    return _applyValidator(RequiredValidator<T>(message).validator);
  }
}

/// An extension on the [ValidatorFn] type for string validators.
extension StringValidators on ValidatorFn<String> {
  /// A minimum length validator.
  ValidatorFn<String> min(int length, [String? message]) {
    return _applyValidator(MinLengthValidator(length, message).validator);
  }

  /// A maximum length validator.
  ValidatorFn<String> max(int length, [String? message]) {
    return _applyValidator(MaxLengthValidator(length, message).validator);
  }

  /// A email validator.
  ValidatorFn<String> email([String? message]) {
    return _applyValidator(EmailValidator(message).validator);
  }

  /// A phone validator.
  ValidatorFn<String> phone([String? message]) {
    return _applyValidator(PhoneValidator(message).validator);
  }
}

/// An extension on the [ValidatorFn] type for file validators.
extension FileValidators on ValidatorFn<XFile> {
  /// A file format validator.
  ValidatorFn<XFile> mimeType(Set<String> mimeType, [String? message]) {
    return _applyValidator(FileValidator.mimeType(mimeType, message).validator);
  }
}

/// An extension on the [ValidatorFn] type for date validators.
extension DateTimeValidators on ValidatorFn<DateTime> {
  /// A date after validator.
  ValidatorFn<DateTime> isAfter(DateTime min, [String? message]) {
    return _applyValidator(DateTimeValidator.isAfter(min, message).validator);
  }

  /// A date before validator.
  ValidatorFn<DateTime> isBefore(DateTime max, [String? message]) {
    return _applyValidator(DateTimeValidator.isBefore(max, message).validator);
  }
}

/// An extension on the [ValidatorFn] type for list validators.
extension ListValidators<T> on ValidatorFn<List<T>> {
  /// A minimum items validator.
  ValidatorFn<List<T>> minItems(int length, [String? message]) {
    return _applyValidator(ListValidator.minItems(length, message).validator);
  }

  /// A maximum items validator.
  ValidatorFn<List<T>> maxItems(int length, [String? message]) {
    return _applyValidator(ListValidator.maxItems(length, message).validator);
  }
}
