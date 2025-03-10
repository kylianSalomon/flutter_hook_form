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
          const RequiredValidator<String>(message: 'Custom message').validator;
      final intValidator = const RequiredValidator<int>().validator;
      final listValidator = const RequiredValidator<List>().validator;
      final dateValidator = const RequiredValidator<DateTime>().validator;

      // String tests
      expect(stringValidator(null), isNotNull);
      expect(stringValidator(''), isNull);
      expect(stringValidator('test'), isNull);
      expect(stringValidator2(null), 'Custom message');

      // Int tests
      expect(intValidator(null), isNotNull);
      expect(intValidator(0), isNull);
      expect(intValidator(42), isNull);

      // List tests
      expect(listValidator(null), isNotNull);
      expect(listValidator([]), isNull);
      expect(listValidator(['test']), isNull);

      // DateTime tests
      final date = DateTime.now();
      expect(dateValidator(null), isNotNull);
      expect(dateValidator(date), isNull);
    });
  });

  group('String Validators', () {
    test('min length validator', () {
      final validator = const MinLengthValidator(3).validator;
      final validator2 =
          const MinLengthValidator(3, message: 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('ab'), isNotNull);
      expect(validator2('ab'), 'Custom message');
      expect(validator('abc'), isNull);
      expect(validator('abcd'), isNull);
    });

    test('max length validator', () {
      final validator = const MaxLengthValidator(3).validator;
      final validator2 =
          const MaxLengthValidator(3, message: 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('ab'), isNull);
      expect(validator('abc'), isNull);
      expect(validator('abcd'), isNotNull);
      expect(validator2('abcd'), 'Custom message');
    });

    test('email validator', () {
      final validator = const EmailValidator().validator;
      final validator2 =
          const EmailValidator(message: 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('not-an-email'), isNotNull);
      expect(validator2('not-an-email'), 'Custom message');
      expect(validator('test@example'), isNotNull);
      expect(validator2('test@example'), 'Custom message');
      expect(validator('test@example.com'), isNull);
    });

    test('phone validator', () {
      final validator = const PhoneValidator().validator;
      final validator2 =
          const PhoneValidator(message: 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator('123'), isNotNull);
      expect(validator('123456789'), isNull);
      expect(validator('+123456789'), isNull);
      expect(validator2('123'), 'Custom message');
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
      expect(validator(yesterday), isNotNull);
      expect(validator2(yesterday), 'Custom message');
      expect(validator(tomorrow), isNull);
    });

    test('isBefore validator', () {
      final validator = DateTimeValidator.isBefore(now).validator;
      final validator2 =
          DateTimeValidator.isBefore(now, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator(tomorrow), isNotNull);
      expect(validator(yesterday), isNull);
      expect(validator2(tomorrow), 'Custom message');
    });
  });

  group('List Validators', () {
    test('minItems validator', () {
      final validator = ListValidator.minItems(2).validator;
      final validator2 = ListValidator.minItems(2, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator(['one']), isNotNull);
      expect(validator2(['one']), 'Custom message');
      expect(validator(['one', 'two']), isNull);
      expect(validator(['one', 'two', 'three']), isNull);
    });

    test('maxItems validator', () {
      final validator = ListValidator.maxItems(2).validator;
      final validator2 = ListValidator.maxItems(2, 'Custom message').validator;

      _expectNullOnNullValue(validator, context);
      expect(validator(['one']), isNull);
      expect(validator(['one', 'two']), isNull);
      expect(validator(['one', 'two', 'three']), isNotNull);
      expect(validator2(['one', 'two', 'three']), 'Custom message');
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
      expect(validator(jpegFile), isNull);
      expect(
        validator(pdfFile),
        HookFormScope.of(context).invalidFileFormat(
          {'image/jpeg', 'image/png'},
        ),
      );
      expect(validator2(pdfFile), 'Custom message');
    });
  });
}

/// Helper function to expect no errors on null value
void _expectNullOnNullValue<T>(ValidatorFn<T> validator, BuildContext context) {
  expect(validator(null), isNull);
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
