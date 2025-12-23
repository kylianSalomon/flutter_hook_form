import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../schemas/form_schemas.dart';

/// Registration page demonstrating advanced form usage.
///
/// This example shows:
/// - Multiple field types (text, dropdown, date picker, checkbox)
/// - Custom validation (password confirmation)
/// - Server-side error simulation with setError
/// - Form state tracking (hasChanged, isDirty)
class RegistrationPage extends HookWidget {
  const RegistrationPage({super.key});

  static const _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final form = useForm<RegistrationFields>();
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final isSubmitting = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: HookedForm<RegistrationFields>(
          form: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Username field
              const HookedTextFormField<RegistrationFields<String>>(
                fieldHook: .username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Choose a username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: .next,
                autovalidateMode: .onUserInteraction,
              ),
              const SizedBox(height: 16),
              // Email field
              const HookedTextFormField<RegistrationFields<String>>(
                fieldHook: .email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: .emailAddress,
                textInputAction: .next,
                autovalidateMode: .onUserInteraction,
              ),
              const SizedBox(height: 16),
              // Phone field (optional)
              const HookedTextFormField<RegistrationFields<String>>(
                fieldHook: .phone,
                decoration: InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: '+1234567890',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: .phone,
                textInputAction: .next,
                autovalidateMode: .onUserInteraction,
              ),
              const SizedBox(height: 16),
              // Password field
              HookedTextFormField<RegistrationFields<String>>(
                fieldHook: .password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'At least 8 characters',
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
                textInputAction: .next,
                autovalidateMode: .onUserInteraction,
              ),
              const SizedBox(height: 16),
              // Confirm password field with custom validator
              HookedTextFormField<RegistrationFields<String>>(
                fieldHook: .confirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => obscureConfirmPassword.value =
                        !obscureConfirmPassword.value,
                  ),
                ),
                obscureText: obscureConfirmPassword.value,
                textInputAction: .next,
                autovalidateMode: .onUserInteraction,
              ),
              const SizedBox(height: 16),
              // Birth date picker using HookedFormField
              HookedFormField<RegistrationFields, DateTime>(
                fieldHook: .birthDate,
                builder: (value, onChanged, error) {
                  return Column(
                    crossAxisAlignment: .start,
                    children: [
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                value ??
                                DateTime.now().subtract(
                                  const Duration(days: 6570),
                                ),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            onChanged?.call(date);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Birth Date (optional)',
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            errorText: error,
                          ),
                          child: Text(
                            value != null
                                ? '${value.day}/${value.month}/${value.year}'
                                : 'Select date',
                            style: TextStyle(
                              color: value != null ? null : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Country dropdown using HookedFormField
              HookedFormField<RegistrationFields, String>(
                fieldHook: .country,
                builder: (value, onChanged, error) {
                  return DropdownButtonFormField<String>(
                    initialValue: value?.isEmpty == true ? null : value,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      prefixIcon: const Icon(Icons.public_outlined),
                      errorText: error,
                    ),
                    hint: const Text('Select your country'),
                    items: _countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Terms and conditions checkbox
              HookedFormField<RegistrationFields, bool>(
                fieldHook: .agreeToTerms,
                builder: (value, onChanged, error) {
                  return Column(
                    crossAxisAlignment: .start,
                    children: [
                      CheckboxListTile(
                        title: const Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            children: [
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  decoration: .underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        value: value ?? false,
                        onChanged: onChanged,
                        controlAffinity: .leading,
                        contentPadding: .zero,
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            error,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Form state indicators
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Form State',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Has been interacted: ${form.hasBeenInteracted}'),
                      Text('Has changed: ${form.hasChanged}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Submit button
              FilledButton(
                onPressed: isSubmitting.value
                    ? null
                    : () => _handleSubmit(context, form, isSubmitting),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Account'),
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
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    FormFieldsController<RegistrationFields> form,
    ValueNotifier<bool> isSubmitting,
  ) async {
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    isSubmitting.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Simulate server-side validation error (e.g., username already taken)
    final username = form.getValue<String>(.username);
    if (username == 'admin') {
      // Use setError to show server-side validation errors
      form.setError(.username, 'username_taken');
      isSubmitting.value = false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username is already taken'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    isSubmitting.value = false;

    if (context.mounted) {
      final values = form.getValues();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created!\n'
            'Username: ${values[RegistrationFields.username]}\n'
            'Email: ${values[RegistrationFields.email]}\n'
            'Country: ${values[RegistrationFields.country]}\n'
            'date: ${form.getValue<DateTime>(.birthDate)?.toLocal().toString()}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
