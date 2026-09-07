import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

class const FieldConfig<T>([
  final List<Validator<T>> validators = const [],
  final T? initialValue,
]) {
  static FieldConfig<T> required<T>({
    String? message,
    String? errorCode,
  }) => FieldConfig<T>([
    RequiredValidator(message: message, errorCode: errorCode),
  ]);

  static FieldConfig<T> optional<T>({
    String? message,
    String? errorCode,
  }) => FieldConfig<T>([
    OptionalValidator(message: message, errorCode: errorCode),
  ]);

  FieldConfig<T> merge([Validator<T>? validator, T? initialValue]) {
    return FieldConfig<T>([...validators, ?validator], initialValue);
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

extension FieldConfigBase<T> on FieldConfig<T> {
  FieldConfig<T> optional({String? message, String? errorCode}) {
    return merge(OptionalValidator<T>(message: message, errorCode: errorCode));
  }

  FieldConfig<T> required() => merge(const RequiredValidator());

  FieldConfig<T> matcheField(
    Enum field, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MatchesValidator(field: field, message: message, errorCode: errorCode),
    );
  }

  FieldConfig<T> initWith(T value) {
    return merge(null, value);
  }
}

extension FieldConfigString on FieldConfig<String> {
  FieldConfig<String> email({String? message, String? errorCode}) {
    return merge(EmailValidator(message: message, errorCode: errorCode));
  }

  FieldConfig<String> phone({String? message, String? errorCode}) {
    return merge(PhoneValidator(message: message, errorCode: errorCode));
  }

  FieldConfig<String> pattern(
    RegExp pattern, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      PatternValidator(pattern, message: message, errorCode: errorCode),
    );
  }

  FieldConfig<String> minLength(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MinLengthValidator(length, message: message, errorCode: errorCode),
    );
  }

  FieldConfig<String> maxLength(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MaxLengthValidator(length, message: message, errorCode: errorCode),
    );
  }
}

extension FieldConfigNum on FieldConfig<num> {
  FieldConfig<num> min(num min, {String? message, String? errorCode}) {
    return merge(MinValidator(min, message: message, errorCode: errorCode));
  }

  FieldConfig<num> max(num max, {String? message, String? errorCode}) {
    return merge(MaxValidator(max, message: message, errorCode: errorCode));
  }

  FieldConfig<num> range(
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

extension FieldConfigXFile on FieldConfig<XFile> {
  FieldConfig<XFile> mimeType(
    Set<String> mimeType, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      MimeTypeValidator(mimeType, message: message, errorCode: errorCode),
    );
  }
}

extension FieldConfigDateTime on FieldConfig<DateTime> {
  FieldConfig<DateTime> isBefore(
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

  FieldConfig<DateTime> isAfter(
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

  FieldConfig<DateTime> dateAfterField(
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

extension FieldConfigList<T> on FieldConfig<List<T>> {
  FieldConfig<List<T>> minItems(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      ListMinItemsValidator<T>(length, message: message, errorCode: errorCode),
    );
  }

  FieldConfig<List<T>> maxItems(
    int length, {
    String? message,
    String? errorCode,
  }) {
    return merge(
      ListMaxItemsValidator<T>(length, message: message, errorCode: errorCode),
    );
  }
}
