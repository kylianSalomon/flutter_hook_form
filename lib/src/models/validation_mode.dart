import 'package:flutter/widgets.dart' show AutovalidateMode;

/// When a field validates itself while the user edits it.
///
/// Mirrors Flutter's [AutovalidateMode], plus [afterFirstUnfocus], which
/// Flutter does not provide. Declare it per field with
/// `FieldConfig.validateOn`, or for the whole form with
/// `useForm(validateOn: ...)`. A widget's own `autovalidateMode` argument
/// still takes priority.
enum ValidationMode {
  /// See [AutovalidateMode.disabled].
  disabled(AutovalidateMode.disabled),

  /// See [AutovalidateMode.always].
  always(AutovalidateMode.always),

  /// See [AutovalidateMode.onUserInteraction].
  onUserInteraction(AutovalidateMode.onUserInteraction),

  /// See [AutovalidateMode.onUserInteractionIfError].
  onUserInteractionIfError(AutovalidateMode.onUserInteractionIfError),

  /// See [AutovalidateMode.onUnfocus].
  onUnfocus(AutovalidateMode.onUnfocus),

  /// Stays silent until the user edits the field and then leaves it. From
  /// then on, the field validates on every change.
  afterFirstUnfocus(AutovalidateMode.disabled);

  const ValidationMode(this.autovalidateMode);

  /// The [AutovalidateMode] given to the underlying [FormField]. For
  /// [afterFirstUnfocus], this is the mode used before the first unfocus.
  final AutovalidateMode autovalidateMode;
}
