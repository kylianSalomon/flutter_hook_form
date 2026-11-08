/// When a field validates itself while the user edits it.
///
/// Mirrors Flutter's `AutovalidateMode`, plus [afterFirstUnfocus]. Declare
/// it per field with `FieldConfig.validateOn`, or for the whole form with
/// `useForm(validateOn: ...)`. A widget's own `validateOn` argument still
/// takes priority.
enum ValidationMode {
  /// Never validates on its own.
  disabled,

  /// Validates on every build.
  always,

  /// Validates on every change once the user edited the field.
  onUserInteraction,

  /// Validates on change only while the field shows an error.
  onUserInteractionIfError,

  /// Validates when the field loses the focus.
  onUnfocus,

  /// Stays silent until the user edits the field and then leaves it. From
  /// then on, the field validates on every change.
  afterFirstUnfocus,
}
