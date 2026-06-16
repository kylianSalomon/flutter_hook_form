import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';

/// The builder function receives a map with the following parameters:
/// - `value`: The current value of the field.
/// - `onChanged`: A function to update the value of the field.
/// - `error`: The error message of the field.
typedef HookedFormBuilderFn<T> = Widget Function(
  T? value,
  void Function(T?)? onChanged,
  String? error,
);

/// A form field that integrates with flutter_hook_form.
class const HookedFormField<T, F extends FieldSchema<T>>({
  super.key,

  /// The form controller, if provided directly.
  final FormFieldsController<FieldSchema<dynamic>>? _form,

  /// The field identifier from the form schema.
  required final F fieldHook,

  /// Builder function to create the form field widget.
  required final HookedFormBuilderFn<T> builder,

  /// Optional error text to force the field into an error state.
  final String? forceErrorText,

  /// Optional validator function that overrides the form's validators.
  final String? Function(T?)? validator,

  /// Controls when auto-validation occurs.
  final AutovalidateMode? autovalidateMode,

  /// Whether the field is enabled.
  final bool enabled = true,

  /// Initial value for the field.
  final T? initialValue,

  /// Callback when the form is saved.
  final void Function(T?)? onSaved,

  /// Restoration ID for saving and restoring the field state.
  final String? restorationId,

  /// Whether to notify form listeners when the field value changes.
  ///
  /// Defaults to `true`. Required for [FormFieldsController.listen] to react
  /// to this field's changes. Set to `false` only if you need to suppress
  /// reactive updates for performance reasons.
  final bool notifyOnChange = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FormFieldsController<FieldSchema<dynamic>> form =
        _form ?? useFormContext(context);
    final typedField = fieldHook as FieldSchema<T>;

    return FormField<T>(
      key: form.fieldKey(typedField),
      validator:
          validator ?? form.validators(fieldHook)?.resolveMessage<T>(context),
      forceErrorText:
          forceErrorText ??
          form
              .getFieldForcedError(fieldHook)
              .localize(context, form.getNotifier(typedField)),
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      initialValue: form.getInitialValue(typedField) ?? initialValue,
      onSaved: onSaved,
      restorationId: restorationId,
      builder: (_) {
        return builder(form.getNotifier(typedField).value, (value) {
          form.updateValue(typedField, value, notify: notifyOnChange);
        }, form.getFieldError(fieldHook));
      },
    );
  }
}
