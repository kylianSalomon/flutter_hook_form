import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BuildContext context;

  setUp(() {
    context = _TestBuildContext();
  });

  group('Common Validators', () {
    test('required validator works with any type', () {
      final stringValidator = const RequiredValidator<String>().validator;
      final stringValidator2 =
          const RequiredValidator<String>('Custom message').validator;
      final intValidator = const RequiredValidator<int>().validator;
      final listValidator = const RequiredValidator<List>().validator;
      final dateValidator = const RequiredValidator<DateTime>().validator;

      // String tests
      expect(stringValidator(null, context), isNotNull);
      expect(stringValidator('', context), isNull);
      expect(stringValidator('test', context), isNull);
      expect(stringValidator2(null, context), 'Custom message');

      // Int tests
      expect(intValidator(null, context), isNotNull);
      expect(intValidator(0, context), isNull);
      expect(intValidator(42, context), isNull);

      // List tests
      expect(listValidator(null, context), isNotNull);
      expect(listValidator([], context), isNull);
      expect(listValidator(['test'], context), isNull);

      // DateTime tests
      final date = DateTime.now();
      expect(dateValidator(null, context), isNotNull);
      expect(dateValidator(date, context), isNull);
    });
  });

  group('String Validators', () {
    test('min length validator', () {
      final validator = const MinLengthValidator(3).validator;
      final validator2 =
          const MinLengthValidator(3, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('ab', context), isNotNull);
      expect(validator2('ab', context), 'Custom message');
      expect(validator('abc', context), isNull);
      expect(validator('abcd', context), isNull);
    });

    test('max length validator', () {
      final validator = const MaxLengthValidator(3).validator;
      final validator2 =
          const MaxLengthValidator(3, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('ab', context), isNull);
      expect(validator('abc', context), isNull);
      expect(validator('abcd', context), isNotNull);
      expect(validator2('abcd', context), 'Custom message');
    });

    test('email validator', () {
      final validator = const EmailValidator().validator;
      final validator2 = const EmailValidator('Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('not-an-email', context), isNotNull);
      expect(validator2('not-an-email', context), 'Custom message');
      expect(validator('test@example', context), isNotNull);
      expect(validator2('test@example', context), 'Custom message');
      expect(validator('test@example.com', context), isNull);
    });

    test('phone validator', () {
      final validator = const PhoneValidator().validator;
      final validator2 = const PhoneValidator('Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('123', context), isNotNull);
      expect(validator('123456789', context), isNull);
      expect(validator('+123456789', context), isNull);
      expect(validator2('123', context), 'Custom message');
    });
  });

  group('DateTime Validators', () {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    test('isAfter validator', () {
      final validator = DateTimeValidator.isAfter(now).validator;
      final validator2 =
          DateTimeValidator.isAfter(now, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator(yesterday, context), isNotNull);
      expect(validator2(yesterday, context), 'Custom message');
      expect(validator(tomorrow, context), isNull);
    });

    test('isBefore validator', () {
      final validator = DateTimeValidator.isBefore(now).validator;
      final validator2 =
          DateTimeValidator.isBefore(now, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator(tomorrow, context), isNotNull);
      expect(validator(yesterday, context), isNull);
      expect(validator2(tomorrow, context), 'Custom message');
    });
  });

  group('List Validators', () {
    test('minItems validator', () {
      final validator = ListValidator.minItems(2).validator;
      final validator2 = ListValidator.minItems(2, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator(['one'], context), isNotNull);
      expect(validator2(['one'], context), 'Custom message');
      expect(validator(['one', 'two'], context), isNull);
      expect(validator(['one', 'two', 'three'], context), isNull);
    });

    test('maxItems validator', () {
      final validator = ListValidator.maxItems(2).validator;
      final validator2 = ListValidator.maxItems(2, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator(['one'], context), isNull);
      expect(validator(['one', 'two'], context), isNull);
      expect(validator(['one', 'two', 'three'], context), isNotNull);
      expect(validator2(['one', 'two', 'three'], context), 'Custom message');
    });
  });

  group('File Validators', () {
    test('format validator', () {
      final validator =
          FileValidator.mimeType({'image/jpeg', 'image/png'}).validator;
      final validator2 = FileValidator.mimeType(
        {'image/jpeg', 'image/png'},
        'Custom message',
      ).validator;
      final jpegFile = XFile('test.jpg', mimeType: 'image/jpeg');
      final pdfFile = XFile('test.pdf', mimeType: 'application/pdf');

      _expectNullOnNullValue(validator, context);
      expect(validator(jpegFile, context), isNull);
      expect(
        validator(pdfFile, context),
        HookFormScope.of(context).invalidFileFormat(
          {'image/jpeg', 'image/png'},
        ),
      );
      expect(validator2(pdfFile, context), 'Custom message');
    });
  });
}

/// Helper function to expect no errors on null value
void _expectNullOnNullValue<T>(ValidatorFn<T> validator, BuildContext context) {
  expect(validator(null, context), isNull);
}

class _TestBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) {
    if (T == HookFormScope) {
      return HookFormScope(
        messages: const FormErrorMessages(),
        child: Container(),
      ) as T;
    }

    throw UnimplementedError('dependOnInheritedWidgetOfExactType<$T>');
  }
}
