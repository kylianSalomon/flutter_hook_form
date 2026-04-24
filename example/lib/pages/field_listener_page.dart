import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Demonstrates granular field listening with [useFieldValue].
///
/// This example shows how widgets can listen to specific fields and only
/// rebuild when those fields change, improving performance.
class FieldListenerPage extends HookWidget {
  const FieldListenerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final form = useForm<DemoFields>(
      initialValues: {
        DemoFields.firstName: '',
        DemoFields.lastName: '',
        DemoFields.age: '',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Listener Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanation card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Granular Rebuilds Demo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Each card below listens to a specific field using useFieldValue. '
                      'The rebuild counter shows how many times each widget has rebuilt. '
                      'Notice that only the relevant card rebuilds when you type!',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            HookedForm<DemoFields>(
              form: form,
              child: Column(
                children: [
                  HookedTextFormField<DemoFields<String>>(
                    fieldHook: DemoFields.firstName,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    notifyOnChange: true, // Important: enables ValueNotifier updates
                  ),
                  const SizedBox(height: 16),
                  HookedTextFormField<DemoFields<String>>(
                    fieldHook: DemoFields.lastName,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    notifyOnChange: true,
                  ),
                  const SizedBox(height: 16),
                  HookedTextFormField<DemoFields<String>>(
                    fieldHook: DemoFields.age,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    notifyOnChange: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              'Field Listeners',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Listener cards - each listens to a specific field
            _FirstNameListener(form: form),
            const SizedBox(height: 12),
            _LastNameListener(form: form),
            const SizedBox(height: 12),
            _AgeListener(form: form),
            const SizedBox(height: 12),
            _FullNameListener(form: form),

            const SizedBox(height: 32),

            // Reset button
            OutlinedButton.icon(
              onPressed: () => form.reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Form'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Listens ONLY to firstName field
class _FirstNameListener extends HookWidget {
  const _FirstNameListener({required this.form});
  final FormFieldsController<DemoFields> form;

  @override
  Widget build(BuildContext context) {
    // Track rebuilds
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    // Listen to firstName only
    final firstName = useFieldValue<DemoFields, String>(form, DemoFields.firstName);

    return _ListenerCard(
      title: 'First Name Listener',
      field: 'firstName',
      value: firstName ?? '(empty)',
      rebuildCount: rebuildCount.value,
      color: Colors.blue,
    );
  }
}

/// Listens ONLY to lastName field
class _LastNameListener extends HookWidget {
  const _LastNameListener({required this.form});
  final FormFieldsController<DemoFields> form;

  @override
  Widget build(BuildContext context) {
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    final lastName = useFieldValue<DemoFields, String>(form, DemoFields.lastName);

    return _ListenerCard(
      title: 'Last Name Listener',
      field: 'lastName',
      value: lastName ?? '(empty)',
      rebuildCount: rebuildCount.value,
      color: Colors.green,
    );
  }
}

/// Listens ONLY to age field
class _AgeListener extends HookWidget {
  const _AgeListener({required this.form});
  final FormFieldsController<DemoFields> form;

  @override
  Widget build(BuildContext context) {
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    final age = useFieldValue<DemoFields, String>(form, DemoFields.age);

    return _ListenerCard(
      title: 'Age Listener',
      field: 'age',
      value: age ?? '(empty)',
      rebuildCount: rebuildCount.value,
      color: Colors.orange,
    );
  }
}

/// Listens to BOTH firstName AND lastName fields
class _FullNameListener extends HookWidget {
  const _FullNameListener({required this.form});
  final FormFieldsController<DemoFields> form;

  @override
  Widget build(BuildContext context) {
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    // Listen to multiple fields
    final firstName = useFieldValue<DemoFields, String>(form, DemoFields.firstName);
    final lastName = useFieldValue<DemoFields, String>(form, DemoFields.lastName);

    final fullName = [firstName, lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    return _ListenerCard(
      title: 'Full Name Listener',
      field: 'firstName + lastName',
      value: fullName.isEmpty ? '(empty)' : fullName,
      rebuildCount: rebuildCount.value,
      color: Colors.purple,
    );
  }
}

class _ListenerCard extends StatelessWidget {
  const _ListenerCard({
    required this.title,
    required this.field,
    required this.value,
    required this.rebuildCount,
    required this.color,
  });

  final String title;
  final String field;
  final String value;
  final int rebuildCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Listening to: $field',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Value: $value',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Rebuilds: $rebuildCount',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo form fields schema
enum DemoFields<T> implements FieldSchema {
  firstName<String>(),
  lastName<String>(),
  age<String>();

  const DemoFields({this.validators});

  @override
  final List<Validator<T>>? validators;
}
