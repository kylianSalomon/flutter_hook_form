import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';

import '../messages/form_messages.dart';
import '../models/validator.dart';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final _phonePattern = RegExp(r'^\+?[0-9]{9,14}$');

/// Required field validator.
class RequiredValidator<T> extends Validator<T> {
  const RequiredValidator({
    super.message,
  }) : super(errorCode: 'required');

  @override
  ValidatorFn<T> get validator {
    return (T? value) {
      if (value == null) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Email validator.
class EmailValidator extends Validator<String> {
  const EmailValidator({
    super.message,
  }) : super(errorCode: 'invalid_email');

  @override
  ValidatorFn<String> get validator {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (!_emailPattern.hasMatch(value)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Minimum length validator.
class MinLengthValidator extends Validator<String> {
  const MinLengthValidator(this.length, {super.message})
      : super(errorCode: 'min_length');
  final int length;

  @override
  ValidatorFn<String> get validator {
    return (String? value) {
      if (value != null && value.length < length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Maximum length validator.
class MaxLengthValidator extends Validator<String> {
  const MaxLengthValidator(this.length, {super.message})
      : super(errorCode: 'max_length');

  final int length;

  @override
  ValidatorFn<String> get validator {
    return (String? value) {
      if (value != null && value.length > length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

class PhoneValidator extends Validator<String> {
  const PhoneValidator({
    super.message,
  }) : super(errorCode: 'invalid_phone');

  @override
  ValidatorFn<String> get validator {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (!_phonePattern.hasMatch(value)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

class FileValidator {
  const FileValidator._();

  static Validator<XFile> mimeType(Set<String> mimeType, [String? message]) {
    return _MimeTypeValidator(mimeType, message: message);
  }
}

class _MimeTypeValidator extends Validator<XFile> {
  const _MimeTypeValidator(this.mimeType, {super.message})
      : super(errorCode: 'invalid_file_format');

  final Set<String> mimeType;

  @override
  ValidatorFn<XFile> get validator {
    return (XFile? value) {
      final fileType = lookupMimeType(value?.path ?? '');

      if (value != null && !mimeType.contains(fileType)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

class DateTimeValidator {
  const DateTimeValidator._();

  static Validator<DateTime> isAfter(DateTime min, [String? message]) {
    return _IsAfterValidator(min, message: message);
  }

  static Validator<DateTime> isBefore(DateTime max, [String? message]) {
    return _IsBeforeValidator(max, message: message);
  }
}

class _IsAfterValidator extends Validator<DateTime> {
  const _IsAfterValidator(
    this.min, {
    super.message,
  }) : super(errorCode: 'date_after');
  final DateTime min;

  @override
  ValidatorFn<DateTime> get validator {
    return (DateTime? value) {
      if (value != null && value.isBefore(min)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

class _IsBeforeValidator extends Validator<DateTime> {
  const _IsBeforeValidator(
    this.max, {
    super.message,
  }) : super(errorCode: 'date_before');

  final DateTime max;

  @override
  ValidatorFn<DateTime> get validator {
    return (DateTime? value) {
      if (value != null && value.isAfter(max)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

class ListValidator {
  const ListValidator._();

  static Validator<List<T>> minItems<T>(int length, [String? message]) {
    return _MinItemsValidator(length, message: message);
  }

  static Validator<List<T>> maxItems<T>(int length, [String? message]) {
    return _MaxItemsValidator(length, message: message);
  }
}

class _MinItemsValidator<T> extends Validator<List<T>> {
  const _MinItemsValidator(
    this.length, {
    super.message,
  }) : super(errorCode: 'min_items');
  final int length;

  @override
  ValidatorFn<List<T>> get validator {
    return (List<T>? value) {
      if (value != null && value.length < length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

class _MaxItemsValidator<T> extends Validator<List<T>> {
  const _MaxItemsValidator(
    this.length, {
    super.message,
  }) : super(errorCode: 'max_items');
  final int length;

  @override
  ValidatorFn<List<T>> get validator {
    return (List<T>? value) {
      if (value != null && value.length > length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

extension ValidatorListExtension<T> on List<Validator<T>>? {
  ValidatorFn<T>? localize(BuildContext context) {
    return this?.fold<ValidatorFn<T>>(
      (value) => null,
      (previous, validator) {
        return (value) {
          return _localizeError(context, validator, value) ??
              previous.call(value);
        };
      },
    );
  }

  String? _localizeError(
    BuildContext context,
    Validator<T> validator,
    T? value,
  ) {
    final error = validator.validator(value);

    if (error == null) {
      return null;
    }

    // If the error is not the same as the error code, return the error.
    // That means that the error has been overridden.
    if (error != validator.errorCode) {
      return error;
    }

    return switch (validator) {
      RequiredValidator() => HookFormScope.of(context).required,
      EmailValidator() => HookFormScope.of(context).invalidEmail,
      MinLengthValidator(length: final length) =>
        HookFormScope.of(context).minLength(length),
      MaxLengthValidator(length: final length) =>
        HookFormScope.of(context).maxLength(length),
      PhoneValidator() => HookFormScope.of(context).invalidPhone,
      _MimeTypeValidator(mimeType: final mimeType) =>
        HookFormScope.of(context).invalidFileFormat(mimeType),
      _IsAfterValidator(min: final min) =>
        HookFormScope.of(context).dateAfter(min),
      _IsBeforeValidator(max: final max) =>
        HookFormScope.of(context).dateBefore(max),
      _MinItemsValidator(length: final length) =>
        HookFormScope.of(context).minItems(length),
      _MaxItemsValidator(length: final length) =>
        HookFormScope.of(context).maxItems(length),
      _ =>
        HookFormScope.of(context).parseErrorCode(validator.errorCode) ?? error,
    };
  }
}
