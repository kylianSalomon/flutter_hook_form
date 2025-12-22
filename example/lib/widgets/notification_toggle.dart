import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

import '../schemas/form_schemas.dart';

/// A nested widget that demonstrates using [useFormContext].
///
/// This widget accesses the form controller from the parent [HookedForm]
/// or [HookedFormProvider] using [useFormContext].
///
/// Use this pattern when you want to:
/// - Break down large forms into smaller, reusable widgets
/// - Access form state in deeply nested widgets
/// - Keep form logic encapsulated within widgets
class NotificationToggle extends StatelessWidget {
  const NotificationToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the form controller from context.
    // This requires a HookedForm or HookedFormProvider ancestor.
    // DO NOT use useForm here - that would create a new form instance!
    final form = useFormContext<ProfileFields>(context);

    return HookedFormField.explicit(
      form: form,
      fieldHook: ProfileFields.notificationsEnabled,
      notifyOnChange: true,
      builder: (value, onChanged, error) {
        return SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive updates about your account'),
          value: value ?? true,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
