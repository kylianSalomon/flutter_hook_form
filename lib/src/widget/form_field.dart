import 'package:dartnative/dartnative.dart';

import '../models/validation_mode.dart';

/// DartNative has no `Form`/`FormField`: this is the subset of Flutter's
/// `FormField` that the hooked widgets need. The [FormFieldsController]
/// plays the `Form` role through the fields' [GlobalKey]s.
///
/// It also runs every [ValidationMode], including
/// [ValidationMode.afterFirstUnfocus], and validates right after mounting
/// when [validateOnMount] is `true`.
class FormField<T> extends StatefulWidget {
  /// Creates a [FormField].
  const FormField({
    super.key,
    required this.builder,
    this.validator,
    this.forceErrorText,
    this.validationMode = ValidationMode.disabled,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.focusNode,
    this.validateOnMount = false,
  });

  /// Builds the field's widget.
  final Widget Function(FormFieldState<T> field) builder;

  /// Returns an error message, or `null` when the value is valid.
  final String? Function(T? value)? validator;

  /// Shown as the error instead of the validator's result when not `null`.
  final String? forceErrorText;

  /// When the field validates itself while the user edits it.
  final ValidationMode validationMode;

  /// Whether the field validates itself; a disabled field never does.
  final bool enabled;

  /// The value before any change, and after [FormFieldState.reset].
  final T? initialValue;

  /// Called with the value by [FormFieldState.save].
  final void Function(T? value)? onSaved;

  /// The node whose focus drives [ValidationMode.onUnfocus] and
  /// [ValidationMode.afterFirstUnfocus]. Without it, a [Focus] around the
  /// field reports the focus changes.
  final FocusNode? focusNode;

  /// Whether to validate after the first frame, e.g. to show a forced error
  /// set while the field was not mounted.
  final bool validateOnMount;

  @override
  State<FormField<T>> createState() => FormFieldState<T>();
}

/// The state of a [FormField].
class FormFieldState<T> extends State<FormField<T>> {
  T? _value;
  String? _errorText;
  bool _hasInteractedByUser = false;

  /// Whether the user left the field after editing it, for
  /// [ValidationMode.afterFirstUnfocus].
  bool _leftAfterEdit = false;

  /// The current value.
  T? get value => _value;

  /// The error shown, or `null`.
  String? get errorText => widget.forceErrorText ?? _errorText;

  /// Whether the field shows an error.
  bool get hasError => errorText != null;

  /// Whether the user changed the value since the last [reset].
  bool get hasInteractedByUser => _hasInteractedByUser;

  /// Whether the field validates itself on every change right now.
  bool get validatesOnChange => switch (widget.validationMode) {
    ValidationMode.always => true,
    ValidationMode.onUserInteraction => _hasInteractedByUser,
    ValidationMode.afterFirstUnfocus => _leftAfterEdit,
    _ => false,
  };

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    widget.focusNode?.addListener(_onFocusNodeChange);
    if (widget.validateOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          validate();
        }
      });
    }
  }

  @override
  void didUpdateWidget(FormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusNodeChange);
      widget.focusNode?.addListener(_onFocusNodeChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusNodeChange);
    super.dispose();
  }

  /// Runs the validator, shows its result and returns whether it passed.
  bool validate() {
    setState(_validate);
    return !hasError;
  }

  void _validate() {
    _errorText = widget.validator?.call(_value);
  }

  /// Sets the value as a user edit.
  void didChange(T? value) {
    setState(() {
      _value = value;
      _hasInteractedByUser = true;
    });
  }

  /// Restores the initial value and clears the error.
  void reset() {
    setState(() {
      _value = widget.initialValue;
      _hasInteractedByUser = false;
      _leftAfterEdit = false;
      _errorText = null;
    });
  }

  /// Calls [FormField.onSaved] with the value.
  void save() => widget.onSaved?.call(_value);

  void _onFocusNodeChange() => _onFocusChange(widget.focusNode!.hasFocus);

  void _onFocusChange(bool hasFocus) {
    if (hasFocus || !widget.enabled) {
      return;
    }
    switch (widget.validationMode) {
      case ValidationMode.onUnfocus:
        validate();
      case ValidationMode.afterFirstUnfocus
          when _hasInteractedByUser && !_leftAfterEdit:
        // The next build validates, see [validatesOnChange].
        setState(() => _leftAfterEdit = true);
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      if (validatesOnChange ||
          (widget.validationMode == ValidationMode.onUserInteractionIfError &&
              _hasInteractedByUser &&
              _errorText != null)) {
        _validate();
      }
    }

    final child = widget.builder(this);
    final watchesFocus =
        widget.validationMode == ValidationMode.onUnfocus ||
        widget.validationMode == ValidationMode.afterFirstUnfocus;
    if (widget.focusNode != null || !watchesFocus) {
      return child;
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChange,
      child: child,
    );
  }
}
