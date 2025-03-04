import 'package:flutter/widgets.dart';

import '../models/form_field_controller.dart';
import '../models/form_schema.dart';

class FormProvider<F extends FormSchema>
    extends InheritedNotifier<FormFieldsController<F>> {
  const FormProvider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static FormFieldsController<F> _of<F extends FormSchema>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<FormProvider<F>>()!
        .notifier!;
  }
}

FormFieldsController<F> useFormContext<F extends FormSchema>(
  BuildContext context,
) {
  return FormProvider._of<F>(context);
}
