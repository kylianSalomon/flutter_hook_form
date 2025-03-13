import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/test_form_schema.dart';

void main() {
  group('Form Hooks Tests', () {
    testWidgets('useForm creates and returns a FormFieldsController',
        (tester) async {
      FormFieldsController<TestFormSchema>? capturedController;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              capturedController = useForm(formSchema: TestFormSchema());
              return Container();
            },
          ),
        ),
      );

      expect(capturedController, isNotNull);
      expect(capturedController!.key, isA<GlobalKey<FormState>>());
    });

    testWidgets('useFormContext retrieves controller from context',
        (tester) async {
      final controller = FormFieldsController<TestFormSchema>(
        GlobalKey<FormState>(),
        TestFormSchema(),
      );

      FormFieldsController<TestFormSchema>? capturedController;

      await tester.pumpWidget(
        MaterialApp(
          home: FormProvider<TestFormSchema>(
            notifier: controller,
            child: HookBuilder(
              builder: (context) {
                capturedController = useFormContext<TestFormSchema>(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(capturedController, isNotNull);
      expect(capturedController, equals(controller));
    });
  });
}
