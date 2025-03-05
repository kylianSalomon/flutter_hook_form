import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';

import 'messages/form_messages.dart';
import 'models/types.dart';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final _phonePattern = RegExp(r'^\+?[0-9]{9,14}$');

/// An extension on the [ValidatorFn] type.
extension CommonValidators<T> on ValidatorFn<T> {
  /// Localize the validator function.
  ValidatorFn2<T> localize(BuildContext context) =>
      (T? value) => this.call(value, context);

  /// A required validator.
  ValidatorFn<T> required([String? message]) =>
      (T? value, BuildContext context) {
        if (value == null) {
          return message ?? HookFormScope.of(context).required;
        }

        return this.call(value, context);
      };
}

/// An extension on the [ValidatorFn] type for string validators.
extension StringValidators on ValidatorFn<String> {
  /// A minimum length validator.
  ValidatorFn<String> min(int length, [String? message]) =>
      (String? value, BuildContext context) {
        if (value != null && value.length < length) {
          return message ?? HookFormScope.of(context).minLength(length);
        }

        return this.call(value, context);
      };

  /// A maximum length validator.
  ValidatorFn<String> max(int length, [String? message]) =>
      (String? value, BuildContext context) {
        if (value != null && value.length > length) {
          return message ?? HookFormScope.of(context).maxLength(length);
        }

        return this.call(value, context);
      };

  /// A email validator.
  ValidatorFn<String> email([String? message]) {
    return (String? value, BuildContext context) {
      if (value == null || value.isEmpty) {
        return this.call(value, context);
      }

      if (!_emailPattern.hasMatch(value)) {
        return message ?? HookFormScope.of(context).invalidEmail;
      }

      return this.call(value, context);
    };
  }

  /// A phone validator.
  ValidatorFn<String> phone([String? message]) {
    return (String? value, BuildContext context) {
      if (value == null || value.isEmpty) {
        return this.call(value, context);
      }

      if (!_phonePattern.hasMatch(value)) {
        return message ?? HookFormScope.of(context).invalidPhone;
      }

      return this.call(value, context);
    };
  }
}

/// An extension on the [ValidatorFn] type for file validators.
extension FileValidators on ValidatorFn<XFile> {
  /// A file format validator.
  ValidatorFn<XFile> format(Set<String> mimeType, [String? message]) =>
      (XFile? value, BuildContext context) {
        final fileType = lookupMimeType(value?.path ?? '');

        if (value != null && !mimeType.contains(fileType)) {
          return message ??
              HookFormScope.of(context).invalidFileFormat(mimeType);
        }

        return this.call(value, context);
      };
}

/// An extension on the [ValidatorFn] type for date validators.
extension DateTimeValidators on ValidatorFn<DateTime> {
  /// A date after validator.
  ValidatorFn<DateTime> isAfter(DateTime min, [String? message]) {
    return (DateTime? value, BuildContext context) {
      if (value != null && value.isBefore(min)) {
        return message ?? HookFormScope.of(context).dateAfter(min);
      }

      return this.call(value, context);
    };
  }

  /// A date before validator.
  ValidatorFn<DateTime> isBefore(DateTime max, [String? message]) {
    return (DateTime? value, BuildContext context) {
      if (value != null && value.isAfter(max)) {
        return message ?? HookFormScope.of(context).dateBefore(max);
      }

      return this.call(value, context);
    };
  }
}

/// An extension on the [ValidatorFn] type for list validators.
extension ListValidators on ValidatorFn<List> {
  /// A minimum items validator.
  ValidatorFn<List<T>> minItems<T>(int length, [String? message]) {
    return (List<T>? value, BuildContext context) {
      if (value != null && value.length < length) {
        return message ?? HookFormScope.of(context).minItems(length);
      }

      return this.call(value, context);
    };
  }

  /// A maximum items validator.
  ValidatorFn<List<T>> maxItems<T>(int length, [String? message]) {
    return (List<T>? value, BuildContext context) {
      if (value != null && value.length > length) {
        return message ?? HookFormScope.of(context).maxItems(length);
      }

      return this.call(value, context);
    };
  }
}
