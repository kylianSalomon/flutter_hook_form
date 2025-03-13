import 'package:flutter/material.dart';

import '../hooks/use_form_context.dart';
import '../models/form_field_controller.dart';
import '../models/form_schema.dart';
import '../validators/validators.dart';
import 'hooked_form.dart';

/// A form field that integrates with flutter_hook_form.
class HookedFormField<F extends FormSchema, T> extends StatelessWidget {
  /// Creates a [HookedFormField] that gets the form from context.
  ///
  /// This widget wraps a standard [FormField] and connects it to a [FormFieldsController].
  ///
  /// Use the recommended [HookedForm] to wrap your form to provide the form
  /// controller to this widget. If not, use [HookedFormField.explicit] to provide
  /// the form controller explicitly.
  ///
  /// ```dart
  /// /// Recommended
  /// HookedForm( // <--- Form is provided via context
  ///   form: form,
  ///   child: HookedFormField<MyFormSchema, String>(
  ///     fieldKey: MyFormSchema.fieldKey,
  ///     builder: (field) => MyWidget(field: field),
  ///   ),
  /// )
  ///
  /// /// Alternative
  /// Form(
  ///   key: form.key,
  ///   child: HookedFormField.explicit(
  ///     form: form, // <--- Form is provided explicitly
  ///     fieldKey: MyFormSchema.fieldKey,
  ///     builder: (field) => MyWidget(field: field),
  ///   ),
  /// )
  /// ```
  const HookedFormField({
    super.key,
    required this.fieldKey,
    required this.builder,
    this.forceErrorText,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.restorationId,
  }) : _form = null;

  /// Creates a [HookedFormField] with an explicitly provided form.
  ///
  /// Consider using [HookedFormField.explicit] if you did not use [HookedForm] to
  /// wrap your form or use [FormProvider] to provide the form.
  const HookedFormField.explicit({
    super.key,
    required this.fieldKey,
    required this.builder,
    required FormFieldsController<F> form,
    this.forceErrorText,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.restorationId,
  }) : _form = form;

  /// The form controller, if provided directly.
  final FormFieldsController<F>? _form;

  /// The field identifier from the form schema.
  final TypedId<T> fieldKey;

  /// Builder function to create the form field widget.
  final Widget Function(FormFieldState<T>) builder;

  /// Optional error text to force the field into an error state.
  final String? forceErrorText;

  /// Optional validator function that overrides the form's validators.
  final String? Function(T?)? validator;

  /// Controls when auto-validation occurs.
  final AutovalidateMode? autovalidateMode;

  /// Whether the field is enabled.
  final bool enabled;

  /// Initial value for the field.
  final T? initialValue;

  /// Callback when the form is saved.
  final void Function(T?)? onSaved;

  /// Restoration ID for saving and restoring the field state.
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    final form = _form ?? useFormContext<F>(context);

    return FormField<T>(
      key: form.fieldKey(fieldKey),
      validator: validator ?? form.validators(fieldKey)?.localize(context),
      forceErrorText: forceErrorText ?? form.getFieldError(fieldKey),
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      initialValue: initialValue,
      onSaved: onSaved,
      restorationId: restorationId,
      builder: builder,
    );
  }
}
