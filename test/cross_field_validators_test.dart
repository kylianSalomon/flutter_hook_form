import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrossFieldValidator', () {
    group('DateAfterValidator', () {
      testWidgets('returns null when value is null', (tester) async {
        final controller = FormFieldsController<_DateFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {
            _DateFormSchema.startDate: DateTime(2024, 1, 1),
          },
        );

        final validator = const DateAfterValidator(
          field: _DateFormSchema.startDate,
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator(null, context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, isNull);
      });

      testWidgets('returns null when value is after the compared field', (
        tester,
      ) async {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 15);

        final controller = FormFieldsController<_DateFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {_DateFormSchema.startDate: startDate},
        );

        final validator = const DateAfterValidator(
          field: _DateFormSchema.startDate,
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator(endDate, context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, isNull);
      });

      testWidgets('returns error when value is before the compared field', (
        tester,
      ) async {
        final startDate = DateTime(2024, 1, 15);
        final endDate = DateTime(2024, 1, 1);

        final controller = FormFieldsController<_DateFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {.startDate: startDate},
        );

        final validator = const DateAfterValidator(
          field: _DateFormSchema.startDate,
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator(endDate, context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, 'date_after');
      });

      testWidgets('returns custom message when provided', (tester) async {
        final startDate = DateTime(2024, 1, 15);
        final endDate = DateTime(2024, 1, 1);

        final controller = FormFieldsController<_DateFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {_DateFormSchema.startDate: startDate},
        );

        final validator = const DateAfterValidator(
          field: _DateFormSchema.startDate,
          message: 'End date must be after start date',
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator(endDate, context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, 'End date must be after start date');
      });

      testWidgets('returns null when compared field value is null', (
        tester,
      ) async {
        final endDate = DateTime(2024, 1, 1);

        final controller = FormFieldsController<_DateFormSchema>(
          GlobalKey<FormState>(),
        );

        final validator = const DateAfterValidator(
          field: _DateFormSchema.startDate,
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator(endDate, context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, isNull);
      });
    });

    group('MatchesValidator', () {
      testWidgets('returns null when values match', (tester) async {
        final controller = FormFieldsController<_PasswordFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {.password: 'secret123'},
        );

        final validator = const MatchesValidator<String, _PasswordFormSchema>(
          field: .password,
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator('secret123', context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, isNull);
      });

      testWidgets('returns error when values do not match', (tester) async {
        final controller = FormFieldsController<_PasswordFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {.password: 'secret123'},
        );

        final validator = const MatchesValidator<String, _PasswordFormSchema>(
          field: .password,
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator('different', context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, 'field_does_not_match');
      });

      testWidgets('returns custom message when provided', (tester) async {
        final controller = FormFieldsController<_PasswordFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {.password: 'secret123'},
        );

        final validator = const MatchesValidator<String, _PasswordFormSchema>(
          field: .password,
          message: 'Passwords must match',
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator('different', context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(result, 'Passwords must match');
      });

      testWidgets('returns error when both values are null', (tester) async {
        final controller = FormFieldsController<_PasswordFormSchema>(
          GlobalKey<FormState>(),
        );

        final validator = const MatchesValidator<String, _PasswordFormSchema>(
          field: .password,
        ).validator;

        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  result = validator(null, context);
                  return Container();
                },
              ),
            ),
          ),
        );

        // null == null, so should pass
        expect(result, isNull);
      });

      testWidgets('works with non-string types', (tester) async {
        final controller = FormFieldsController<_NumberFormSchema>(
          GlobalKey<FormState>(),
          initialValues: {_NumberFormSchema.firstNumber: 42},
        );

        final validator = const MatchesValidator<int, _NumberFormSchema>(
          field: _NumberFormSchema.firstNumber,
        ).validator;

        String? matchResult;
        String? noMatchResult;

        await tester.pumpWidget(
          MaterialApp(
            home: HookedForm(
              form: controller,
              child: HookBuilder(
                builder: (context) {
                  matchResult = validator(42, context);
                  noMatchResult = validator(99, context);
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(matchResult, isNull);
        expect(noMatchResult, 'field_does_not_match');
      });
    });
  });
}

enum _DateFormSchema {
  startDate,
  // (validators: [DateAfterValidator(field: startDate)]);
  // ignore: unused_field
  endDate,
}

enum _PasswordFormSchema {
  password,
  // ignore: unused_field
  confirmPassword,
}

enum _NumberFormSchema {
  firstNumber,
  // ignore: unused_field
  secondNumber,
}
