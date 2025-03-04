import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/hooks/hooks.dart';

import '../models/form_field_controller.dart';
import '../models/form_schema.dart';

/// A provider that provides a [FormFieldsController] to the form fields.
///
/// Wrap your widget with a [FormProvider] to access the [FormFieldsController].
/// Be careful to use [useFormContext] to access a provided [FormFieldsController]
/// and not the [useForm] that is used to create the [FormFieldsController].
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

/// A hook that provides a [FormFieldsController] to the form fields.
///
/// Use this hook to access the [FormFieldsController] from the [FormProvider].
/// DO NOT use this hook to create a [FormFieldsController], please see
/// [useForm] instead.
FormFieldsController<F> useFormContext<F extends FormSchema>(
  BuildContext context,
) {
  return FormProvider._of<F>(context);
}
