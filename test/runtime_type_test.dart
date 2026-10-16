import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/test_form_schema.dart';

enum _AgeField { age }

void main() {
  test('getNotifier on a field without value exposes null', () {
    final controller = FormFieldsController<TestFormSchema>(
      GlobalKey<FormState>(),
    );

    expect(controller.getNotifier<String>(.email).value, isNull);
  });

  testWidgets('an empty HookedFormField builds', (tester) async {
    final controller = FormFieldsController<TestFormSchema>(
      GlobalKey<FormState>(),
      validators: {.email: .required<String>()},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HookedForm(
            form: controller,
            child: HookedFormField<String, TestFormSchema>(
              fieldHook: .email,
              builder: (value, onChanged, error) => Text('value=$value'),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('value=null'), findsOneWidget);
  });

  testWidgets('a cross-field validator runs through form validation', (
    tester,
  ) async {
    final controller = FormFieldsController<TestFormSchema>(
      GlobalKey<FormState>(),
      validators: {
        .email: .required<String>().initWith('a'),
        .password: .required<String>()
            .matcheField(TestFormSchema.email)
            .initWith('b'),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HookedForm(
            form: controller,
            child: const Column(
              children: [
                HookedTextFormField<TestFormSchema>(fieldHook: .email),
                HookedTextFormField<TestFormSchema>(fieldHook: .password),
              ],
            ),
          ),
        ),
      ),
    );

    expect(controller.validate(), isFalse);
    expect(tester.takeException(), isNull);
    expect(controller.getFieldError(.password), isNotNull);
  });

  test('an optional field accepts an empty value', () {
    final optional = FieldConfig.optional<String>().validators.single
        as FieldValidator<String>;

    expect(optional.validator(null), isNull);
  });

  test('num validators keep the field type on FieldConfig<int>', () {
    final FieldConfig<int> config = FieldConfig.required<int>()
        .min(1)
        .max(10)
        .range(1, 10);

    final range = config.validators.last as FieldValidator<int>;
    expect(range.validator(42), isNotNull);
    expect(range.validator(5), isNull);
  });

  testWidgets('a range-validated int field validates', (tester) async {
    final controller = FormFieldsController<_AgeField>(
      GlobalKey<FormState>(),
      validators: {.age: .required<int>().range(18, 99).initWith(12)},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HookedForm(
            form: controller,
            child: HookedFormField<int, _AgeField>(
              fieldHook: .age,
              builder: (value, onChanged, error) => Text('error=$error'),
            ),
          ),
        ),
      ),
    );

    expect(controller.validate(), isFalse);
    expect(tester.takeException(), isNull);
  });
}
