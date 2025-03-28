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
  GlobalKey<FormFieldState<T>> fieldKey<T>(HookedFieldId<F, T> fieldId) {
    return _fieldKeys.putIfAbsent(fieldId.toString(),
            () => GlobalKey<FormFieldState<T>>(debugLabel: fieldId.toString()))
        as GlobalKey<FormFieldState<T>>;
  }

  /// Get the value of a form field.
  T? getValue<T>(HookedFieldId<F, T> fieldId) {
    return _fieldKeys[fieldId.toString()]?.currentState?.value as T?;
  }

  /// Update the value of a form field.
  T? updateValue<T>(
    HookedFieldId<F, T> fieldId,
    T? value, {
    bool notify = true,
  }) {
    _fieldKeys[fieldId.toString()]?.currentState?.didChange(value);

    if (notify) {
      // Notify listeners when a field value changes
      notifyListeners();
    }

    return value;
  }

  /// Get the error of a form field.
  String? getFieldError<T>(HookedFieldId<F, T> fieldId) {
    return getFieldForcedError(fieldId) ??
        _fieldKeys[fieldId.toString()]?.currentState?.errorText;
  }

  /// Get the forced error of a form field.
  String? getFieldForcedError<T>(HookedFieldId<F, T> fieldId) {
    return _forcedErrors[fieldId.toString()];
  }

  /// Set the error of a form field.
  void setError<T>(
    HookedFieldId<F, T> fieldId,
    String error, {
    bool notify = true,
  }) {
    _forcedErrors[fieldId.toString()] = error;
    if (notify) {
      notifyListeners();
    }
  }

  /// Check if a form field has an error.
  bool hasFieldError<T>(HookedFieldId<F, T> fieldId) {
    return getFieldError(fieldId) != null;
  }

  /// Get the validators of a form field. Use `localize` to localize the
  /// validators.
  List<Validator<T>>? validators<T>(HookedFieldId<F, T> fieldId) {
    return _formSchema.field<T, F>(fieldId)?.validators;
  }

  /// Validate the form.
  ///
  /// If `notify` is `true`, the form will notify listeners after validation.
  /// Consider setting `notify` to `false` if you are using `validate` as a
  /// condition to enable or disable a button.
  ///
  /// If `clearErrors` is `true`, the forced errors will be cleared.
  /// Consider setting `clearErrors` to `false` if you are calling `validate`
  /// as a condition to enable or disable a button.
  bool validate({bool notify = true, bool clearErrors = true}) {
    if (clearErrors) {
      _forcedErrors.clear();
    }

    final isValid = key.currentState?.validate() ?? false;
    if (notify) {
      notifyListeners(); // Notify listeners after validation
    }
    return isValid;
  }

  /// Clear the forced errors.
  void clearForcedErrors({bool notify = true}) {
    _forcedErrors.clear();
    if (notify) {
      notifyListeners();
    }
  }

  /// Reset the form.
  void reset() {
    key.currentState?.reset();
    _forcedErrors.clear();
    notifyListeners(); // Notify listeners after reset
  }

  /// Validate the form field.
  bool validateField<T>(HookedFieldId<F, T> fieldId) {
    final isValid = fieldKey(fieldId).currentState?.validate();

    notifyListeners();
    return isValid ?? false;
  }

  /// Check if the form fields have been interacted with.
  bool isDirty<T>(Set<HookedFieldId<F, T>> fieldIds) {
    return fieldIds.every(
      (fieldId) => fieldKey(fieldId).currentState?.hasInteractedByUser ?? false,
    );
  }

  /// Check if all form fields have been interacted with.
  bool isAllDirty() {
    return _fieldKeys.values.every(
      (field) => field.currentState?.hasInteractedByUser ?? false,
    );
  }

  /// Check if the form has been interacted with.
  bool get hasBeenInteracted => _fieldKeys.values.any(
        (field) => field.currentState?.hasInteractedByUser ?? false,
      );

  /// Check if the form has changed.
  bool get hasChanged => _fieldKeys.values.any(
        (field) {
          if (field.currentWidget case final FormField formField) {
            return field.currentState?.value != formField.initialValue;
          }

          return false;
        },
      );

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
