import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';

import 'messages/form_messages.dart';
import 'models/types.dart';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final _phonePattern = RegExp(r'^\+?[0-9]{9,14}$');

extension CommonValidators<T> on ValidatorFn<T> {
  ValidatorFn2<T> localize(BuildContext context) =>
      (T? value) => this.call(value, context);

  ValidatorFn<T> required([String? message]) =>
      (T? value, BuildContext context) {
        if (value == null) {
          return message ?? HookFormScope.of(context).required;
        }

        return this.call(value, context);
      };
}

extension StringValidators on ValidatorFn<String> {
  ValidatorFn<String> min(int length, [String? message]) =>
      (String? value, BuildContext context) {
        if (value != null && value.length < length) {
          return message ?? HookFormScope.of(context).minLength(length);
        }

        return this.call(value, context);
      };

  ValidatorFn<String> max(int length, [String? message]) =>
      (String? value, BuildContext context) {
        if (value != null && value.length > length) {
          return message ?? HookFormScope.of(context).maxLength(length);
        }

        return this.call(value, context);
      };

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

extension FileValidators on ValidatorFn<XFile> {
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

extension DateTimeValidators on ValidatorFn<DateTime> {
  ValidatorFn<DateTime> isAfter(DateTime min, [String? message]) {
    return (DateTime? value, BuildContext context) {
      if (value != null && value.isBefore(min)) {
        return message ?? HookFormScope.of(context).dateAfter(min);
      }

      return this.call(value, context);
    };
  }

  ValidatorFn<DateTime> isBefore(DateTime max, [String? message]) {
    return (DateTime? value, BuildContext context) {
      if (value != null && value.isAfter(max)) {
        return message ?? HookFormScope.of(context).dateBefore(max);
      }

      return this.call(value, context);
    };
  }
}

extension ListValidators on ValidatorFn<List> {
  ValidatorFn<List<T>> minItems<T>(int length, [String? message]) {
    return (List<T>? value, BuildContext context) {
      if (value != null && value.length < length) {
        return message ?? HookFormScope.of(context).minItems(length);
      }

      return this.call(value, context);
    };
  }

  ValidatorFn<List<T>> maxItems<T>(int length, [String? message]) {
    return (List<T>? value, BuildContext context) {
      if (value != null && value.length > length) {
        return message ?? HookFormScope.of(context).maxItems(length);
      }

      return this.call(value, context);
    };
  }
}
