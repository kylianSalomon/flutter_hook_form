# Use Cases

Recipes for things that come up once a form grows past the basics covered in the main [README](../README.md).

- [Form Value Handling and Payload Conversion](#form-value-handling-and-payload-conversion)
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

## Asynchronous Form Validation

Use the `setError` method for asynchronous validation:

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

// Clear all forced errors
controller.clearForcedErrors(notify: true);
```

### Automatic Form Validation

Control validation behavior to prevent rebuild errors:

```dart
controller.validate(
  notify: false,     // Prevent listener notifications
  clearErrors: false // Keep existing forced errors
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
