import 'package:dartnative/dartnative.dart';

import '../hooks/use_form_context.dart';
import '../models/form_field_controller.dart';
import '../models/validation_mode.dart';
import '../validators/validators.dart';
import 'form_field.dart';
import 'hooked_form.dart';

/// A text form field that integrates with flutter_hook_form.
///
/// DartNative has no `TextFormField`: this widget builds a [TextField] and
/// shows the error below it, styled with [errorStyle]. Its options are the
/// ones of DartNative's [TextField].
class HookedTextFormField<E extends Enum> extends StatefulWidget {
  /// Creates a [HookedTextFormField] that gets the form from context.
  ///
  /// Use the recommended [HookedForm] to wrap your form to provide the form
  /// controller to this widget. If not, use [HookedTextFormField.explicit] to
  /// provide the form controller explicitly.
  ///
  /// ```dart
  /// HookedForm(
  ///   form: form,
  ///   child: HookedTextFormField<MyFormSchema>(
  ///     fieldHook: MyFormSchema.email,
  ///   ),
  /// )
  /// ```
  const HookedTextFormField({
    super.key,
    required this.fieldHook,
    this.forceErrorText,
    this.validator,
    this.validateOn,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.notifyOnChange = true,
    this.errorStyle,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.autocorrect = true,
    this.autofocus = false,
    this.readOnly = false,
    this.cursorColor,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.buildCounter,
  }) : _form = null;

  /// Creates a [HookedTextFormField] with an explicitly provided form.
  const HookedTextFormField.explicit({
    super.key,
    required this.fieldHook,
    required FormFieldsController<E> form,
    this.forceErrorText,
    this.validator,
    this.validateOn,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.notifyOnChange = true,
    this.errorStyle,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.autocorrect = true,
    this.autofocus = false,
    this.readOnly = false,
    this.cursorColor,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.buildCounter,
  }) // Dart 3.12 has no private named parameters (`this._form`).
    // ignore: prefer_initializing_formals
    : _form = form;

  /// The form controller, if provided directly.
  final FormFieldsController<E>? _form;

  /// The field identifier from the form schema.
  final E fieldHook;

  /// Optional error text to force the field into an error state.
  final String? forceErrorText;

  /// Optional validator function that overrides the form's validators.
  final String? Function(String?)? validator;

  /// When the field validates itself. Overrides the field's
  /// `FieldConfig.validateOn` and the form's `validateOn`.
  final ValidationMode? validateOn;

  /// Whether the field is enabled.
  final bool enabled;

  /// Initial value, used when the form gives none and [controller] is
  /// `null`.
  final String? initialValue;

  /// Callback when the form is saved.
  final void Function(String?)? onSaved;

  /// Whether to notify form listeners when the field value changes.
  ///
  /// Defaults to `true`. Required for [FormFieldsController.listen] to react
  /// to this field's changes.
  final bool notifyOnChange;

  /// The style of the error shown below the field.
  final TextStyle? errorStyle;

  /// See [TextField.controller]. Created and disposed by the widget when
  /// `null`.
  final TextEditingController? controller;

  /// See [TextField.focusNode]. Registered with
  /// [FormFieldsController.focusNodeFor] for focus-on-invalid.
  final FocusNode? focusNode;

  /// See [TextField.decoration].
  final InputDecoration? decoration;

  /// See [TextField.keyboardType].
  final TextInputType keyboardType;

  /// See [TextField.textInputAction].
  final TextInputAction? textInputAction;

  /// See [TextField.textCapitalization].
  final TextCapitalization textCapitalization;

  /// See [TextField.style].
  final TextStyle? style;

  /// See [TextField.textAlign].
  final TextAlign textAlign;

  /// See [TextField.textAlignVertical].
  final TextAlignVertical? textAlignVertical;

  /// See [TextField.maxLines].
  final int? maxLines;

  /// See [TextField.minLines].
  final int? minLines;

  /// See [TextField.maxLength].
  final int? maxLength;

  /// See [TextField.inputFormatters].
  final List<TextInputFormatter>? inputFormatters;

  /// See [TextField.autofillHints].
  final List<String>? autofillHints;

  /// See [TextField.obscureText].
  final bool obscureText;

  /// See [TextField.autocorrect].
  final bool autocorrect;

  /// See [TextField.autofocus].
  final bool autofocus;

  /// See [TextField.readOnly].
  final bool readOnly;

  /// See [TextField.cursorColor].
  final Color? cursorColor;

  /// See [TextField.onChanged].
  final ValueChanged<String>? onChanged;

  /// See [TextField.onSubmitted].
  final void Function(String)? onFieldSubmitted;

  /// See [TextField.onTap].
  final VoidCallback? onTap;

  /// See [TextField.onEditingComplete].
  final VoidCallback? onEditingComplete;

  /// See [TextField.buildCounter].
  final Widget? Function(
    BuildContext, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  })?
  buildCounter;

  @override
  State<HookedTextFormField<E>> createState() => _HookedTextFormFieldState<E>();
}

class _HookedTextFormFieldState<E extends Enum>
    extends State<HookedTextFormField<E>> {
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget._form ?? useFormContext<E>(context);
    final field = widget.fieldHook;
    final focusNode = form.focusNodeFor(field, external: widget.focusNode);

    return FormField<String>(
      key: form.fieldKey(field),
      validator:
          widget.validator ??
          (value) {
            final forcedError = form.getFieldForcedError(field);
            if (forcedError != null) {
              return forcedError.localize(context, form.getNotifier(field));
            }
            return form
                .validators(field)
                ?.resolveMessage<String>(context)
                ?.call(value);
          },
      forceErrorText: widget.forceErrorText,
      validationMode: widget.validateOn ?? form.validationModeOf(field),
      validateOnMount: form.getFieldForcedError(field) != null,
      enabled: widget.enabled,
      initialValue:
          widget.controller?.text ??
          form.getInitialValue<String>(field) ??
          widget.initialValue,
      onSaved: widget.onSaved,
      focusNode: focusNode,
      builder: (state) {
        // Text flows Dart → native only: follow the field's value, set by the
        // user, `form.updateValue` or `form.reset`.
        final text = state.value ?? '';
        if (_controller.text != text) {
          _controller.text = text;
        }
        final error = form.getFieldForcedError(field) ?? state.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              focusNode: focusNode,
              decoration: widget.decoration,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              style: widget.style,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              obscureText: widget.obscureText,
              autocorrect: widget.autocorrect,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              cursorColor: widget.cursorColor,
              onChanged: (value) {
                _controller.text = value;
                widget.onChanged?.call(value);
                form.updateValue(field, value, notify: widget.notifyOnChange);
              },
              onSubmitted: widget.onFieldSubmitted,
              onTap: widget.onTap,
              onEditingComplete: widget.onEditingComplete,
              buildCounter: widget.buildCounter,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  error,
                  style:
                      widget.errorStyle ??
                      const TextStyle(color: Color(0xFFB3261E), fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
