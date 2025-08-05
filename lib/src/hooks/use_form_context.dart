import 'package:flutter/widgets.dart';

import '../models/form_field_controller.dart';
import '../models/form_schema.dart';

/// A provider that provides a [FormFieldsController] to the form fields.
///
/// Wrap your widget with a [HookedFormProvider] to access the [FormFieldsController].
/// Be careful to use [useFormContext] to access a provided [FormFieldsController]
/// and not the [useForm] that is used to create the [FormFieldsController].
///
/// If the generated form is not in the same context, (due to a navigation for
/// instance), you can provide it on top on the widget tree with
/// a [HookedFormProvider].
class HookedFormProvider<F extends FormSchema>
    extends InheritedNotifier<FormFieldsController<F>> {
  /// Creates a [HookedFormProvider].
  const HookedFormProvider({
    super.key,
    required super.child,
    required FormFieldsController<F> form,
  }) : super(notifier: form);

  static FormFieldsController<F> _of<F extends FormSchema>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<HookedFormProvider<F>>()!
        .notifier!;
  }
}

/// A hook that provides a [FormFieldsController] to the form fields.
///
/// Use this hook to access the [FormFieldsController] from the [HookedFormProvider].
/// DO NOT use this hook to create a [FormFieldsController], please see
/// [useForm] instead.
FormFieldsController<F> useFormContext<F extends FormSchema>(
  BuildContext context,
) {
  return HookedFormProvider._of<F>(context);
}
