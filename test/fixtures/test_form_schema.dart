
import 'package:flutter_hook_form/src/models/field_schema.dart';
import 'package:flutter_hook_form/src/models/validator.dart';
import 'package:flutter_hook_form/src/validators/validators.dart';

enum TestFormSchema<T> implements FieldSchema<T> {
  email<String>(validators: [RequiredValidator<String>(), EmailValidator()]),
  password<String>(validators: [RequiredValidator<String>()]);

  const TestFormSchema({this.validators, this.initialValue});

  @override
  final T? initialValue;

  @override
  final List<Validator<T>>? validators;
}
