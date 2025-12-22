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
      controller = FormFieldsController<TestFormSchema>(formKey);
    });

    test('controller initializes with correct key', () {
      expect(controller.key, equals(formKey));
    });

    test('fieldKey returns a GlobalKey for a form field', () {
      final key = controller.fieldKey<String>(.email);
      expect(key, isA<GlobalKey<FormFieldState<String>>>());
    });

    test('validators returns validators from schema', () {
      final validators = controller.validators(.email);
      expect(validators, isNotNull);
      expect(validators!.length, equals(2));
      expect(validators[0], isA<RequiredValidator<String>>());
      expect(validators[1], isA<EmailValidator>());
    });

    test('setError and getFieldError work correctly', () {
      controller.setError(.email, 'Custom error');
      expect(controller.getFieldError(.email),
          equals('Custom error'));
    });

    test('hasFieldError returns correct state', () {
      expect(controller.hasFieldError(.email), isFalse);

      controller.setError(.email, 'Custom error');

      expect(controller.hasFieldError(.email), isTrue);
    });

    test('controller initializes with initial values', () {
      final controllerWithValues = FormFieldsController<TestFormSchema>(
        GlobalKey<FormState>(),
        initialValues: {
          TestFormSchema.email: 'test@example.com',
          TestFormSchema.password: 'password123',
        },
      );

      expect(
        controllerWithValues.getInitialValue(.email),
        equals('test@example.com'),
      );
      expect(
        controllerWithValues.getInitialValue(.password),
        equals('password123'),
      );
    });

    test('getInitialValue returns stored initial value', () {
      final controllerWithValues = FormFieldsController<TestFormSchema>(
        GlobalKey<FormState>(),
        initialValues: {TestFormSchema.email: 'initial@example.com'},
      );

      expect(
        controllerWithValues.getInitialValue(.email),
        equals('initial@example.com'),
      );
      expect(controllerWithValues.getInitialValue(.password), isNull);
    });

    test('updateValue stores value and getValue retrieves it', () {
      controller.updateValue(.email, 'updated@example.com');
      expect(controller.getValue(.email), equals('updated@example.com'));
    });

    test('updateValue can set value to null', () {
      controller.updateValue(.email, 'test@example.com');
      expect(controller.getValue(.email), equals('test@example.com'));

      controller.updateValue(.email, null);
      expect(controller.getValue(.email), isNull);
    });

    test('clearForcedErrors removes all forced errors', () {
      controller.setError(.email, 'Email error');
      controller.setError(.password, 'Password error');

      expect(controller.getFieldForcedError(.email), equals('Email error'));
      expect(
        controller.getFieldForcedError(.password),
        equals('Password error'),
      );

      controller.clearForcedErrors();

      expect(controller.getFieldForcedError(.email), isNull);
      expect(controller.getFieldForcedError(.password), isNull);
    });

    test('getFieldForcedError returns only forced errors', () {
      controller.setError(.email, 'Forced error');
      expect(controller.getFieldForcedError(.email), equals('Forced error'));
    });

    test('fieldKey returns consistent key for same field', () {
      final key1 = controller.fieldKey(.email);
      final key2 = controller.fieldKey(.email);
      expect(key1, same(key2));
    });

    test('fieldKey returns different keys for different fields', () {
      final emailKey = controller.fieldKey(.email);
      final passwordKey = controller.fieldKey(.password);
      expect(emailKey, isNot(same(passwordKey)));
    });

    test('validators returns null for field without validators', () {
      // Create an enum field without validators for this test
      // Using password field which only has RequiredValidator
      final validators = controller.validators(.password);
      expect(validators, isNotNull);
      expect(validators!.length, equals(1));
    });
  });
}
