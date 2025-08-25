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
              final form = useForm(
                formSchema: const TestFormSchema(),
                initialValues: {
                  TestFormSchema.email.withInitialValue('test@example.com'),
                  TestFormSchema.password.withInitialValue('password123'),
                },
              );

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: TestFormSchema.email,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: TestFormSchema.password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
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
              final form = useForm(formSchema: const TestFormSchema());

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: TestFormSchema.email,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: TestFormSchema.password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
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
              final form = useForm(formSchema: const TestFormSchema());

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          fieldHook: TestFormSchema.email,
                          decoration: const InputDecoration(labelText: 'Email'),
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
              final form = useForm(
                formSchema: const TestFormSchema(),
                initialValues: {
                  TestFormSchema.email.withInitialValue('test@example.com'),
                  TestFormSchema.password.withInitialValue('password123'),
                },
              );

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: TestFormSchema.email,
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
              final form = useForm(
                formSchema: const TestFormSchema(),
                initialValues: {
                  TestFormSchema.email.withInitialValue('test@example.com'),
                  TestFormSchema.password.withInitialValue('password123'),
                },
              );
              formController = form;

              return Scaffold(
                body: HookedForm<TestFormSchema>(
                  form: form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: TestFormSchema.email,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        HookedTextFormField<TestFormSchema>(
                          fieldHook: TestFormSchema.password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
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
      expect(
        formController.getValue(TestFormSchema.email),
        equals('test@example.com'),
      );
      expect(
        formController.getValue(TestFormSchema.password),
        equals('password123'),
      );
    });
  });
}
