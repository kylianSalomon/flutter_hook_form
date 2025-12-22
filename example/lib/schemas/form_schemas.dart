import 'package:flutter_hook_form/flutter_hook_form.dart';

/// Sign-in form field schema.
///
/// Define your form fields as an enum that implements [FieldSchema].
/// Each field can have validators and an initial value.
enum SignInFields<T> implements FieldSchema {
  email<String>(validators: [RequiredValidator<String>()]),
  password<String>(
    validators: [RequiredValidator<String>(), MinLengthValidator(8)],
  ),
  rememberMe<bool>(initialValue: false);

  const SignInFields({this.validators, this.initialValue});

  @override
  final T? initialValue;

  @override
  final List<Validator<T>>? validators;
}

/// Registration form field schema with more field types.
enum RegistrationFields<T> implements FieldSchema {
  username<String>(
    validators: [
      RequiredValidator(),
      MinLengthValidator(3),
      MaxLengthValidator(20),
    ],
  ),
  email<String>(validators: [RequiredValidator(), EmailValidator()]),
  phone<String>(validators: [PhoneValidator()]),
  password<String>(validators: [RequiredValidator(), MinLengthValidator(8)]),
  confirmPassword<String>(validators: [RequiredValidator()]),
  birthDate<DateTime>(),
  country<String>(validators: [RequiredValidator()]),
  agreeToTerms<bool>(validators: [RequiredValidator()], initialValue: false);

  const RegistrationFields({this.validators, this.initialValue});

  @override
  final T? initialValue;

  @override
  final List<Validator<T>>? validators;
}

/// Profile form field schema demonstrating nested widgets and context usage.
enum ProfileFields<T> implements FieldSchema {
  firstName<String>(validators: [RequiredValidator()]),
  lastName<String>(validators: [RequiredValidator()]),
  bio<String>(validators: [MaxLengthValidator(500)]),
  website<String>(),
  notificationsEnabled<bool>(initialValue: true),
  theme<String>(initialValue: 'system');

  const ProfileFields({this.validators, this.initialValue});

  @override
  final T? initialValue;

  @override
  final List<Validator<T>>? validators;
}
