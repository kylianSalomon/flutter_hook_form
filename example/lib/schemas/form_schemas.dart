import 'package:flutter_hook_form/flutter_hook_form.dart';

/// Sign-in form field schema.
///
/// Define your form fields as an enum that implements [FieldSchema].
/// Each field can have validators and an initial value.
enum SignInFields {
  //<String>(validators: [RequiredValidator<String>()]),
  email,
  // <String>(
  //   validators: [RequiredValidator<String>(), MinLengthValidator(8)],
  // ),
  password,
  //<bool>(validators: [RequiredValidator()]);
  rememberMe,
}

const maxBirthDate = '2023-01-01';

/// Registration form field schema with more field types.
enum RegistrationFields {
  // <String>(
  //   validators: [
  //     RequiredValidator(),
  //     MinLengthValidator(3),
  //     MaxLengthValidator(20),
  //   ],
  // ),
  username,
  // <String>(validators: [RequiredValidator(), EmailValidator()]),
  email,
  // <String>(validators: [PhoneValidator()]),
  phone,
  // <String>(validators: [RequiredValidator(), MinLengthValidator(8)]),
  password,
  // <String>(
  //   validators: [
  //     RequiredValidator(),
  //     MatchesValidator(field: password),
  //   ],
  // ),
  confirmPassword,
  // <DateTime>(validators: [IsBeforeValidator(maxBirthDate)]),
  birthDate,
  // <DateTime>(validators: [DateAfterValidator(field: birthDate)]),
  firstJobDate,
  // <String>(validators: [RequiredValidator()]),
  country,
  //<bool>(validators: [RequiredValidator()]);
  agreeToTerms,
}

/// Profile form field schema demonstrating nested widgets and context usage.
enum ProfileFields {
  // <String>(validators: [RequiredValidator()]),
  firstName,
  // <String>(validators: [RequiredValidator()]),
  lastName,
  // <String>(validators: [MaxLengthValidator(500)]),
  bio,
  // <String>(),
  website,
  // <bool>(validators: [RequiredValidator()]),
  notificationsEnabled,
  // <String>(validators: [RequiredValidator()]);
  theme,
}
