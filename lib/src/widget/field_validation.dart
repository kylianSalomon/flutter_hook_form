import 'package:flutter/widgets.dart';

import '../models/form_field_controller.dart';
import '../models/validation_mode.dart';

/// Wraps the [FormField] of a hooked widget to:
/// - give it the field's [ValidationMode], and run
///   [ValidationMode.afterFirstUnfocus], which Flutter does not provide;
/// - show a forced error set while the field was not mounted, e.g. a server
///   error on another page of a wizard.
class FieldValidation<E extends Enum> extends StatefulWidget {
  /// Creates a [FieldValidation].
  const FieldValidation({
    super.key,
    required this.form,
    required this.field,
    required this.autovalidateMode,
    required this.builder,
  });

  /// The form controller.
  final FormFieldsController<E> form;

  /// The wrapped field.
  final E field;

  /// The widget's own mode. Overrides the form's when not `null`.
  final AutovalidateMode? autovalidateMode;

  /// Builds the [FormField] with the [AutovalidateMode] to use.
  final Widget Function(AutovalidateMode autovalidateMode) builder;

  @override
  State<FieldValidation<E>> createState() => _FieldValidationState<E>();
}

class _FieldValidationState<E extends Enum> extends State<FieldValidation<E>> {
  /// Whether the user left the field after editing it, for
  /// [ValidationMode.afterFirstUnfocus].
  // ponytail: not reset by `form.reset()`; after a reset the field validates
  // on its first change instead of its first unfocus.
  bool _leftAfterEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.form.getFieldForcedError(widget.field) != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.form.fieldKey(widget.field).currentState?.validate();
      });
    }
  }

  void _onFocusChange(bool hasFocus) {
    final state = widget.form.fieldKey(widget.field).currentState;
    if (hasFocus || _leftAfterEdit || !(state?.hasInteractedByUser ?? false)) {
      return;
    }

    setState(() => _leftAfterEdit = true);
    state!.validate();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.autovalidateMode case final mode?) {
      return widget.builder(mode);
    }

    final mode = widget.form.validationModeOf(widget.field);
    if (mode != ValidationMode.afterFirstUnfocus) {
      return widget.builder(mode.autovalidateMode);
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChange,
      child: widget.builder(
        _leftAfterEdit
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
      ),
    );
  }
}
