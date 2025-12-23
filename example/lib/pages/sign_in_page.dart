import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../schemas/form_schemas.dart';

/// Sign-in page demonstrating basic form usage.
///
/// This example shows:
/// - Using [useForm] hook to create a form controller
/// - Using [HookedForm] to wrap form fields
/// - Using [HookedTextFormField] for text inputs
/// - Using [HookedFormField] for custom widgets (checkbox)
/// - Form validation and submission
class SignInPage extends HookWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a form controller using the useForm hook.
    // The form controller manages all field states and validation.
    final form = useForm<SignInFields>(
      // Optionally provide initial values for fields
      initialValues: {SignInFields.email: '', SignInFields.password: ''},
    );

    // State for password visibility toggle
    final obscurePassword = useState(true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 32),
            // Wrap form fields with HookedForm to provide the form controller
            // to all child HookedTextFormField and HookedFormField widgets.
            HookedForm<SignInFields>(
              form: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email field using HookedTextFormField
                  const HookedTextFormField<SignInFields<String>>(
                    fieldHook: .email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  // Password field with visibility toggle
                  HookedTextFormField<SignInFields<String>>(
                    fieldHook: .password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            obscurePassword.value = !obscurePassword.value,
                      ),
                    ),
                    obscureText: obscurePassword.value,
                    textInputAction: .done,
                    autovalidateMode: .onUserInteraction,
                  ),
                  const SizedBox(height: 8),
                  // Remember me checkbox using HookedFormField
                  HookedFormField<SignInFields<bool>, bool>(
                    fieldHook: SignInFields.rememberMe,
                    builder: (value, onChanged, error) {
                      return CheckboxListTile(
                        title: const Text('Remember me'),
                        value: value ?? false,
                        onChanged: onChanged,
                        controlAffinity: .leading,
                        contentPadding: .zero,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            FilledButton(
              onPressed: () => _handleSubmit(context, form),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Sign In'),
              ),
            ),
            const SizedBox(height: 16),
            // Reset button
            OutlinedButton(
              onPressed: () => form.reset(),
              child: const Text('Reset Form'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(
    BuildContext context,
    FormFieldsController<SignInFields> form,
  ) {
    // Validate all fields before submission
    if (form.validate()) {
      // Get all form values
      final values = form.getValues();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sign in successful!\n'
            'Email: ${values[SignInFields.email]}\n'
            'Remember me: ${values[SignInFields.rememberMe]}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
