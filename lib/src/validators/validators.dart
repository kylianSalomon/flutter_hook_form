import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';

import '../messages/form_messages.dart';
import '../models/validator.dart';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final _phonePattern = RegExp(r'^\+?[0-9]{9,14}$');

/// Required field validator.
class RequiredValidator<T> extends Validator<T> {
  /// Creates a [RequiredValidator].
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
  /// Creates a [EmailValidator].
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
  /// Creates a [MinLengthValidator].
  const MinLengthValidator(this.length, {super.message})
      : super(errorCode: 'min_length');

  /// The minimum length.
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

/// Pattern validator.
class PatternValidator extends Validator<String> {
  /// Creates a [PatternValidator].
  const PatternValidator(this.pattern, {super.message})
      : super(errorCode: 'invalid_pattern');

  /// The pattern to validate against.
  final RegExp pattern;

  @override
  ValidatorFn<String> get validator {
    return (String? value) {
      if (value != null && !pattern.hasMatch(value)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Maximum length validator.
class MaxLengthValidator extends Validator<String> {
  /// Creates a [MaxLengthValidator].
  const MaxLengthValidator(this.length, {super.message})
      : super(errorCode: 'max_length');

  /// The maximum length.
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

/// Phone validator.
class PhoneValidator extends Validator<String> {
  /// Creates a [PhoneValidator].
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

/// Mime type validator.
class MimeTypeValidator extends Validator<XFile> {
  /// Creates a [MimeTypeValidator].
  const MimeTypeValidator(this.mimeType, {super.message})
      : super(errorCode: 'invalid_file_format');

  /// The mime type to validate against.
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

/// Date after validator.
class IsAfterValidator extends Validator<DateTime> {
  /// Creates a [IsAfterValidator].
  const IsAfterValidator(
    this.min, {
    super.message,
  }) : super(errorCode: 'date_after');

  /// The minimum date.
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

/// Date before validator.
class IsBeforeValidator extends Validator<DateTime> {
  /// Creates a [IsBeforeValidator].
  const IsBeforeValidator(
    this.max, {
    super.message,
  }) : super(errorCode: 'date_before');

  /// The maximum date.
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

/// Minimum items validator.
class ListMinItemsValidator<T> extends Validator<List<T>> {
  /// Creates a [ListMinItemsValidator].
  const ListMinItemsValidator(
    this.length, {
    super.message,
  }) : super(errorCode: 'min_items');

  /// The minimum length.
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

/// Maximum items validator.
class ListMaxItemsValidator<T> extends Validator<List<T>> {
  /// Creates a [ListMaxItemsValidator].
  const ListMaxItemsValidator(
    this.length, {
    super.message,
  }) : super(errorCode: 'max_items');

  /// The maximum length.
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

/// Validator list extension.
extension ValidatorListExtension<T> on List<Validator<T>>? {
  /// Localizes the error messages.
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
      PatternValidator() => HookFormScope.of(context).invalidPattern,
      MinLengthValidator(length: final length) =>
        HookFormScope.of(context).minLength(length),
      MaxLengthValidator(length: final length) =>
        HookFormScope.of(context).maxLength(length),
      PhoneValidator() => HookFormScope.of(context).invalidPhone,
      MimeTypeValidator(mimeType: final mimeType) =>
        HookFormScope.of(context).invalidFileFormat(mimeType),
      IsAfterValidator(min: final min) =>
        HookFormScope.of(context).dateAfter(min),
      IsBeforeValidator(max: final max) =>
        HookFormScope.of(context).dateBefore(max),
      ListMinItemsValidator(length: final length) =>
        HookFormScope.of(context).minItems(length),
      ListMaxItemsValidator(length: final length) =>
        HookFormScope.of(context).maxItems(length),
      _ =>
        HookFormScope.of(context).parseErrorCode(validator.errorCode, value) ??
            error,
    };
  }
}
