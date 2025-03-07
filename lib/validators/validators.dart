import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';

import '../messages/form_messages.dart';
import '../models/validator.dart';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final _phonePattern = RegExp(r'^\+?[0-9]{9,14}$');

/// Required field validator.
class RequiredValidator<T> extends Validator<T> {
  const RequiredValidator([super.message]);

  @override
  ValidatorFn<T> get validator {
    return (T? value, BuildContext context) {
      if (value == null) {
        return message ?? HookFormScope.of(context).required;
      }

      return null;
    };
  }
}

/// Email validator.
class EmailValidator extends Validator<String> {
  const EmailValidator([super.message]);

  @override
  ValidatorFn<String> get validator {
    return (String? value, BuildContext context) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (!_emailPattern.hasMatch(value)) {
        return message ?? HookFormScope.of(context).invalidEmail;
      }

      return null;
    };
  }
}

/// Minimum length validator.
class MinLengthValidator extends Validator<String> {
  const MinLengthValidator(this.length, [super.message]);
  final int length;

  @override
  ValidatorFn<String> get validator {
    return (String? value, BuildContext context) {
      if (value != null && value.length < length) {
        return message ?? HookFormScope.of(context).minLength(length);
      }

      return null;
    };
  }
}

/// Maximum length validator.
class MaxLengthValidator extends Validator<String> {
  const MaxLengthValidator(this.length, [super.message]);

  final int length;

  @override
  ValidatorFn<String> get validator {
    return (String? value, BuildContext context) {
      if (value != null && value.length > length) {
        return message ?? HookFormScope.of(context).maxLength(length);
      }

      return null;
    };
  }
}

class PhoneValidator extends Validator<String> {
  const PhoneValidator([super.message]);

  @override
  ValidatorFn<String> get validator {
    return (String? value, BuildContext context) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (!_phonePattern.hasMatch(value)) {
        return message ?? HookFormScope.of(context).invalidPhone;
      }

      return null;
    };
  }
}

class FileValidator {
  const FileValidator._();

  static Validator<XFile> mimeType(Set<String> mimeType, [String? message]) {
    return _MimeTypeValidator(mimeType, message);
  }
}

class _MimeTypeValidator extends Validator<XFile> {
  const _MimeTypeValidator(this.mimeType, [super.message]);

  final Set<String> mimeType;

  @override
  ValidatorFn<XFile> get validator {
    return (XFile? value, BuildContext context) {
      final fileType = lookupMimeType(value?.path ?? '');

      if (value != null && !mimeType.contains(fileType)) {
        return message ?? HookFormScope.of(context).invalidFileFormat(mimeType);
      }

      return null;
    };
  }
}

class DateTimeValidator {
  const DateTimeValidator._();

  static Validator<DateTime> isAfter(DateTime min, [String? message]) {
    return _IsAfterValidator(min, message);
  }

  static Validator<DateTime> isBefore(DateTime max, [String? message]) {
    return _IsBeforeValidator(max, message);
  }
}

class _IsAfterValidator extends Validator<DateTime> {
  const _IsAfterValidator(
    this.min, [
    super.message,
  ]);
  final DateTime min;

  @override
  ValidatorFn<DateTime> get validator {
    return (DateTime? value, BuildContext context) {
      if (value != null && value.isBefore(min)) {
        return message ?? HookFormScope.of(context).dateAfter(min);
      }

      return null;
    };
  }
}

class _IsBeforeValidator extends Validator<DateTime> {
  const _IsBeforeValidator(
    this.max, [
    super.message,
  ]);

  final DateTime max;

  @override
  ValidatorFn<DateTime> get validator {
    return (DateTime? value, BuildContext context) {
      if (value != null && value.isAfter(max)) {
        return message ?? HookFormScope.of(context).dateBefore(max);
      }

      return null;
    };
  }
}

class ListValidator {
  const ListValidator._();

  static Validator<List<T>> minItems<T>(int length, [String? message]) {
    return _MinItemsValidator(length, message);
  }

  static Validator<List<T>> maxItems<T>(int length, [String? message]) {
    return _MaxItemsValidator(length, message);
  }
}

class _MinItemsValidator<T> extends Validator<List<T>> {
  const _MinItemsValidator(
    this.length, [
    super.message,
  ]);
  final int length;

  @override
  ValidatorFn<List<T>> get validator {
    return (List<T>? value, BuildContext context) {
      if (value != null && value.length < length) {
        return message ?? HookFormScope.of(context).minItems(length);
      }

      return null;
    };
  }
}

class _MaxItemsValidator<T> extends Validator<List<T>> {
  const _MaxItemsValidator(this.length, [super.message]);
  final int length;

  @override
  ValidatorFn<List<T>> get validator {
    return (List<T>? value, BuildContext context) {
      if (value != null && value.length > length) {
        return message ?? HookFormScope.of(context).maxItems(length);
      }

      return null;
    };
  }
}
