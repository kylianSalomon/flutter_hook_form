import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/messages/form_messages.dart';
import 'package:flutter_hook_form/src/models/validator.dart';
import 'package:flutter_hook_form/src/validators/cross_field_validators.dart';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final _phonePattern = RegExp(r'^\+?[0-9]{9,14}$');

/// Required field validator.
class const RequiredValidator<T>({super.message}) extends FieldValidator<T> {
  /// Creates a [RequiredValidator].
  this : super(errorCode: 'required');

  @override
  FieldValidatorFn<T> get validator {
    return (value) {
      final isEmpty = switch (value) {
        final String s => s.isEmpty,
        final Iterable l => l.isEmpty,
        final Map m => m.isEmpty,
        _ => false,
      };

      if (value == null || isEmpty) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Email validator.
class const EmailValidator({super.message}) extends FieldValidator<String> {
  /// Creates a [EmailValidator].
  this : super(errorCode: 'invalid_email');

  @override
  FieldValidatorFn<String> get validator {
    return (value) {
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
class const MinLengthValidator(
  /// The minimum length.
  final int length, {
  super.message,
}) extends FieldValidator<String> {
  /// Creates a [MinLengthValidator].
  this : super(errorCode: 'min_length');

  @override
  FieldValidatorFn<String> get validator {
    return (value) {
      if (value != null && value.length < length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Pattern validator.
class const PatternValidator(
  /// The pattern to validate against.
  final RegExp pattern, {
  super.message,
}) extends FieldValidator<String> {
  /// Creates a [PatternValidator].
  this : super(errorCode: 'invalid_pattern');

  @override
  FieldValidatorFn<String> get validator {
    return (value) {
      if (value != null && value.isNotEmpty && !pattern.hasMatch(value)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Maximum length validator.
class const MaxLengthValidator(
  /// The maximum length.
  final int length, {
  super.message,
}) extends FieldValidator<String> {
  /// Creates a [MaxLengthValidator].
  this : super(errorCode: 'max_length');

  @override
  FieldValidatorFn<String> get validator {
    return (value) {
      if (value != null && value.length > length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Phone validator.
class const PhoneValidator({super.message}) extends FieldValidator<String> {
  /// Creates a [PhoneValidator].
  this : super(errorCode: 'invalid_phone');

  @override
  FieldValidatorFn<String> get validator {
    return (value) {
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
class const MimeTypeValidator(
  /// The mime types to validate against.
  final Set<String> mimeType, {
  super.message,
}) extends FieldValidator<XFile> {
  /// Creates a [MimeTypeValidator].
  this : super(errorCode: 'invalid_file_format');

  @override
  FieldValidatorFn<XFile> get validator {
    return (value) {
      if (value != null && !mimeType.contains(value.mimeType)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Date after validator.
class const IsAfterValidator(
  /// The minimum date.
  final String min, {
  super.message,
}) extends FieldValidator<DateTime> {
  /// Creates a [IsAfterValidator].
  this : super(errorCode: 'date_after');

  @override
  FieldValidatorFn<DateTime> get validator {
    return (value) {
      if (value != null && value.isBefore(DateTime.parse(min))) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Date before validator.
class const IsBeforeValidator(
  /// The maximum date.
  final String max, {
  super.message,
}) extends FieldValidator<DateTime> {
  /// Creates a [IsBeforeValidator].
  this : super(errorCode: 'date_before');

  @override
  FieldValidatorFn<DateTime> get validator {
    return (value) {
      if (value != null && value.isAfter(DateTime.parse(max))) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Minimum items validator.
class const ListMinItemsValidator<T>(
  /// The minimum length.
  final int length, {
  super.message,
}) extends FieldValidator<List<T>> {
  /// Creates a [ListMinItemsValidator].
  this : super(errorCode: 'min_items');

  @override
  FieldValidatorFn<List<T>> get validator {
    return (value) {
      if (value != null && value.length < length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Maximum items validator.
class const ListMaxItemsValidator<T>(
  /// The maximum length.
  final int length, {
  super.message,
}) extends FieldValidator<List<T>> {
  /// Creates a [ListMaxItemsValidator].
  this : super(errorCode: 'max_items');

  @override
  FieldValidatorFn<List<T>> get validator {
    return (value) {
      if (value != null && value.length > length) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Validator list extension.
extension MessageResolver on List<Validator<dynamic>>? {
  /// Resolves the message error for the validators (can be null if no errors
  /// or validators). If [FormErrorMessages] has been overriden via the
  /// [HookFormScope] widget, the custom messages will be used.
  FieldValidatorFn<T>? resolveMessage<T>(BuildContext context) {
    return this?.reversed.fold<FieldValidatorFn<T>>((value) => null, (
      previous,
      validator,
    ) {
      if (validator is! Validator<T>) {
        throw ErrorDescription(
          '''Cannot resolve message for type $T. Please provide the type of the 
          validators when calling the resolveMessage method.''',
        );
      }

      return (value) {
        return _getScopedError<T?>(context, validator, value) ??
            previous.call(value);
      };
    });
  }

  String? _getScopedError<T>(
    BuildContext context,
    Validator<T> validator,
    T value,
  ) {
    final error = switch (validator) {
      FieldValidator<T>(:final validator) => validator(value),
      CrossFieldValidator<T>(:final validator) => validator(value, context),
    };

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
      MinLengthValidator(length: final length) => HookFormScope.of(
        context,
      ).minLength(length),
      MaxLengthValidator(length: final length) => HookFormScope.of(
        context,
      ).maxLength(length),
      PhoneValidator() => HookFormScope.of(context).invalidPhone,
      MimeTypeValidator(mimeType: final mimeType) => HookFormScope.of(
        context,
      ).invalidFileFormat(mimeType),
      IsAfterValidator(min: final min) => HookFormScope.of(
        context,
      ).dateAfter(DateTime.parse(min)),
      IsBeforeValidator(max: final max) => HookFormScope.of(
        context,
      ).dateBefore(DateTime.parse(max)),
      ListMinItemsValidator(length: final length) => HookFormScope.of(
        context,
      ).minItems(length),
      ListMaxItemsValidator(length: final length) => HookFormScope.of(
        context,
      ).maxItems(length),
      MatchesValidator() => HookFormScope.of(context).fieldDoesNotMatch,
      DateAfterValidator() => HookFormScope.of(context).fieldIsNotAfter,
      _ =>
        HookFormScope.of(context).parseErrorCode(validator.errorCode, value) ??
            error,
    };
  }
}

/// Localize error extension.
extension LocalizeError on String? {
  /// Localizes the error. Useful to translate the forced error messages.
  String? localize(BuildContext context, dynamic value) {
    return switch (this) {
      final String errorCode =>
        HookFormScope.of(context).parseErrorCode(errorCode, value) ?? errorCode,
      _ => null,
    };
  }
}
