import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

class const ValidatorWrapper<T>([
  final List<Validator<T>> validators = const [],
]) {
  static ValidatorWrapper<T> required<T>({
    String? message,
    String? errorCode,
  }) => ValidatorWrapper<T>([
    RequiredValidator(message: message, errorCode: errorCode),
  ]);

  static ValidatorWrapper<T> optional<T>({
    String? message,
    String? errorCode,
  }) => ValidatorWrapper<T>([
    OptionalValidator(message: message, errorCode: errorCode),
  ]);

  ValidatorWrapper<T> merge(Validator<T> validator) {
    return ValidatorWrapper<T>([...validators, validator]);
  }

  String? validate(T value, BuildContext context) {
    return validators
        .map((v) {
          return switch (v) {
            FieldValidator(:final validator) => validator(value),
            CrossFieldValidator<dynamic, Enum>(:final validator) => validator(
              value,
              context,
            ),
          };
        })
        .whereType<String>()
        .firstOrNull;
  }
}

extension ValidatorWrapperBase<T> on ValidatorWrapper<T> {
  ValidatorWrapper<T> optional({String? message, String? errorCode}) {
    return merge(OptionalValidator<T>(message: message, errorCode: errorCode));
  }

  ValidatorWrapper<T> required() => merge(const RequiredValidator());

  ValidatorWrapper<T> matcheField(
    Enum field, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MatchesValidator(field: field, message: message, errorCode: errorCode),
    );
  }
}

extension ValidatorWrapperString on ValidatorWrapper<String> {
  ValidatorWrapper<String> email({String? message, String? errorCode}) {
    return merge(EmailValidator(message: message, errorCode: errorCode));
  }

  ValidatorWrapper<String> phone({String? message, String? errorCode}) {
    return merge(PhoneValidator(message: message, errorCode: errorCode));
  }

  ValidatorWrapper<String> pattern(
    RegExp pattern, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      PatternValidator(pattern, message: message, errorCode: errorCode),
    );
  }

  ValidatorWrapper<String> minLength(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MinLengthValidator(length, message: message, errorCode: errorCode),
    );
  }

  ValidatorWrapper<String> maxLength(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MaxLengthValidator(length, message: message, errorCode: errorCode),
    );
  }
}

extension ValidatorWrapperNum on ValidatorWrapper<num> {
  ValidatorWrapper<num> min(num min, {String? message, String? errorCode}) {
    return merge(MinValidator(min, message: message, errorCode: errorCode));
  }

  ValidatorWrapper<num> max(num max, {String? message, String? errorCode}) {
    return merge(MaxValidator(max, message: message, errorCode: errorCode));
  }

  ValidatorWrapper<num> range(
    num min,
    num max, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      RangeValidator(min, max, message: message, errorCode: errorCode),
    );
  }
}

extension ValidatorWrapperXFile on ValidatorWrapper<XFile> {
  ValidatorWrapper<XFile> mimeType(
    Set<String> mimeType, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MimeTypeValidator(mimeType, message: message, errorCode: errorCode),
    );
  }
}

extension ValidatorWrapperDateTime on ValidatorWrapper<DateTime> {
  ValidatorWrapper<DateTime> isBefore(
    DateTime date, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      IsBeforeValidator(
        date.toIso8601String(),
        message: message,
        errorCode: errorCode,
      ),
    );
  }

  ValidatorWrapper<DateTime> isAfter(
    DateTime date, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      IsAfterValidator(
        date.toIso8601String(),
        message: message,
        errorCode: errorCode,
      ),
    );
  }

  ValidatorWrapper<DateTime> dateAfterField(
    Enum field, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      DateAfterValidator(
        field: field,
        message: message,
        errorCode: errorCode,
      ),
    );
  }
}

extension ValidatorWrapperList<T> on ValidatorWrapper<List<T>> {
  ValidatorWrapper<List<T>> minItems(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      ListMinItemsValidator<T>(length, message: message, errorCode: errorCode),
    );
  }

  ValidatorWrapper<List<T>> maxItems(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      ListMaxItemsValidator<T>(length, message: message, errorCode: errorCode),
    );
  }
}
