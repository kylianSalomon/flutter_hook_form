import 'package:flutter_hook_form/flutter_hook_form.dart';

class TestFormSchema extends FormSchema {
  TestFormSchema()
      : super(
          fields: {
            const FormFieldScheme<String>(email, validators: [
              RequiredValidator<String>(),
              EmailValidator(),
            ]),
            const FormFieldScheme<String>(password, validators: [
              RequiredValidator<String>(),
            ]),
          },
        );

  static const email = HookedFieldId<TestFormSchema, String>('email');
  static const password = HookedFieldId<TestFormSchema, String>('password');
}
