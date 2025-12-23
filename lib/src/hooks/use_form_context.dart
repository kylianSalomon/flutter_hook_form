import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';

import '../models/form_field_controller.dart';

// Base provider that stores controller without F type parameter
class _HookedFormProviderBase extends InheritedNotifier<FormFieldsController> {
  const _HookedFormProviderBase({
    required super.child,
    required FormFieldsController form,
  }) : super(notifier: form);

  static FormFieldsController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_HookedFormProviderBase>()!
        .notifier!;
  }
}

/// Typed provider wraps the base provider to provide a [FormFieldsController] to the form fields.
class HookedFormProvider<F extends FieldSchema> extends StatelessWidget {
  /// Creates a [HookedFormProvider] that provides a [FormFieldsController] to the form fields.
  const HookedFormProvider({
    super.key,
    required this.form,
    required this.child,
  });

  /// The form controller.
  final FormFieldsController<F> form;

  /// The child of the form.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _HookedFormProviderBase(form: form, child: child);
  }
}

/// A hook that provides a [FormFieldsController] to the form fields.
///
/// Use this hook to access the [FormFieldsController] from the [HookedFormProvider].
/// DO NOT use this hook to create a [FormFieldsController], please see
/// [useForm] instead.
FormFieldsController<F> useFormContext<F extends FieldSchema>(
  BuildContext context,
) {
  return _HookedFormProviderBase.of(context) as FormFieldsController<F>;
}
