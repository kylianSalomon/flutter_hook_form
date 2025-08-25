# flutter_hook_form

A type-safe form controller for Flutter applications using hooks. This package provides a flexible and type-safe way to handle form validation and state management in Flutter. Inspired by _react_hook_form_ package.

## Motivation

Managing forms in Flutter can be challenging, especially when dealing with multiple form fields and their controllers. The traditional approach requires creating and managing individual controllers for each field, which can lead to boilerplate code and reduced maintainability. `flutter_hook_form` was created to address these challenges by providing a more streamlined and declarative way to handle forms, making the form configuration process more intuitive and maintainable. Unlike other form solutions that introduce new widgets and require significant refactoring, `flutter_hook_form` is designed to work seamlessly with Flutter's built-in form widgets. This means you can gradually adopt it in your existing forms without having to rewrite your entire form structure or learn new widget patterns.

The benefits of using `flutter_hook_form` are clear:

- 🧹 **Reduced Boilerplate**: No need to manually create and dispose controllers
- 🔒 **Type Safety**: Form fields are type-safe and validated at compile time
- ♻️ **Reusable Validation**: Built-in validators and easy custom validation
- 📝 **Cleaner Code**: Form logic is separated into a schema class
- 🎮 **Better State Management**: Form state is handled automatically
- 🌍 **Internationalization Ready**: Built-in support for translated error messages

## Table of Contents

- [Getting Started](#getting-started)
- [How to use](#how-to-use)
  - [Install](#install)
  - [Create your Schema](#create-your-schema)
    - [Available Validators](#available-validators)
    - [Create validators](#create-validators)
  - [Use "hooked" widget](#use-hooked-widgets)
    - [Use form controller](#use-form-controller)
    - [HookedTextFormField](#hookedtextformfield)
    - [HookedFormField](#hookedformfield)
    - [Form State Management](#form-state-management)
    - [Form Field State](#form-field-state)
- [Customizations](#customizations)
  - [Custom Validation Messages & Internationalization](#custom-validation-messages--internationalization)
  - [Alternative Injection Methods](#alternative-injection-methods)
  - [Form Injection and Context Access](#form-injection-and-context-access)
  - [Write your own Form field](#write-your-own-form-field)
- [Use Cases](#use-cases)
  - [Form Value Handling and Payload Conversion](#form-value-handling-and-payload-conversion)
  - [Asynchronous Form Validation](#asynchronous-form-validation)
  - [Form Controller Enhancements](#form-controller-enhancements)
- [Additional Information](#additional-information)
  - [Dependencies](#dependencies)
  - [Contributing](#contributing)
  - [License](#license)
- [Support](#support)

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_hook_form: ^1.0.0
```

## How to use

### Install

To use `flutter_hook_form`, you need to add it to your dependencies in `pubspec.yaml`:

```yaml
dependencies:
  flutter_hook_form: ^1.0.0
  
  # Not essential but recommended, for different dependency injection
  # see "Alternative Injection Methods" paragraph.
  flutter_hooks: ^0.20.0
```

### Create your Schema

```dart
import 'package:flutter_hook_form/flutter_hook_form.dart';

part 'signin_form.schema.dart';

class SignInFormSchema extends FormSchema {
  SignInFormSchema();
  
  static const email = HookField<SignInFormSchema, String>(
    'email',
    validators: [RequiredValidator(), EmailValidator()],
  );

  static const password = HookField<SignInFormSchema, String>(
    'password',
    validators: [RequiredValidator(),  MinLengthValidator(8)],
  );

  static Set<InitializedField<SignInFormSchema, dynamic>> initWith(
      String? email,
      String? password,
    ) {
    return _SignInFormSchema.initializeWith(
      email: email,
      password: password,
    );
  }
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
| | `PatternValidator` | Validate the value with the given pattern | `PatternValidator(r'^[A-zÀ-ú \-]+$')` |
| **Date** | `IsAfterValidator` | Validates minimum date | `IsAfterValidator(DateTime.now())` |
| | `IsBeforeValidator` | Validates maximum date | `IsBeforeValidator(DateTime.now())` |
| **List** | `ListMinItemsValidator` | Checks minimum items | `ListMinItemsValidator<T>(2)` |
| | `ListMaxItemsValidator` | Checks maximum items | `ListMaxItemsValidator<T>(5)` |
| **File** | `MimeTypeValidator` | Validates file type | `MimeTypeValidator({'image/jpeg', 'image/png'})` |

🚨 **Important**: When using multiple validators, they are executed in the order they are defined in the list.

#### Create validators

You can create custom validators by extending the `Validator` class. To support **Internationalization**, return the defined
`errorCode` on error. For more info about internationalization see [Custom Validation Messages & Internationalization](#custom-validation-messages--internationalization).

```dart
class UsernameValidator extends Validator<String> {
  const UsernameValidator() : super(errorCode: 'username_error');

  @override
  ValidatorFn<String> get validator => (String? value) {
        if (value?.contains('@') == true) {
          return errorCode; // <- needed for Internationalization
        }
        return null;
      };
}

// Use in your form schema
static const username = HookField<ProfileFormSchema, String>(
    'username',
    validators: [ RequiredValidator<String>(),UsernameValidator(),],
  );
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
          return errorCode; // <- needed for Internationalization
        }
        return null;
      };
}
```

### Use "Hooked" widgets

`flutter_hook_form` includes a set of convenient Form widgets to streamline your development process.

_Note that these widgets are entirely optional and simply wrap Flutter's standard form widgets. This package is designed to be highly customizable and adaptable to your specific needs._

#### Use form controller

To use the `useForm` hook, you need to install `flutter_hooks` in your project. The `useForm` hook can only be used within a `HookWidget` or a widget that uses the `HookConsumerWidget` mixin.

```dart
// ✅ Correct usage
class MyForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: MyFormSchema());
    // ...
  }
}

// ✅ Also correct with Riverpod
class MyForm extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = useForm(formSchema: MyFormSchema());
    // ...
  }
}

// ❌ Incorrect usage
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: MyFormSchema()); // This will not work
    // ...
  }
}
```

If you need to use the form controller in a regular widget, you can either:

1. Use the `FormFieldsController` directly
2. Access it through a provider using `useFormContext` (`HookWidget` not necessary here as it is not a hook.)
3. Use any other dependency injection method (see [Alternative Injection Methods](#alternative-injection-methods))

#### HookedTextFormField

`HookedTextFormField` is a wrapper around Flutter's `TextFormField` that integrates with the form controller:

```dart
HookedTextFormField(
  fieldHook: SignInFormSchema.email,
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
```

#### HookedFormField

`HookedFormField` is a generic form field that can be used with any type of input:

```dart
HookedFormField(
  fieldHook: SignInFormSchema.rememberMe,
  builder: ({value, onChanged, error}) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
    );
  },
)
```

Here's a complete example of a form using these widgets:

```dart
class SignInForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(
      formSchema: SignInFormSchema()
    // You can define initial values here if needed
      initialValues: SignInFormSchema.initializeWith(
        email: 'user@example.com',
        password: '',
      )
    );

    return HookedForm(
      form: form, // Bind the form controller with the Form widget
      child: Column(
        children: [
          // No need to specify the form schema type - it's inferred from the fieldHook
          HookedTextFormField(
            fieldHook: SignInFormSchema.email,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
          ),
          
          HookedTextFormField(
            fieldHook: SignInFormSchema.password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
            ),
          ),
          
          // No need to specify the form schema type or value type - both are inferred
          HookedFormField(
            fieldHook: SignInFormSchema.rememberMe,
            builder: (field) {
              return Checkbox(
                value: field.value,
                onChanged: (value) => field.didChange(value),
              );
            },
          ),
          
          ElevatedButton(
            onPressed: () {
              if (form.validate()) {
                // Form is valid, get all values
                final values = form.getValues();
                print('Email: ${values[SignInFormSchema.email]}');
                print('Password: ${values[SignInFormSchema.password]}');
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

#### Form initialization

When you want to initialized your form with a value, you can assign a value to each `HookField` of your choice:

```dart
final form = useForm(
  formSchema: SignInFormSchema()
  initialValues: {
    SignInFormSchema.email.withInitialValue('user@example.com'),
    SignInFormSchema.password.withInitialValue(''),
  }
);
```

#### Form State Management

The form controller provides several methods to manage form state:

```dart
// Update a field value
form.updateValue(SignInFormSchema.email, 'new@email.com');

// Get a field value
final email = form.getValue(SignInFormSchema.email);

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
// Check if a field has been modified
final isDirty = form.isDirty(SignInFormSchema.email);

// Check if a specific field is valid
final isEmailValid = form.validateField(SignInFormSchema.email);

// Get field error message
final error = form.getFieldError(SignInFormSchema.email);
```

## Customizations

### Custom Validation Messages & Internationalization

_flutter_hook_form_ comes with validators messages customization. Simply override the `FormErrorMessages` class and provide it via the `HookFormScope`. This allows you to translate error messages that appear in forms.

```dart
class CustomFormMessages extends FormErrorMessages {
  const CustomFormMessages(this.context);

  final BuildContext context;

  @override
  String get required => 'This field is required.';
  
  @override
  String get invalidEmail => AppLocalizations.of(context).invalidEmail;

  String minAgeError(int age) => 'You must be $age to use this.'

   @override
  String? parseErrorCode(String errorCode, dynamic value) {
    final error = switch (errorCode) {
      // Same error code used in the MinAgeValidator definition
      'min_age_error' when value is int => minAgeError(value),
      _ => null,
    };

    return error;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

The `parseErrorCode` method is the key component for custom error message handling. It maps your validator error codes to their corresponding translated messages.

### Form Injection and Context Access

_flutter_hook_form_ provides a way to inject and access form controllers throughout your widget tree using the `HookedForm` widget and `useFormContext` hook. Use the `HookedForm` to inject the `form` in the widget tree and then retrieve the instance with the `useFormContext` in child widget.

Remember that you don't need `useFormContext` if you use a _"Hooked"_ widget.

```dart
class ParentWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: SignInFormSchema());

    return HookedForm(
      form: form,
      child: Column(
        children: [
          // Child widgets can access the form using useFormContext
          const ChildWidget(),
        ],
      ),
    );
  }
}

class ChildWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useFormContext<SignInFormSchema>();

    return ///... child widget
  }
}
```

### Alternative Injection Methods

While `HookedForm` is the recommended way to inject form controllers, you can also use any other dependency injection method or package. Here are some examples:

#### Using Riverpod

```dart
final signInFormProvider = Provider<FormFieldsController<SignInFormSchema>>((ref) {
  return FormFieldsController(
    GlobalKey<FormState>(),
    SignInFormSchema(),
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
  getIt.registerLazySingleton<FormFieldsController<SignInFormSchema>>(
    () => FormFieldsController(
      GlobalKey<FormState>(),
      SignInFormSchema(),
    ),
  );
}

class SignInForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = getIt<FormFieldsController<SignInFormSchema>>();
    
    return HookedForm(
      form: form,
      child: // ... form fields
    );
  }
}
```

#### Using Provider

```dart
class SignInForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = FormFieldsController(
      GlobalKey<FormState>(),
      SignInFormSchema(),
    );

    return ChangeNotifierProvider.value(
      value: form,
      child: HookedForm(
        form: form,
        child: // ... form fields
      ),
    );
  }
}
```

#### Navigating with the form instance

In case of a navigation, a new widget tree is generated and you may loose the access to the form instance, resulting in an
error when using the `userFormContext`. To avoid this, use a `HookedFormProvider` on top of your new widget tree to provide
the created form :

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

### Write your own Form field

"Hooked" widgets are here to facilitate form development, but you can write your own form fields to fit your specific needs. Behind the scenes, `HookedFormField` and `HookedTextFormField` are simply wrappers around Flutter's standard `FormField` and `TextFormField` that connect them to the form controller.

To create your own custom form field, you need to:

1. Connect to the form controller (either via `useFormContext` or by passing it directly)
2. Use the correct field ID from your schema
3. Handle validation and error display
4. Register value changes with the form controller

Here's a simple example of a custom checkbox form field:

```dart
class CustomCheckboxField<F extends FormSchema> extends HookWidget {
  const CustomCheckboxField({
    Key? key,
    required this.fieldHook,
    this.initialValue = false,
    required this.label,
  }) : super(key: key);

  final HookedFieldId<F, bool> fieldHook;
  final bool initialValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Get the form controller from context
    final form = useFormContext<F>();
    
    return FormField<bool>(
      // Connect the field to the form using the fieldHook
      key: form.getFieldKey(fieldHook),
      validator: (_) => form.getFieldError(fieldHook),
      builder: (field) {
        return Row(
          children: [
            Checkbox(
              value: field.value ?? false,
              onChanged: (value) {
                // Update the field value
                field.didChange(value);
                // Notify the form controller about the change
                form.registerFieldChange(fieldHook, value);
              },
            ),
            Text(label),
            if (field.hasError)
              Text(
                field.errorText!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        );
      },
    );
  }
}
```

For more complex implementations, refer to the source code of:

- [HookedFormField](https://github.com/kylianSalomon/flutter_hook_form/blob/main/lib/src/widget/hooked_form_field.dart)
- [HookedTextFormField](https://github.com/kylianSalomon/flutter_hook_form/blob/main/lib/src/widget/hooked_text_form_field.dart)

The key aspects to remember when creating custom form fields:

- Use `form.getFieldKey(fieldHook)` to connect the field to the form controller
- Use `form.getFieldError(fieldHook)` for validation
- Call `form.registerFieldChange(fieldHook, newValue)` when the value changes
- Handle the display of error messages appropriately

## Use Cases

### Form Value Handling and Payload Conversion

One of the main pain points in Flutter forms is handling form values and converting them to the correct payload format. _flutter_hook_form_ makes this process much easier by allowing you to define static methods in your form schema for validation and payload conversion.

```dart
class SignInFormSchema extends FomSchema {
  SignInFormSchema();

  static const email = HookField<SignInFormSchema, String>(
    'email',
    validators: [RequiredValidator(), EmailValidator()],
  );

  static const password = HookField<SignInFormSchema, String>(
    'password',
    validators:[ RequiredValidator<String>(),MinLengthValidator(8)]
  )

  // Static method to validate and convert form values to API payload
  static SignInPayload toPayload(FormFieldsController form) {
    if(!form.validate()){
      return null;
    }

    return SignInPayload(
      email: form.getValue(email)!,
      password: form.getValue(password)!,
    );
  }
}

// Usage in your widget
class SignInForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: SignInFormSchema());

    return Form(
      key: form.key,
      child: Column(
        children: [
          // ... form fields
          ElevatedButton(
            onPressed: () {
              if (form.validate()) {
                final payload = SignInFormSchema.toPayload(form);
                // Send payload to API
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

This approach provides several benefits:

- Type-safe form value handling
- Centralized validation logic
- Easy payload conversion
- Reusable form schemas
- Clear separation of concerns

### Asynchronous Form Validation

Flutter's built-in form validation is synchronous, but real-world applications often require asynchronous validation, such as checking if a username is already taken or validating an address with an API.

`flutter_hook_form` supports asynchronous validation through the `setError` method on the form controller.

Here's how to implement asynchronous validation:

```dart
class RegistrationForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: RegistrationFormSchema());
    final isLoading = useState(false);

    Future<void> validateUsernameAsync(String username) async {
      // Skip validation if empty (let the required validator handle it)
      if (username.isEmpty) return;
      
      isLoading.value = true;
      try {
        // Call your API to check if username exists
        final exists = await userRepository.checkUsernameExists(username);
        
        if (exists) {
          // Set error manually if username is taken
          form.setError(RegistrationFormSchema.username, 'Username is already taken');
        }
      } finally {
        isLoading.value = false;
      }
    }

    return HookedForm(
      form: form,
      child: Column(
        children: [
          HookedTextFormField(
            fieldHook: RegistrationFormSchema.username,
            decoration: InputDecoration(
              labelText: 'Username',
              suffixIcon: isLoading.value 
                ? const CircularProgressIndicator(strokeWidth: 2)
                : null,
            ),
            onChanged: (value) {
              // Trigger async validation when the value changes
              validateUsernameAsync(value);
            },
          ),
          ElevatedButton(
            onPressed: () async {
              // First perform synchronous validation
              if (form.validate()) {
                final username = form.getValue(RegistrationFormSchema.username);
                
                // Then perform async validation before submission
                await validateUsernameAsync(username);
                
                // Check if any async errors were set
                if (!form.hasFieldError(RegistrationFormSchema.username)) {
                  // No errors, proceed with form submission
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

The FormFieldsController now provides finer control over error handling and validation:

```dart
// Set a field error with optional notification control
controller.setError(fieldId, "Error message", notify: false);

// Clear all forced errors
controller.clearForcedErrors(notify: true);
```

#### Automatic Form Validation

When using `formController.validate()` to automatically validate forms, you might encounter rebuild errors if the widget hasn't finished its initial build cycle. To prevent this and gain more control over validation behavior, use the new optional parameters:

```dart
// Validate with custom options
controller.validate(
  notify: false,     // Prevent listener notifications that would trigger rebuilds
  clearErrors: false // Keep existing forced errors instead of clearing them
);
```

These parameters are particularly useful when validating forms in response to button presses or when implementing conditional form submission logic.

#### Form State Tracking

New properties help you track form interaction and changes:

```dart
// Check if any field has been interacted with by the user
if (controller.hasBeenInteracted) {
  // Show confirmation dialog before navigating away
}

// Check if any field value has changed from its initial value
if (controller.hasChanged) {
  // Enable the "Save Changes" button
}
```

These state tracking features simplify the implementation of common form patterns like "dirty form" detection and user interaction monitoring.

## Additional Information

### Dependencies

- flutter_hooks: ^0.20.0
- collection: ^1.17.0

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/kylianSalomon/flutter_hook_form/issues).
