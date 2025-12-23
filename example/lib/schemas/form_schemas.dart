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
  rememberMe<bool>(validators: [RequiredValidator()]);

  const SignInFields({this.validators});

  @override
  final List<Validator<T>>? validators;
}

const maxBirthDate = '2023-01-01';

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
  confirmPassword<String>(
    validators: [
      RequiredValidator(),
      MatchesValidator(field: password),
    ],
  ),
  birthDate<DateTime>(validators: [IsBeforeValidator(maxBirthDate)]),
  firstJobDate<DateTime>(validators: [DateAfterValidator(field: birthDate)]),
  country<String>(validators: [RequiredValidator()]),
  agreeToTerms<bool>(validators: [RequiredValidator()]);

  const RegistrationFields({this.validators});


  @override
  final List<Validator<T>>? validators;
}

/// Profile form field schema demonstrating nested widgets and context usage.
enum ProfileFields<T> implements FieldSchema {
  firstName<String>(validators: [RequiredValidator()]),
  lastName<String>(validators: [RequiredValidator()]),
  bio<String>(validators: [MaxLengthValidator(500)]),
  website<String>(),
  notificationsEnabled<bool>(validators: [RequiredValidator()]),
  theme<String>(validators: [RequiredValidator()]);

  const ProfileFields({this.validators});

  @override
  final List<Validator<T>>? validators;
}
