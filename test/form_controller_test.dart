import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/test_form_schema.dart';

void main() {
  group('FormFieldsController Tests', () {
    late FormFieldsController<TestFormSchema> controller;
    late GlobalKey<FormState> formKey;

    setUp(() {
      formKey = GlobalKey<FormState>();
      controller = FormFieldsController(
        formKey,
        TestFormSchema(),
      );
    });

    test('controller initializes with correct key', () {
      expect(controller.key, equals(formKey));
    });

    test('fieldKey returns a GlobalKey for a form field', () {
      final key = controller.fieldKey(TestFormSchema.email);
      expect(key, isA<GlobalKey<FormFieldState<String>>>());
    });

    test('validators returns validators from schema', () {
      final validators = controller.validators(TestFormSchema.email);
      expect(validators, isNotNull);
      expect(validators!.length, equals(2));
      expect(validators[0], isA<RequiredValidator<String>>());
      expect(validators[1], isA<EmailValidator>());
    });

    test('setError and getFieldError work correctly', () {
      controller.setError(TestFormSchema.email, 'Custom error');
      expect(controller.getFieldError(TestFormSchema.email),
          equals('Custom error'));
    });

    test('hasFieldError returns correct state', () {
      expect(controller.hasFieldError(TestFormSchema.email), isFalse);

      controller.setError(TestFormSchema.email, 'Custom error');

      expect(controller.hasFieldError(TestFormSchema.email), isTrue);
    });
  });
}
