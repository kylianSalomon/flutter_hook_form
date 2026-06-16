import 'package:flutter_hook_form/src/models/field_schema.dart';
import 'package:flutter_hook_form/src/models/validator.dart';
import 'package:flutter_hook_form/src/validators/validators.dart';

enum TestFormSchema<T>({
  this.validators,
  final T? initialValue,
}) implements FieldSchema<T> {
  email<String>(validators: [RequiredValidator(), EmailValidator()]),
  password<String>(validators: [RequiredValidator()]);

  @override
  final List<Validator<T>>? validators;
}
