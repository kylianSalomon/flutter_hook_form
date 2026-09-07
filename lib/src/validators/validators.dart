// ignore_for_file: public_member_api_docs

import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/messages/form_messages.dart';
import 'package:flutter_hook_form/src/models/validator.dart';
import 'package:flutter_hook_form/src/validators/cross_field_validators.dart';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final _phonePattern = RegExp(r'^\+?[0-9]{9,14}$');

/// Required field validator.
class RequiredValidator<T> extends FieldValidator<T> {
  const new({super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'required');

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

/// Optional field validator.
class OptionalValidator<T> extends FieldValidator<T> {
  const new({super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'invalid_field_type');

  @override
  FieldValidatorFn<T> get validator {
    return (value) {
      if (value is! T) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Email validator.
class EmailValidator extends FieldValidator<String> {
  const new({super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'invalid_email');

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
class MinLengthValidator extends FieldValidator<String> {
  const new(this.length, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'min_length');

  final int length;

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
class PatternValidator extends FieldValidator<String> {
  const new(this.pattern, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'invalid_pattern');

  final RegExp pattern;

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
class MaxLengthValidator extends FieldValidator<String> {
  const new(this.length, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'max_length');

  final int length;

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
class PhoneValidator extends FieldValidator<String> {
  const new({super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'invalid_phone');

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

/// Minimum validator.
class MinValidator extends FieldValidator<num> {
  const new(this.min, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'num_infer_to_min');

  final num min;

  @override
  FieldValidatorFn<num> get validator {
    return (value) {
      if (value != null && value < min) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Maximum validator.
class MaxValidator extends FieldValidator<num> {
  const new(this.max, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'num_superior_to_max');

  final num max;

  @override
  FieldValidatorFn<num> get validator {
    return (value) {
      if (value != null && value > max) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

class RangeValidator extends FieldValidator<num> {
  const new(this.min, this.max, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'num_out_of_range');

  final num min;
  final num max;

  @override
  FieldValidatorFn<num> get validator {
    return (value) {
      if (value != null && (value < min || value > max)) {
        return message ?? errorCode;
      }
      return null;
    };
  }
}

/// Mime type validator.
class MimeTypeValidator extends FieldValidator<XFile> {
  const new(this.mimeType, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'invalid_file_format');

  final Set<String> mimeType;

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
class IsAfterValidator extends FieldValidator<DateTime> {
  const new(this.min, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'date_after');

  final String min;

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
class IsBeforeValidator extends FieldValidator<DateTime> {
  const new(this.max, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'date_before');

  final String max;

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
class ListMinItemsValidator<T> extends FieldValidator<List<T>> {
  const new(this.length, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'min_items');

  final int length;

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
class ListMaxItemsValidator<T> extends FieldValidator<List<T>> {
  const new(this.length, {super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'max_items');

  final int length;

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
      FieldValidator(:final validator) => validator(value),
      CrossFieldValidator<dynamic, Enum>(:final validator) => validator(
        value,
        context,
      ),
    };

    if (error == null) {
      return null;
    }

    // If the error is not the same as the error code, return the error.
    // That means that the error has been overridden.
    if (error != validator.errorCode) {
      return error;
    }

    final formScope = HookFormScope.of(context);

    return switch (validator) {
      RequiredValidator() => formScope.required,
      EmailValidator() => formScope.invalidEmail,
      PatternValidator() => formScope.invalidPattern,
      MinLengthValidator(length: final length) => formScope.minLength(length),
      MaxLengthValidator(length: final length) => formScope.maxLength(length),
      PhoneValidator() => formScope.invalidPhone,
      MimeTypeValidator(mimeType: final mimeType) =>
        formScope.invalidFileFormat(mimeType),
      IsAfterValidator(min: final min) => formScope.dateAfter(
        DateTime.parse(min),
      ),
      IsBeforeValidator(max: final max) => formScope.dateBefore(
        DateTime.parse(max),
      ),
      ListMinItemsValidator(length: final length) => formScope.minItems(length),
      ListMaxItemsValidator(length: final length) => formScope.maxItems(length),
      MatchesValidator() => formScope.fieldDoesNotMatch,
      DateAfterValidator() => formScope.fieldIsNotAfter,
      _ => formScope.parseErrorCode(validator.errorCode, value) ?? error,
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
