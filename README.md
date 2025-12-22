# flutter_hook_form

A type-safe form controller for Flutter applications using hooks. Inspired by _react_hook_form_.

## What's New in 4.0.0

Version 4.0.0 introduces a significantly simplified API for defining form schemas. The `FieldSchema<T>` interface now only requires two properties (`validators` and `initialValue`), removing the need for boilerplate field name declarations. This makes your enum-based schemas cleaner and more concise while maintaining full type safety.

## Motivation

Managing forms in Flutter often requires creating multiple `TextEditingController` instances, managing their lifecycle, and scattering validation logic across widgets. This package was created to:

- **Centralize validation logic**: Define all your form fields and their validators in a single enum schema
- **Easy access to field values**: Get and update field values directly from the form controller without setting up a dedicated state manager or dependency injection

## Table of Contents

- [Getting Started](#getting-started)
- [How to use](#how-to-use)
  - [Install](#install)
  - [Create your Schema](#create-your-schema)
    - [Available Validators](#available-validators)
    - [Create validators](#create-validators)
  - [Use "hooked" widgets](#use-hooked-widgets)
    - [Use form controller](#use-form-controller)
    - [HookedTextFormField](#hookedtextformfield)
    - [HookedFormField](#hookedformfield)
    - [Form initialization](#form-initialization)
    - [Form State Management](#form-state-management)
    - [Form Field State](#form-field-state)
- [Customizations](#customizations)
  - [Custom Validation Messages & Internationalization](#custom-validation-messages--internationalization)
  - [Form Injection and Context Access](#form-injection-and-context-access)
  - [Alternative Injection Methods](#alternative-injection-methods)
  - [Write your own Form field](#write-your-own-form-field)
- [Use Cases](#use-cases)
  - [Form Value Handling and Payload Conversion](#form-value-handling-and-payload-conversion)
  - [Asynchronous Form Validation](#asynchronous-form-validation)
  - [Form Controller Enhancements](#form-controller-enhancements)
- [Additional Information](#additional-information)

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_hook_form: ^4.0.0
```

## How to use

### Install

To use `flutter_hook_form`, you need to add it to your dependencies in `pubspec.yaml`:

```yaml
dependencies:
  flutter_hook_form: ^4.0.0

  # Required for the useForm hook
  flutter_hooks: ^0.20.0
```

### Create your Schema

Define your form schema as an enum implementing `FieldSchema<T>`. Each enum value represents a form field with its validators and optional initial value.

```dart
import 'package:flutter_hook_form/flutter_hook_form.dart';

enum SignInFormFields<T> implements FieldSchema<T> {
  email<String>(validators: [RequiredValidator(), EmailValidator()]),
  password<String>(validators: [RequiredValidator(), MinLengthValidator(8)]),
  rememberMe<bool>(initialValue: false);

  const SignInFormFields({this.validators, this.initialValue});

  @override
  final T? initialValue;

  @override
  final List<Validator<T>>? validators;
}
```

#### Available Validators

The package comes with several built-in validators:

| Category | Validator | Description | Example |
|----------|-----------|-------------|---------|
| **Generic** | `RequiredValidator<T>` | Ensures field is not empty | `RequiredValidator<String>()` |
| **String** | `EmailValidator` | Validates email format | `EmailValidator()` |
| | `MinLengthValidator` | Checks minimum length | `MinLengthValidator(8)` |
| | `MaxLengthValidator` | Checks maximum length | `MaxLengthValidator(32)` |
| | `PhoneValidator` | Validates phone number format | `PhoneValidator()` |
| | `PatternValidator` | Validate the value with the given pattern | `PatternValidator(RegExp(r'^[A-zÀ-ú \-]+$'))` |
| **Date** | `IsAfterValidator` | Validates minimum date | `IsAfterValidator(DateTime.now())` |
| | `IsBeforeValidator` | Validates maximum date | `IsBeforeValidator(DateTime.now())` |
| **List** | `ListMinItemsValidator` | Checks minimum items | `ListMinItemsValidator<T>(2)` |
| | `ListMaxItemsValidator` | Checks maximum items | `ListMaxItemsValidator<T>(5)` |
| **File** | `MimeTypeValidator` | Validates file type | `MimeTypeValidator({'image/jpeg', 'image/png'})` |

When using multiple validators, they are executed in the order they are defined in the list.

#### Create validators

You can create custom validators by extending the `Validator` class. Return the `errorCode` on error to support internationalization (see [Custom Validation Messages & Internationalization](#custom-validation-messages--internationalization)).

```dart
class UsernameValidator extends Validator<String> {
  const UsernameValidator() : super(errorCode: 'username_error');

  @override
  ValidatorFn<String> get validator => (String? value) {
    if (value?.contains('@') == true) {
      return errorCode;
    }
    return null;
  };
}

// Use in your form schema
enum ProfileFormFields<T> implements FieldSchema<T> {
  username<String>(validators: [RequiredValidator(), UsernameValidator()]);

  // ...
}
```

Custom validators can also include additional parameters:

```dart
class MinAgeValidator extends Validator<DateTime> {
  const MinAgeValidator({required this.minAge}) : super(errorCode: 'min_age_error');

  final int minAge;

  @override
  ValidatorFn<DateTime> get validator => (DateTime? value) {
    if (value == null) return null;

    final age = DateTime.now().year - value.year;
    if (age < minAge) {
      return errorCode;
    }
    return null;
  };
}
```

### Use "Hooked" widgets

`flutter_hook_form` includes convenient Form widgets to streamline your development process. These widgets are optional and simply wrap Flutter's standard form widgets.

#### Use form controller

The `useForm` hook requires `flutter_hooks` and can only be used within a `HookWidget` or `HookConsumerWidget`.

```dart
// Correct usage
class MyForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm<MyFormFields>();
    // ...
  }
}

// Also correct with Riverpod
class MyForm extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useForm<MyFormFields>();
    // ...
  }
}
```

If you need to use the form controller in a regular widget, you can either:

1. Use the `FormFieldsController` directly
2. Access it through `useFormContext` (see [Form Injection and Context Access](#form-injection-and-context-access))
3. Use any other dependency injection method (see [Alternative Injection Methods](#alternative-injection-methods))

#### HookedTextFormField

`HookedTextFormField` is a wrapper around Flutter's `TextFormField` that integrates with the form controller:

```dart
HookedTextFormField<SignInFormFields<String>>(
  fieldHook: .email,
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
```

#### HookedFormField

`HookedFormField` is a generic form field that can be used with any type of input:

```dart
HookedFormField<SignInFormFields<bool>, bool>(
  fieldHook: .rememberMe,
  builder: (value, onChanged, error) {
    return Checkbox(
      value: value ?? false,
      onChanged: onChanged,
    );
  },
)
```

Here's a complete example of a form using these widgets:

```dart
class SignInPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm<SignInFormFields>();

    return Scaffold(
      body: HookedForm(
        form: form,
        child: Column(
          children: [
            HookedTextFormField<SignInFormFields<String>>(
              fieldHook: .email,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),

            HookedTextFormField<SignInFormFields<String>>(
              fieldHook: .password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
            ),

            HookedFormField<SignInFormFields<bool>, bool>(
              fieldHook: .rememberMe,
              builder: (value, onChanged, error) {
                return Checkbox(
                  value: value ?? false,
                  onChanged: onChanged,
                );
              },
            ),

            ElevatedButton(
              onPressed: () {
                if (form.validate()) {
                  final email = form.getValue(.email);
                  final password = form.getValue(.password);
                  print('Email: $email, Password: $password');
                }
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Form initialization

When you want to initialize your form with values, pass them to `useForm`:

```dart
final form = useForm<SignInFormFields>(
  initialValues: {
    SignInFormFields.email: 'user@example.com',
    SignInFormFields.password: '',
  },
);
```

#### Form State Management

The form controller provides several methods to manage form state:

```dart
// Update a field value
form.updateValue(.email, 'new@email.com');

// Get a field value
final email = form.getValue(.email);

// Get all form values
final values = form.getValues();

// Reset the form
form.reset();

// Validate the form
final isValid = form.validate();
```

#### Form Field State

You can also access the state of individual form fields:

```dart
// Check if fields have been modified
final isDirty = form.isDirty({.email, .password});

// Check if a specific field is valid
final isEmailValid = form.validateField(.email);

// Get field error message
final error = form.getFieldError(.email);
```

## Customizations

### Custom Validation Messages & Internationalization

Override the `FormErrorMessages` class and provide it via `HookFormScope` to translate error messages.

```dart
class CustomFormMessages extends FormErrorMessages {
  const CustomFormMessages(this.context);

  final BuildContext context;

  @override
  String get required => 'This field is required.';

  @override
  String get invalidEmail => AppLocalizations.of(context).invalidEmail;

  String minAgeError(int age) => 'You must be $age to use this.';

  @override
  String? parseErrorCode(String errorCode, dynamic value) {
    return switch (errorCode) {
      'min_age_error' when value is int => minAgeError(value),
      _ => null,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => HookFormScope(
        messages: CustomFormMessages(context),
        child: child ?? const SignInPage(),
      ),
    );
  }
}
```

### Form Injection and Context Access

Use `HookedForm` to inject the form controller into the widget tree and retrieve it with `useFormContext` in child widgets.

```dart
class ParentWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm<SignInFormFields>();

    return HookedForm(
      form: form,
      child: Column(
        children: [
          const ChildWidget(),
        ],
      ),
    );
  }
}

class ChildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final form = useFormContext<SignInFormFields>(context);

    return // ... child widget
  }
}
```

#### Navigating with the form instance

When navigating, a new widget tree is generated and you may lose access to the form instance. Use `HookedFormProvider` to provide the form to the new widget tree:

```dart
showBottomSheet(
  context: context,
  builder: (context) {
    return HookedFormProvider(
      form: form,
      child: const MySubForm(),
    );
  },
);
```

### Alternative Injection Methods

While `HookedForm` is the recommended way to inject form controllers, you can also use any other dependency injection method.

#### Using Riverpod

```dart
final signInFormProvider = Provider<FormFieldsController<SignInFormFields>>((ref) {
  return FormFieldsController(
    GlobalKey<FormState>(),
  );
});

class SignInForm extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signInFormProvider);

    return HookedForm(
      form: form,
      child: // ... form fields
    );
  }
}
```

#### Using GetIt

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<FormFieldsController<SignInFormFields>>(
    () => FormFieldsController(GlobalKey<FormState>()),
  );
}

class SignInForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = getIt<FormFieldsController<SignInFormFields>>();

    return HookedForm(
      form: form,
      child: // ... form fields
    );
  }
}
```

### Write your own Form field

"Hooked" widgets simply wrap Flutter's standard `FormField` and `TextFormField`. You can write your own form fields to fit your specific needs.

To create your own custom form field, you need to:

1. Connect to the form controller (either via `useFormContext` or by passing it directly)
2. Use `form.fieldKey(field)` to connect the field to the form
3. Handle validation and error display
4. Register value changes with `form.updateValue`

Here's an example of a custom checkbox form field:

```dart
class CustomCheckboxField extends StatelessWidget {
  const CustomCheckboxField({
    super.key,
    required this.field,
    required this.label,
  });

  final FieldSchema<bool> field;
  final String label;

  @override
  Widget build(BuildContext context) {
    final form = useFormContext(context);

    return FormField<bool>(
      key: form.fieldKey(field),
      initialValue: form.getInitialValue(field) ?? false,
      builder: (fieldState) {
        return Row(
          children: [
            Checkbox(
              value: fieldState.value ?? false,
              onChanged: (value) {
                fieldState.didChange(value);
                form.updateValue(field, value);
              },
            ),
            Text(label),
            if (fieldState.hasError)
              Text(
                fieldState.errorText!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        );
      },
    );
  }
}
```

## Use Cases

### Form Value Handling and Payload Conversion

Define static methods in your form schema for validation and payload conversion:

```dart
enum SignInFormFields<T> implements FieldSchema<T> {
  email<String>(validators: [RequiredValidator(), EmailValidator()]),
  password<String>(validators: [RequiredValidator(), MinLengthValidator(8)]);

  const SignInFormFields({this.validators, this.initialValue});

  @override
  final T? initialValue;

  @override
  final List<Validator<T>>? validators;

  // Static method to validate and convert form values to API payload
  static SignInPayload? toPayload(FormFieldsController<SignInFormFields> form) {
    if (!form.validate()) {
      return null;
    }

    return SignInPayload(
      email: form.getValue(.email)!,
      password: form.getValue(.password)!,
    );
  }
}

// Usage
ElevatedButton(
  onPressed: () {
    final payload = SignInFormFields.toPayload(form);
    if (payload != null) {
      // Send payload to API
    }
  },
  child: const Text('Sign In'),
)
```

### Asynchronous Form Validation

Use the `setError` method for asynchronous validation:

```dart
class RegistrationForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm<RegistrationFormFields>();
    final isLoading = useState(false);

    Future<void> validateUsernameAsync(String username) async {
      if (username.isEmpty) return;

      isLoading.value = true;
      try {
        final exists = await userRepository.checkUsernameExists(username);

        if (exists) {
          form.setError(RegistrationFormFields.username, 'Username is already taken');
        }
      } finally {
        isLoading.value = false;
      }
    }

    return HookedForm(
      form: form,
      child: Column(
        children: [
          HookedTextFormField<RegistrationFormFields>(
            fieldHook: .username,
            decoration: InputDecoration(
              labelText: 'Username',
              suffixIcon: isLoading.value
                ? const CircularProgressIndicator(strokeWidth: 2)
                : null,
            ),
            onChanged: (value) => validateUsernameAsync(value),
          ),
          ElevatedButton(
            onPressed: () async {
              if (form.validate()) {
                final username = form.getValue(.username);
                await validateUsernameAsync(username!);

                if (!form.hasFieldError(.username)) {
                  submitForm(form);
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
```

### Form Controller Enhancements

#### Error Handling and Validation

```dart
// Set a field error with optional notification control
controller.setError(field, "Error message", notify: false);

// Clear all forced errors
controller.clearForcedErrors(notify: true);
```

#### Automatic Form Validation

Control validation behavior to prevent rebuild errors:

```dart
controller.validate(
  notify: false,     // Prevent listener notifications
  clearErrors: false // Keep existing forced errors
);
```

#### Form State Tracking

```dart
// Check if any field has been interacted with
if (controller.hasBeenInteracted) {
  // Show confirmation dialog before navigating away
}

// Check if any field value has changed from its initial value
if (controller.hasChanged) {
  // Enable the "Save Changes" button
}
```

## Additional Information

### Dependencies

- flutter_hooks: ^0.21.3

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/kylianSalomon/flutter_hook_form/issues).
