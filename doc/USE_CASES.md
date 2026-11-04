# Use Cases

Recipes for things that come up once a form grows past the basics covered in the main [README](../README.md).

- [Form Value Handling and Payload Conversion](#form-value-handling-and-payload-conversion)
- [Server-side Errors (422)](#server-side-errors-422)
- [Multi-step Forms (Wizard)](#multi-step-forms-wizard)
- [Asynchronous Form Validation](#asynchronous-form-validation)
- [Form Controller Enhancements](#form-controller-enhancements)

## Form Value Handling and Payload Conversion

Keep payload conversion next to the schema it belongs to with a static helper:

```dart
enum SignInFields { email, password }

class SignInPayloadMapper {
  const SignInPayloadMapper._();

  static SignInPayload? toPayload(FormFieldsController<SignInFields> form) {
    if (!form.validate()) {
      return null;
    }

    return SignInPayload(
      email: form.getValue<String>(SignInFields.email)!,
      password: form.getValue<String>(SignInFields.password)!,
    );
  }
}

// Usage
ElevatedButton(
  onPressed: () {
    final payload = SignInPayloadMapper.toPayload(form);
    if (payload != null) {
      // Send payload to API
    }
  },
  child: const Text('Sign In'),
)
```

## Server-side Errors (422)

The form does not run backend validation itself: submit, then show what the server returned. Each forced error disappears as soon as the user edits its field, and `validate()` fails while one is still there.

```dart
enum RegistrationFields { username, email, password }

class RegistrationForm extends HookWidget {
  const RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final form = useForm<RegistrationFields>(
      focusOnInvalid: true,
      validators: {
        .username: .required<String>().minLength(3),
        .email: .required<String>().email(),
        .password: .required<String>().minLength(8),
      },
    );

    Future<void> submit() async {
      if (!form.validate()) return;

      final response = await api.register(form.getValues());
      if (response.statusCode == 422) {
        // e.g. {"errors": {"username": "username_taken"}}
        final errors = Map<String, String>.from(response.data['errors']);
        // One refresh, then focus + scroll to the first field in error.
        form.setErrorsByName(errors);
      }
    }

    return HookedForm(
      form: form,
      child: Column(
        children: [
          const HookedTextFormField<RegistrationFields>(fieldHook: .username),
          const HookedTextFormField<RegistrationFields>(fieldHook: .email),
          const HookedTextFormField<RegistrationFields>(
            fieldHook: .password,
            obscureText: true,
          ),
          ElevatedButton(onPressed: submit, child: const Text('Register')),
        ],
      ),
    );
  }
}
```

Translate error codes such as `username_taken` with `FormErrorMessages.parseErrorCode`:

```dart
class AppFormMessages extends FormErrorMessages {
  const AppFormMessages();

  @override
  String? parseErrorCode(String errorCode, dynamic value) => switch (errorCode) {
    'username_taken' => 'This username is already taken',
    'email_taken' => 'An account already uses this email',
    _ => null,
  };
}
```

## Multi-step Forms (Wizard)

Use one form for all steps. `validateFields` checks the current step before moving on; the final `validate()` checks every field, including those on pages that are not mounted, by running their schema validators on their stored value.

```dart
enum SignUpFields { firstName, lastName, email, password }

const steps = [
  {SignUpFields.firstName, SignUpFields.lastName},
  {SignUpFields.email, SignUpFields.password},
];

class SignUpWizard extends HookWidget {
  const SignUpWizard({super.key});

  @override
  Widget build(BuildContext context) {
    final form = useForm<SignUpFields>(
      focusOnInvalid: true,
      validateOn: .afterFirstUnfocus,
      validators: {
        .firstName: .required<String>(),
        .lastName: .required<String>(),
        .email: .required<String>().email(),
        .password: .required<String>().minLength(8),
      },
    );
    final pages = usePageController();
    final step = useState(0);

    Future<void> next() async {
      if (!form.validateFields(steps[step.value])) return;

      if (step.value < steps.length - 1) {
        step.value++;
        await pages.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }

      if (form.validate()) {
        final response = await api.signUp(form.getValues());
        if (response.statusCode == 422) {
          form.setErrorsByName(Map<String, String>.from(response.data['errors']));
          // The errors are kept on fields of other pages, and shown when
          // their page is displayed again.
        }
      }
    }

    return HookedForm(
      form: form,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pages,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final fields in steps)
                  Column(
                    children: [
                      for (final field in fields)
                        HookedTextFormField<SignUpFields>(fieldHook: field),
                    ],
                  ),
              ],
            ),
          ),
          ElevatedButton(onPressed: next, child: const Text('Next')),
        ],
      ),
    );
  }
}
```

> Cross-field validators (`.matcheField`, `.requiredIf`, ...) of a field that is not mounted need at least one mounted field of the form to run; otherwise they are skipped.

## Asynchronous Form Validation

Use the `setError` method for asynchronous validation. The error disappears as soon as the user edits the field:

```dart
enum RegistrationFields { username }

class RegistrationForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm<RegistrationFields>(
      validators: {.username: .required<String>().minLength(3)},
    );
    final isLoading = useState(false);

    Future<void> validateUsernameAsync(String username) async {
      if (username.isEmpty) return;

      isLoading.value = true;
      try {
        final exists = await userRepository.checkUsernameExists(username);

        if (exists) {
          form.setError(RegistrationFields.username, 'Username is already taken');
        }
      } finally {
        isLoading.value = false;
      }
    }

    return HookedForm(
      form: form,
      child: Column(
        children: [
          HookedTextFormField<RegistrationFields>(
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
                final username = form.getValue<String>(RegistrationFields.username);
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

## Form Controller Enhancements

### Error Handling and Validation

```dart
// Set a field error with optional notification control
controller.setError(field, "Error message", notify: false);

// Set several errors at once (e.g. a 422 response)
controller.setErrors({.username: 'username_taken', .email: 'email_taken'});

// Clear all forced errors; notify: true refreshes the fields right away
controller.clearForcedErrors(notify: true);
```

### Automatic Form Validation

Control validation behavior to prevent rebuild errors:

```dart
controller.validate(
  notify: false,     // Prevent listener notifications
  clearErrors: true  // Drop forced errors first (defaults to false)
);
```

### Form State Tracking

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
