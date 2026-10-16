// ignore_for_file: public_member_api_docs

import 'package:flutter_hook_form/flutter_hook_form.dart';

/// Compare the value with the value of the cross field and validate if the
/// value is after the cross field value.
class DateAfterValidator<E extends Enum>
    extends CrossFieldValidator<DateTime, E> {
  const new({
    required super.field,
    super.message,
    String? errorCode,
  }) : super(errorCode: errorCode ?? 'date_after');
  @override
  CrossFieldValidatorFn<DateTime> get validator {
    return (value, context) {
      if (value == null) {
        return null;
      }

      assertValueIsOfType(context);

      final form = useFormContext<E>(context);
      final fieldValue = form.getValue<DateTime>(field);

      if (fieldValue != null && value.isBefore(fieldValue)) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}

/// Compare the value with the value of the cross field and validate if the
/// value matches the cross field value.
class MatchesValidator<T, E extends Enum> extends CrossFieldValidator<T, E> {
  const new({required super.field, super.message, String? errorCode})
    : super(errorCode: errorCode ?? 'field_does_not_match');

  @override
  CrossFieldValidatorFn<T> get validator {
    return (value, context) {
      assertValueIsOfType(context);

      final form = useFormContext<E>(context);
      final fieldValue = form.getValue<T>(field);

      if (fieldValue != value) {
        return message ?? errorCode;
      }

      return null;
    };
  }
}
