import 'package:flutter/widgets.dart';

import 'form_schema.dart';
import 'types.dart';
import 'validator.dart';

/// A controller that manages form field states and validation
class FormFieldsController<F extends FormSchema> extends ChangeNotifier {
  /// Creates a [FormFieldsController].
  FormFieldsController(
    this.key,
    F formSchema,
  ) : _formSchema = formSchema;

  /// The form key.
  final FormKey key;

  /// The form schema.
  final F _formSchema;

  /// The field keys.
  final _fieldKeys = <String, GlobalKey<FormFieldState>>{};

  /// The forced errors.
  final _forcedErrors = <String, String>{};

  /// Get or create a GlobalKey for a form field
  GlobalKey<FormFieldState<T>> fieldKey<T>(TypedId<T> fieldId) {
    return _fieldKeys.putIfAbsent(
      fieldId.id,
      () => GlobalKey<FormFieldState<T>>(debugLabel: fieldId.id),
    ) as GlobalKey<FormFieldState<T>>;
  }

  /// Get the value of a form field.
  T? getValue<T>(TypedId<T> fieldId) {
    return _fieldKeys[fieldId.id]?.currentState?.value as T?;
  }

  /// Update the value of a form field.
  T? updateValue<T>(TypedId<T> fieldId, T? value) {
    _fieldKeys[fieldId.id]?.currentState?.didChange(value);

    return value;
  }

  /// Get the error of a form field.
  String? getFieldError<T>(TypedId<T> fieldId) {
    return _fieldKeys[fieldId.id]?.currentState?.errorText;
  }

  /// Set the error of a form field.
  void setError<T>(TypedId<T> fieldId, String error) {
    _forcedErrors[fieldId.id] = error;
  }

  /// Check if a form field has an error.
  bool hasFieldError<T>(TypedId<T> fieldId) {
    return getFieldError(fieldId) != null;
  }

  /// Get the validators of a form field. Use `localize` to localize the
  /// validators.
  List<Validator<T>>? validators<T>(TypedId<T> fieldId) {
    return _formSchema.field(fieldId)?.validators;
  }

  /// Validate the form.
  bool validate() {
    _forcedErrors.clear();

    final isValid = key.currentState?.validate() ?? false;
    notifyListeners(); // Notify listeners after validation
    return isValid;
  }

  /// Save the form.
  void save() {
    key.currentState?.save();
    notifyListeners(); // Notify listeners after save
  }

  /// Get the values of the form fields.
  Map<String, dynamic> getValues() {
    return _fieldKeys.map(
      (key, field) => MapEntry(key, field.currentState?.value),
    );
  }
}
