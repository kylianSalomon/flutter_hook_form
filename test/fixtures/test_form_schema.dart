import 'package:flutter_hook_form/flutter_hook_form.dart';

class TestFormSchema extends FormSchema {
  const TestFormSchema();

  static const email = HookField<TestFormSchema, String>(
    'email',
    validators: [
      RequiredValidator<String>(),
      EmailValidator(),
    ],
  );

  static const password = HookField<TestFormSchema, String>(
    'password',
    validators: [
      RequiredValidator<String>(),
    ],
  );

  @override
  Set<HookField<FormSchema, dynamic>> get fields => {email, password};
}
