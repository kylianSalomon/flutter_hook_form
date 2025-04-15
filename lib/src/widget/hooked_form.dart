import 'package:flutter/material.dart';

import '../hooks/use_form_context.dart';
import '../models/form_field_controller.dart';
import '../models/form_schema.dart';

/// A form that integrates with flutter_hook_form.
///
/// This widget wraps a standard [Form] and connects it to a [FormFieldsController].
/// It also provides a [FormFieldsController] to its children via [FormProvider].
class HookedForm<F extends FormSchema> extends StatelessWidget {
  /// Creates a [HookedForm] that gets the form from context.
  const HookedForm({
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
    return Form(
      key: form.key,
      child: HookedFormProvider(
        form: form,
        child: child,
      ),
    );
  }
}
