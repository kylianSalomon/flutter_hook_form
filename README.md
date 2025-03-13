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

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_hook_form: ^1.0.0
```

## Usage

### Basic Form Setup

`flutter_hook_form` provides two ways to define your form schema:

#### 1. Using Code Generation (Recommended)

The package includes a code generator that helps you define form schemas using annotations. This approach reduces boilerplate and provides better type safety.

First, add the following dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
```

Then define your form schema:

```dart
import 'package:flutter_hook_form/flutter_hook_form.dart';

part 'signin_form.schema.dart';

@HookFormSchema()
class SignInFormSchema extends _SignInFormSchema {
  SignInFormSchema() : super(email: email, password: password);

  @HookFormField<String>(validators: [
    RequiredValidator<String>(),
    EmailValidator(),
  ])
  static const email = _EmailFieldSchema();

  @HookFormField<String>(validators: [
    RequiredValidator<String>(),
    MinLengthValidator(8),
  ])
  static const password = _PasswordFieldSchema();
}
```

After defining your schema:

1. Run `flutter pub run build_runner build` to generate the code
2. The generator will create the `_SignInFormSchema` class and field schema classes
3. Make sure to pass all static fields to the super constructor as shown above

#### 2. Manual Definition

If you prefer not to use code generation, you can define your form schema manually:

```dart
import 'package:flutter_hook_form/flutter_hook_form.dart';

class SignInFormSchema extends FormSchema {
  SignInFormSchema()
      : super(
          fields: {
            const FormFieldScheme<String>(
              email,
              validators: [
                RequiredValidator(),
                EmailValidator(),
              ],
            ),
            const FormFieldScheme<String>(
              password,
              validators: [
                RequiredValidator<String>(),
                MinLengthValidator(8),
              ],
            ),
          },
        );

  static const TypedId<String> email = TypedId('email');
  static const TypedId<String> password = TypedId('password');
}
```

Both approaches produce the same result, but the code generation approach is recommended as it:

- Reduces boilerplate code
- Provides better type safety
- Makes form maintenance easier
- Ensures consistency in form field definitions

### Using the Form Hook

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

### Custom Validators

You can create custom validators by extending the `Validator` class. This allows you to define reusable validation logic that can be used across different forms.

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
@HookFormField<String>(validators: [
  RequiredValidator<String>(),
  UsernameValidator(),
])
static const username = _UsernameFieldSchema();
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

// Usage
@HookFormField<DateTime>(validators: [
  RequiredValidator<DateTime>(),
  MinAgeValidator(minAge: 18),
])
static const birthDate = _BirthDateFieldSchema();
```

Note: Validators return an `errorCode` instead of the actual error message. This design enables internationalization of error messages. The error codes are mapped to translated messages using the `FormErrorMessages` class. See [Custom Validation Messages & Internationalization](#custom-validation-messages--internationalization) for more details.

### How to use

`flutter_hook_form` includes a set of convenient Form widgets to streamline your development process.

_Note that these widgets are entirely optional and simply wrap Flutter's standard form widgets. This package is designed to be highly customizable and adaptable to your specific needs._

```dart
class SignInForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: SignInFormSchema());

    return HookedForm(
      form: form, // Bind the form controller with the Form widget
      child: Column(
        children: [
          HookedTextFormField<SignInFormSchema>( // <- Don't forget to provide the FormSchema
            fieldKey: SignInFormSchema.email,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
          ),
          HookedTextFormField<SignInFormSchema>(
            fieldKey: SignInFormSchema.password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
            ),
          ),
          HookedFormField<SignInFormSchema, bool>( // <- use the HookedFormField for custom form field
            fieldKey: SignInFormSchema.rememberMe,
            initialValue: false,
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

**Why can't I initialize my form value in the form controller or form schema?**

When you need to pre-populate a form, the correct approach is to provide initial values at the widget level in the `initialValue` property provided by Flutter `FormField`, or update the values after the first build cycle when the form fields have been properly initialized and connected to their keys (not recommended).

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

### Form Injection and Context Access

_flutter_hook_form_ provides a way to inject and access form controllers throughout your widget tree using the `FormProvider` and `useFormContext` hook.

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

While `FormProvider` is the recommended way to inject form controllers, you can also use any other dependency injection method or package. Here are some examples:

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

### Custom Validation Messages & Internationalization

_flutter_hook_form_ comes with validators messages customization. Simply override the `FormErrorMessages` class and provide it via the `HookFormScope`. This allow to translate errors messages that appears in forms.

```dart
class CustomFormMessages extends FormErrorMessages {
  const CustomFormMessages(this.context);

  final BuildContext context;

  @override
  String get required => 'This field is required.';
  
  @override
  String get invalidEmail => AppLocalizations.of(context).invalideEmail;

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
        messages: MyCustomMessages(context),
        child: child ?? const SignInPage(),
      ),
    );
  }
}
```

The `parseErrorCode` method is the key component for custom error message handling. It maps your validator error codes to their corresponding translated messages. This allows you to:

- Define custom error codes in your validators
- Map these codes to localized messages
- Handle parameterized error messages (like the `minAgeError` example above)
- Fallback to default messages when no custom mapping is defined

### Available Validators

The package comes with several built-in validators that can be used in your form fields:

| Category | Validator | Description | Example |
|----------|-----------|-------------|---------|
| **Generic** | `RequiredValidator<T>` | Ensures field is not empty | `RequiredValidator<String>()` |
| **String** | `EmailValidator` | Validates email format | `EmailValidator()` |
| | `MinLengthValidator` | Checks minimum length | `MinLengthValidator(8)` |
| | `MaxLengthValidator` | Checks maximum length | `MaxLengthValidator(32)` |
| | `PhoneValidator` | Validates phone number format | `PhoneValidator()` |
| **Date** | `DateTimeValidator.isAfter` | Validates minimum date | `DateTimeValidator.isAfter(DateTime.now())` |
| | `DateTimeValidator.isBefore` | Validates maximum date | `DateTimeValidator.isBefore(DateTime.now())` |
| **List** | `ListValidator.minItems` | Checks minimum items | `ListValidator.minItems<T>(2)` |
| | `ListValidator.maxItems` | Checks maximum items | `ListValidator.maxItems<T>(5)` |
| **File** | `FileValidator.mimeType` | Validates file type | `FileValidator.mimeType({'image/jpeg', 'image/png'})` |

🚨 **Important**: When using multiple validators, they are executed in the order they are defined in the list. For example:

```dart
@HookFormField<String>(validators: [
  RequiredValidator<String>(), // Executed first
  EmailValidator(),           // Executed second
])
static const email = _EmailFieldSchema();
```

### Use Cases

#### Form Value Handling and Payload Conversion

One of the main pain points in Flutter forms is handling form values and converting them to the correct payload format. _flutter_hook_form_ makes this process much easier by allowing you to define static methods in your form schema for validation and payload conversion.

```dart
@HookFormSchema()
class SignInFormSchema extends _SignInFormSchema {
  SignInFormSchema() : super(email: email, password: password);

  @HookFormField<String>(validators: [
    RequiredValidator<String>(),
    EmailValidator(),
  ])
  static const email = _EmailFieldSchema();

  @HookFormField<String>(validators: [
    RequiredValidator<String>(),
    MinLengthValidator(8),
  ])
  static const password = _PasswordFieldSchema();

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
                final values = form.getValues();
                if (SignInFormSchema.validateForm(values)) {
                  final payload = SignInFormSchema.toPayload(values);
                  // Send payload to API
                }
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

#### Asynchronous form validation

Flutter's built-in form validation is synchronous, but real-world applications often require asynchronous validation, such as checking if a username is already taken or validating an address with an API.

`flutter_hook_form` supports asynchronous validation through the `forceErrorText` property and the `setError` method on the form controller.

##### Basic Implementation

Here's how to implement asynchronous validation:

```dart
@HookFormSchema()
class RegistrationFormSchema extends _RegistrationFormSchema {
  RegistrationFormSchema() : super(username: username);

  @HookFormField<String>(validators: [
    RequiredValidator<String>(),
    EmailValidator(),
  ])
  static const username = _UsernameFieldSchema();

  // Static method to do form asynchronous validation
  static Future<bool> validateUsername(FormFieldsController form) async{
    if(!form.validate()){
      return false;
    }

    try {
      // Call your API to check if username exists
      final exists = await userRepository.checkUsernameExists(username);
      
      if (exists) {
        // Set error manually if username is taken
        form.setError(RegistrationFormSchema.username, 'Username is already taken');
        return false;
      }

      return true;
    } finally {
     return true;
    }
  }
}
class RegistrationForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: RegistrationFormSchema());

    return HookedForm(
      form: form,
      child: Column(
        children: [
          HookedTextFormField<RegistrationFormSchema>(
            fieldKey: RegistrationFormSchema.username,
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Form is validated synchronously first then asynchronously.
              final isValid = await RegistrationFormSchema.validateUsername();

              if (isValid) {
                // No errors, proceed with form submission
                submitForm(form);
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
