import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

import '../schemas/form_schemas.dart';

/// A widget demonstrating segmented button with form integration.
///
/// This widget shows how to use [useFormContext] to access
/// the form controller and create custom form field widgets.
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the form from the parent context
    final form = useFormContext<ProfileFields>(context);

    return HookedFormField.explicit(
      form: form,
      fieldHook: ProfileFields.theme,
      notifyOnChange: true,
      builder: (value, onChanged, error) {
        return Column(
          crossAxisAlignment: .start,
          children: [
            const Text('Theme'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'light',
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: 'system',
                  label: Text('System'),
                  icon: Icon(Icons.settings_brightness),
                ),
              ],
              selected: {value ?? 'system'},
              onSelectionChanged: (selected) {
                onChanged?.call(selected.first);
              },
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
    );
  }
}
