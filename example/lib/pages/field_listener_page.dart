import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Demonstrates granular field listening with [FormFieldsController.listen].
///
/// This example shows how widgets can listen to specific fields and only
/// rebuild when those fields change, improving performance.
class const FieldListenerPage({super.key}) extends HookWidget {
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
                      'Each card below listens to a specific field using form.listen. '
                      'The rebuild counter shows how many times each widget has rebuilt. '
                      'Notice that only the relevant card rebuilds when you type!',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            HookedForm(
              form: form,
              child: Column(
                children: [
                  HookedTextFormField<DemoFields<String>>(
                    fieldHook: DemoFields.firstName,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  HookedTextFormField<DemoFields<String>>(
                    fieldHook: DemoFields.lastName,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  HookedTextFormField<DemoFields<String>>(
                    fieldHook: DemoFields.age,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
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
class const _FirstNameListener({
  required final FormFieldsController<DemoFields> form,
}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Track rebuilds
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    // Listen to firstName only
    final firstName = form.listen({
      DemoFields.firstName,
    }, (get) => get<String>(DemoFields.firstName));

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
class const _LastNameListener({
  required final FormFieldsController<DemoFields> form,
}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    final lastName = form.listen({
      DemoFields.lastName,
    }, (get) => get<String>(DemoFields.lastName));

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
class const _AgeListener({
  required final FormFieldsController<DemoFields> form,
}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    final age = form.listen({
      DemoFields.age,
    }, (get) => get<String>(DemoFields.age));

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
class const _FullNameListener({
  required final FormFieldsController<DemoFields> form,
}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final rebuildCount = useRef(0);
    rebuildCount.value++;

    // Listen to multiple fields and combine into a single derived value
    final fullName = form.listen(
      {DemoFields.firstName, DemoFields.lastName},
      (get) => [
        get<String>(DemoFields.firstName),
        get<String>(DemoFields.lastName),
      ].where((s) => s != null && s.isNotEmpty).join(' '),
    );

    return _ListenerCard(
      title: 'Full Name Listener',
      field: 'firstName + lastName',
      value: fullName.isEmpty ? '(empty)' : fullName,
      rebuildCount: rebuildCount.value,
      color: Colors.purple,
    );
  }
}

class const _ListenerCard({
  required final String title,
  required final String field,
  required final String value,
  required final int rebuildCount,
  required final Color color,
}) extends StatelessWidget {
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo form fields schema
enum DemoFields<T>({this.validators}) implements FieldSchema<T> {
  firstName<String>(),
  lastName<String>(),
  age<String>();

  @override
  final List<Validator<T>>? validators;
}
