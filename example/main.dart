import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(const MyApp());
}

class MyCustomMessages extends FormErrorMessages {
  @override
  String get required => 'This field is required';

  String minAge(int age) => 'You must be $age to use this.';

  @override
  String? parseErrorCode(String errorCode, dynamic value) {
    return switch (errorCode) {
      'min_age_error' when value is int => minAge(value),
      _ => null,
    };
  }
}

class SignInFormSchema extends FormSchema {
  SignInFormSchema();

  static const email = HookField<SignInFormSchema, String>('email');
  static const password = HookField<SignInFormSchema, String>('password');
  static const rememberMe = HookField<SignInFormSchema, bool>('rememberMe');

  @override
  Set<HookField<FormSchema, dynamic>> get fields =>
      {email, password, rememberMe};
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => HookFormScope(
        messages: MyCustomMessages(),
        child: child ?? const SignInPage(),
      ),
    );
  }
}

class SignInPage extends HookWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final form = useForm(formSchema: SignInFormSchema());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: HookedForm(
        form: form,
        child: Column(
          children: [
            const HookedTextFormField<SignInFormSchema>(
              fieldHook: SignInFormSchema.email,
            ),
            const HookedTextFormField<SignInFormSchema>(
              fieldHook: SignInFormSchema.password,
            ),
            HookedFormField<SignInFormSchema, bool>(
              fieldHook: SignInFormSchema.rememberMe,
              initialValue: false,
              builder: (value, onChanged, error) {
                return Checkbox(
                  value: value,
                  onChanged: onChanged,
                );
              },
            ),
            const SignUpCheckBox(),
            ElevatedButton(
              onPressed: () => form.validate(),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpCheckBox extends HookWidget {
  const SignUpCheckBox({super.key});

  @override
  Widget build(BuildContext context) {
    /// Don't use useForm<SignInFormSchema>() here,
    /// because it will create a new form instance.
    /// We want to use the same form instance as the parent provided by
    /// the [FormProvider] widget.
    final form = useFormContext<SignInFormSchema>(context);

    return FormField(
      key: form.fieldKey(SignInFormSchema.rememberMe),
      initialValue: false,
      builder: (field) {
        return Checkbox(
          value: field.value,
          onChanged: (value) {
            field.didChange(value);
            // This is the same as:
            form.updateValue(SignInFormSchema.rememberMe, value);
          },
        );
      },
    );
  }
}
