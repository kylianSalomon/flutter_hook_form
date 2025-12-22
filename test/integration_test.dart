import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/test_form_schema.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('complete form submission flow', (tester) async {
      bool formSubmitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>(
                initialValues: {
                  TestFormSchema.email: 'test@example.com',
                  TestFormSchema.password: 'password123',
                },
              );

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const HookedTextFormField(
                          fieldHook: TestFormSchema.email,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        const HookedTextFormField(
                          fieldHook: TestFormSchema.password,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (form.validate()) {
                              formSubmitted = true;
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Enter valid data
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Check form was submitted
      expect(formSubmitted, isTrue);

      // Reset test
      formSubmitted = false;

      // Enter invalid data
      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');

      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Check form was not submitted
      expect(formSubmitted, isFalse);

      // Check for error message
      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('form reset functionality', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const HookedTextFormField<TestFormSchema>(
                          fieldHook: .email,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        const HookedTextFormField<TestFormSchema>(
                          fieldHook: .password,
                          decoration: InputDecoration(labelText: 'Password'),
                        ),
                        ElevatedButton(
                          onPressed: () => form.reset(),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Enter data
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pump();

      // Verify text is entered
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      // Reset form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify fields are cleared
      expect(find.text('test@example.com'), findsNothing);
      expect(find.text('password123'), findsNothing);
    });

    testWidgets('auto validation modes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: const SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          autovalidateMode: .onUserInteraction,
                          fieldHook: .email,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'not-an-email');

      // Unfocus the field to trigger validation
      await tester.tap(find.byType(SingleChildScrollView));
      await tester.pump();

      // Check for error message without explicit validation call
      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('custom validator overrides schema validator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>(
                initialValues: {
                  TestFormSchema.email: 'test@example.com',
                  TestFormSchema.password: 'password123',
                },
              );

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: .email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (_) => 'Custom error message',
                        ),
                        ElevatedButton(
                          onPressed: () => form.validate(),
                          child: const Text('Validate'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Tap validate button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Check for custom error message instead of schema validator message
      expect(find.text('Custom error message'), findsOneWidget);
      expect(find.text('Invalid email address'), findsNothing);
    });

    testWidgets('form values are accessible via controller', (tester) async {
      late FormFieldsController<TestFormSchema> formController;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>(
                initialValues: {
                  TestFormSchema.email: 'test@example.com',
                  TestFormSchema.password: 'password123',
                },
              );
              formController = form;

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: const SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: .email,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: .password,
                          decoration: InputDecoration(labelText: 'Password'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Enter data
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pump();

      // Verify values are accessible via controller
      expect(formController.getValue(.email), equals('test@example.com'));
      expect(formController.getValue(.password), equals('password123'));
    });

    testWidgets('updateValue programmatically updates form values', (
      tester,
    ) async {
      late FormFieldsController<TestFormSchema> formController;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();
              formController = form;

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: Column(
                    children: [
                      const HookedTextFormField<TestFormSchema>(
                        fieldHook: .email,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          form.updateValue(.email, 'programmatic@example.com');
                        },
                        child: const Text('Set Value'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initially empty (TextFormField shows empty string, not null)
      expect(
        formController.getValue(.email), anyOf(isNull, isEmpty));

      // Set value programmatically
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Check value is updated
      expect(
        formController.getValue(.email),
        equals('programmatic@example.com'),
      );
    });

    testWidgets('hasBeenInteracted returns true after user interaction', (
      tester,
    ) async {
      late FormFieldsController<TestFormSchema> formController;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();
              formController = form;

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: const Column(
                    children: [
                      HookedTextFormField<TestFormSchema>(
                        fieldHook: .email,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initially no interaction
      expect(formController.hasBeenInteracted, isFalse);

      // Interact with the field
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();

      // Now should be marked as interacted
      expect(formController.hasBeenInteracted, isTrue);
    });

    testWidgets('validateField validates a single field', (tester) async {
      late FormFieldsController<TestFormSchema> formController;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();
              formController = form;

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: const Column(
                    children: [
                      HookedTextFormField<TestFormSchema>(
                        fieldHook: .email,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      HookedTextFormField<TestFormSchema>(
                        fieldHook: .password,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Enter invalid email but valid password
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pump();

      // Validate only email field
      final isEmailValid = formController.validateField(.email);
      await tester.pump();

      expect(isEmailValid, isFalse);
      expect(find.text('Invalid email address'), findsOneWidget);

      // Password should not show error since we only validated email
      expect(find.text('required'), findsNothing);
    });

    testWidgets('form clears forced errors after validation', (tester) async {
      late FormFieldsController<TestFormSchema> formController;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();
              formController = form;

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: Column(
                    children: [
                      const HookedTextFormField<TestFormSchema>(
                        fieldHook: .email,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      ElevatedButton(
                        onPressed: () => form.validate(),
                        child: const Text('Validate'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Set a forced error
      formController.setError(.email, 'Server error');
      await tester.pump();

      expect(
        formController.getFieldForcedError(.email),
        equals('Server error'),
      );

      // Validate clears forced errors by default
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(formController.getFieldForcedError(.email), isNull);
    });

    testWidgets('useForm with initial values populates form fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>(
                initialValues: {.email: 'prefilled@example.com'},
              );

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: const Column(
                    children: [
                      HookedTextFormField<TestFormSchema>(
                        fieldHook: .email,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Check that initial value is displayed
      expect(find.text('prefilled@example.com'), findsOneWidget);
    });

    testWidgets('getValues returns map of all form field values', (
      tester,
    ) async {
      late FormFieldsController<TestFormSchema> formController;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();
              formController = form;

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: const SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: .email,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: .password,
                          decoration: InputDecoration(labelText: 'Password'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Enter values
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tester.pump();

      // Get all values
      final values = formController.getValues();

      expect(values[TestFormSchema.email], equals('test@example.com'));
      expect(values[TestFormSchema.password], equals('secret123'));
    });

    testWidgets('notifyListeners is called after setError', (tester) async {
      late FormFieldsController<TestFormSchema> formController;
      int notifyCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final form = useForm<TestFormSchema>();
              formController = form;
              form.addListener(() {
                notifyCount++;
              });

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: const Column(
                    children: [
                      HookedTextFormField<TestFormSchema>(
                        fieldHook: .email,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      final initialNotifyCount = notifyCount;

      // Set error should trigger notification
      formController.setError(.email, 'Server error');
      await tester.pump();

      expect(notifyCount, greaterThan(initialNotifyCount));
    });
  });
}
