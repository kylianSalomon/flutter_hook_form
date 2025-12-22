import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../schemas/form_schemas.dart';
import '../widgets/notification_toggle.dart';
import '../widgets/theme_selector.dart';

/// Profile page demonstrating useFormContext for nested widgets.
///
/// This example shows:
/// - Using [useFormContext] to access form controller in child widgets
/// - Building reusable form field widgets
/// - Using [HookedFormField.explicit] when form is provided directly
/// - Custom widgets with form integration
class ProfilePage extends HookWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final form = useForm<ProfileFields>(
      initialValues: {
        ProfileFields.firstName: 'John',
        ProfileFields.lastName: 'Doe',
        ProfileFields.bio: '',
        ProfileFields.website: '',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: form.hasChanged
                ? () => _handleSave(context, form)
                : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: form.hasChanged ? Colors.deepPurple : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: HookedForm<ProfileFields>(
          form: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile avatar section
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Image picker not implemented in this example',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Name fields in a row
              const Row(
                children: [
                  Expanded(
                    child: HookedTextFormField<ProfileFields<String>>(
                      fieldHook: .firstName,
                      decoration: InputDecoration(labelText: 'First Name'),
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: HookedTextFormField<ProfileFields<String>>(
                      fieldHook: .lastName,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      textInputAction: .next,
                      autovalidateMode: .onUserInteraction,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bio field with character counter
              HookedFormField(
                fieldHook: ProfileFields.bio,
                notifyOnChange: true,
                builder: (value, onChanged, error) {
                  return TextField(
                    controller: TextEditingController(text: value),
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself',
                      errorText: error,
                      counterText: '${value?.length ?? 0}/500',
                    ),
                    maxLines: 3,
                    maxLength: 500,
                    onChanged: onChanged,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Website field with inline validator
              HookedTextFormField<ProfileFields<String>>(
                fieldHook: .website,
                decoration: const InputDecoration(
                  labelText: 'Website (optional)',
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // Custom inline validator - useful when validator needs runtime data
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  final urlPattern = RegExp(
                    r'^https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
                  );
                  if (!urlPattern.hasMatch(value)) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              // Nested widget using useFormContext
              // This demonstrates how child widgets can access the form
              const NotificationToggle(),
              const SizedBox(height: 16),
              // Another nested widget for theme selection
              const ThemeSelector(),
              const SizedBox(height: 32),
              // Discard changes button
              if (form.hasChanged)
                OutlinedButton(
                  onPressed: () {
                    form.reset();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Changes discarded')),
                    );
                  },
                  child: const Text('Discard Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave(
    BuildContext context,
    FormFieldsController<ProfileFields> form,
  ) {
    if (form.validate()) {
      final values = form.getValues();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile saved!\n'
            'Name: ${values[ProfileFields.firstName]} ${values[ProfileFields.lastName]}\n'
            'Theme: ${form.getValue(.theme)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
