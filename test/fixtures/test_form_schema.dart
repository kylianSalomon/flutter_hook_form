import 'package:flutter_hook_form/flutter_hook_form.dart';

class TestFormSchema extends FormSchema {
  const TestFormSchema();

  static final email = HookField<TestFormSchema, String>(
    validators: [const RequiredValidator<String>(), const EmailValidator()],
  );

  static final password = HookField<TestFormSchema, String>(
    validators: [const RequiredValidator<String>()],
  );

  @override
  Set<HookField<FormSchema, dynamic>> get fields => {email, password};
}
