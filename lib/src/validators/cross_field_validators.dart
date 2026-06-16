import 'package:flutter_hook_form/flutter_hook_form.dart';

/// Compare the value with the value of the cross field and validate if the
/// value is after the cross field value.
class const DateAfterValidator({
  required super.field,
  super.message,
}) extends CrossFieldValidator<DateTime> {
  /// Creates a [IsAfterValidator].
  this : super(errorCode: 'date_after');

  @override
  CrossFieldValidatorFn<DateTime> get validator {
    return (value, context) {
      if (value == null) {
        return null;
      }

      assertValueIsOfType(context);

      final form = useFormContext(context);
      final fieldValue = form.getValue<DateTime>(
        field as FieldSchema<DateTime>,
      );

      if (fieldValue != null && value.isBefore(fieldValue)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Compare the value with the value of the cross field and validate if the
/// value matches the cross field value.
class const MatchesValidator<T>({
  required super.field,
  super.message,
}) extends CrossFieldValidator<T> {
  /// Creates a [MatchesValidator].
  this : super(errorCode: 'field_does_not_match');

  @override
  CrossFieldValidatorFn<T> get validator {
    return (value, context) {
      assertValueIsOfType(context);

      final form = useFormContext(context);
      final fieldValue = form.getValue<T>(field as FieldSchema<T>);

      if (fieldValue != value) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}
