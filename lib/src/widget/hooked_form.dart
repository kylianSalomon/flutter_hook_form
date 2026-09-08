import 'package:flutter/material.dart';

import '../hooks/use_form_context.dart';
import '../models/form_field_controller.dart';

/// A form that integrates with flutter_hook_form.
///
/// This widget wraps a standard [Form] and connects it to a [FormFieldsController].
/// It also provides a [FormFieldsController] to its children via [HookedFormProvider].
// ignore: public_member_api_docs
class const HookedForm<E extends Enum>({
  super.key,

  /// The form controller.
  required final FormFieldsController<E> form,

  /// The child of the form.
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: form.key,
      child: HookedFormProvider<E>(form: form, child: child),
    );
  }
}
