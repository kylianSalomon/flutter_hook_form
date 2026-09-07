/// Sign-in form field schema.
///
/// Define your form fields as an enum that implements [FieldSchema].
/// Each field can have validators and an initial value.
enum SignInFields { email, password, rememberMe }

const maxBirthDate = '2023-01-01';

/// Registration form field schema with more field types.
enum RegistrationFields {
  username,
  email,
  phone,
  password,
  confirmPassword,
  birthDate,
  firstJobDate,
  country,
  agreeToTerms,
}

/// Profile form field schema demonstrating nested widgets and context usage.
enum ProfileFields {
  firstName,
  lastName,
  bio,
  website,
  notificationsEnabled,
  theme,
}
