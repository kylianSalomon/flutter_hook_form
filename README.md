# flutter_hook_form

A type-safe form controller for Flutter applications using hooks. This package provides a flexible and type-safe way to handle form validation and state management in Flutter. Inspired by _react_hook_form_ package and _zod_.

## Features

- 🔒 **Type-safe**: Full type safety for form fields and validation
- 🎯 **Schema-based**: Define your form structure using a schema
- 🎨 **Customizable**: Easy to customize validation messages
- 🎭 **Flexible**: Works with any form field type
- 🚀 **Lightweight**: Minimal dependencies
- 🧪 **Testable**: Easy to test form validation logic

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_hook_form: ^1.0.0
```

## Usage

_flutter_hook_form_ use class declaration to define form schema. A form schema is a class that declare all form fields and validators applied to each fields. Because there is no mirroring feature in dart like in TypeScript, the form fields are declared as `TypedId` to bind an id with a type. This is mainly to avoid mistypping errors when declaring a `FormField`.

### Requirements

This package requires `flutter_hooks` to be installed in your project. The `useForm` hook can only be used within a `HookWidget` or a widget that uses the `HookConsumerWidget` mixin.

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
2. Access it through a provider using `useFormContext`
3. Use any other dependency injection method (see [Alternative Injection Methods](#alternative-injection-methods))

### Basic Form Setup

```dart
import 'package:flutter_hook_form/flutter_hook_form.dart';

// Define your form schema
class SignInFormSchema extends FormSchema {
  SignInFormSchema()
      : super(
          fields: {
            FormFieldScheme<String>(
              email,
              validators: (_, __) {}.email().required(),
            ),
            FormFieldScheme<String>(
              password,
              validators: (String ? value, __) {
                // You can specify custom validation function like that.
                if(value == 'password'){
                  return '"password" not allowed.'
                }
              }.required(),
            ),
          },
        );

  static const TypedId<String> email = TypedId('email');
  static const TypedId<String> password = TypedId('password');
}

// Use in your widget
class SignInForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: SignInFormSchema());

    return Form(
      key: form.key, /// <-- Bind the formController with the [Form].
      child: Column(
        children: [
          TextFormField(
            key: form.fieldKey(SignInFormSchema.email), /// <-- Bind each field with the generated key
            validator: form.validators(SignInFormSchema.email),
          ),
          TextFormField(
            key: form.fieldKey(SignInFormSchema.password),
            validator: form.validators(SignInFormSchema.password),
          ),
        ],
      ),
    );
  }
}
```

### Form Injection and Context Access

_flutter_hook_form_ provides a way to inject and access form controllers throughout your widget tree using the `FormProvider` and `useFormContext` hook.

```dart
class ParentWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: SignInFormSchema());

    return FormProvider(
      notifier: form,
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

    return TextFormField(
      key: form.fieldKey(SignInFormSchema.email),
      validator: form.validators(SignInFormSchema.email),
    );
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
    
    return Form(
      key: form.key,
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
    
    return Form(
      key: form.key,
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
      child: Form(
        key: form.key,
        child: // ... form fields
      ),
    );
  }
}
```

### Custom Validation Messages

_flutter_hook_form_ comes with validators messages customization. Simply override the `FormMessages` class and provide it via the `HookFormScope`. This allow to translate errors messages that appears in forms.

```dart
class CustomFormMessages extends FormMessages {
  const CustomFormMessages();

  @override
  String get required => 'Ce champ est requis';
  
  @override
  String get invalidEmail => 'Adresse email invalide';
}

void main() {
  runApp(
    HookFormScope(
      messages: const CustomFormMessages(),
      child: const MyApp(),
    ),
  );
}
```

### Available Validators

```dart
// String validators
(_, __) {}.required()
(_, __) {}.email()
(_, __) {}.phone()
(_, __) {}.min(5)
(_, __) {}.max(10)

// File validators
(_, __) {}.format({'image/jpeg', 'image/png'})

// Date validators
(_, __) {}.isAfter(DateTime.now())
(_, __) {}.isBefore(DateTime.now())

// List validators
(_, __) {}.minItems(2)
(_, __) {}.maxItems(5)
```

🚨 **Be Careful** : validators of the same type can be _chained_ but the order is important. Last in the chain will be the first executed.

```dart
// ❌ "required field" error will not appear because "min" is executed first
(_,__){}.required().email().min(2)

// ✅ "required field" error will appear if the field is empty.
(_,__){}.email().min(2).required()
```

### Use Cases

#### Form Value Handling and Payload Conversion

One of the main pain points in Flutter forms is handling form values and converting them to the correct payload format. _flutter_hook_form_ makes this process much easier by allowing you to define static methods in your form schema for validation and payload conversion.

```dart
class SignInFormSchema extends FormSchema {
  SignInFormSchema()
      : super(
          fields: {
            FormFieldScheme<String>(
              email,
              validators: (_, __) {}.email().required(),
            ),
            FormFieldScheme<String>(
              password,
              validators: (_, __) {}.required(),
            ),
          },
        );

  static const TypedId<String> email = TypedId('email');
  static const TypedId<String> password = TypedId('password');


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
