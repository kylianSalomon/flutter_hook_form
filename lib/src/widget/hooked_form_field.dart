import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

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
  ///     builder: ({value, onChanged, error}){
  ///       return MyWidget(value: value, onChanged: onChanged, error: error);
  ///     },
  ///   ),
  /// )
  ///
  /// /// Alternative
  /// Form(
  ///   key: form.key,
  ///   child: HookedFormField.explicit(
  ///     form: form, // <--- Form is provided explicitly
  ///     fieldKey: MyFormSchema.fieldKey,
  ///     builder: ({value, onChanged, error}){
  ///       return MyWidget(value: value, onChanged: onChanged, error: error);
  ///     },
  ///   ),
  /// )
  /// ```
  const HookedFormField({
    super.key,
    required this.fieldHook,
    required this.builder,
    this.forceErrorText,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.restorationId,
    this.notifyOnChange = false,
  }) : _form = null;

  /// Creates a [HookedFormField] with an explicitly provided form.
  ///
  /// Consider using [HookedFormField.explicit] if you did not use [HookedForm] to
  /// wrap your form or use [FormProvider] to provide the form.
  const HookedFormField.explicit({
    super.key,
    required this.fieldHook,
    required this.builder,
    required FormFieldsController<F> form,
    this.forceErrorText,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.restorationId,
    this.notifyOnChange = false,
  }) : _form = form;

  /// The form controller, if provided directly.
  final FormFieldsController<F>? _form;

  /// The field identifier from the form schema.
  final HookField<F, T> fieldHook;

  /// Builder function to create the form field widget.
  ///
  /// The builder function receives a map with the following parameters:
  /// - `value`: The current value of the field.
  /// - `onChanged`: A function to update the value of the field.
  /// - `error`: The error message of the field.
  final Widget Function(
    T? value,
    void Function(T?)? onChanged,
    String? error,
  ) builder;

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

  /// Whether to notify form listeners when the field value changes.
  ///
  /// Default to `false` to avoid any unwanted rebuilds.
  final bool notifyOnChange;

  @override
  Widget build(BuildContext context) {
    final form = _form ?? useFormContext<F>(context);

    return FormField<T>(
      key: form.fieldKey(fieldHook),
      validator: validator ?? form.validators(fieldHook)?.localize(context),
      forceErrorText: forceErrorText ??
          form
              .getFieldForcedError(fieldHook)
              .localize(context, form.getValue(fieldHook)),
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      initialValue: form.getInitialValue(fieldHook) ?? initialValue,
      onSaved: onSaved,
      restorationId: restorationId,
      builder: (_) {
        return builder(
          form.getValue(fieldHook),
          (value) => form.updateValue<T>(
            fieldHook,
            value,
            notify: notifyOnChange,
          ),
          form.getFieldError(fieldHook),
        );
      },
    );
  }
}
