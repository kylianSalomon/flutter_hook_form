import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';

import 'types.dart';
import 'validator.dart';

/// A type that represents the initial values of a form field.
typedef InitialFieldValues<F extends FieldSchema, T> = Map<F, T>;

/// A controller that manages form field states and validation
class FormFieldsController<F extends FieldSchema> extends ChangeNotifier {
  /// Creates a [FormFieldsController].
  FormFieldsController(this.key, {InitialFieldValues? initialValues})
    : _values = {...?initialValues};

  /// The form key.
  final FormKey key;

  /// The field keys.
  final Map<FieldSchema, GlobalKey<FormFieldState<dynamic>>> _fieldKeys = {};

  /// The initial values.
  // final InitialFieldValues<F>? _initialValues;

  /// The forced errors.
  final _forcedErrors = <String, String>{};

  /// The field values.
  final InitialFieldValues _values;

  /// Get or create a GlobalKey for a form field
  GlobalKey<FormFieldState<T>> fieldKey<T>(F field) {
    final key = _fieldKeys.putIfAbsent(
      field,
      () => GlobalKey<FormFieldState<T>>(debugLabel: field.name),
    );

    if (key is! GlobalKey<FormFieldState<T>>) {
      throw Exception(
        'Cannot return $key as a GlobalKey<FormFieldState<$T>>, key is of type ${key.runtimeType}',
      );
    }

    return key;
  }

  /// Get the value of a form field.
  T? getValue<T>(F field) {
    // First try to get from widget state if available
    final widgetValue = _fieldKeys[field]?.currentState?.value as T?;
    if (widgetValue != null) {
      _values[field] = widgetValue;
      return widgetValue;
    }
    // Fallback to stored value
    return _values[field] as T?;
  }

  /// Get the initial value of a form field.
  T? getInitialValue<T>(F field) {
    return _values[field];
  }

  /// Update the value of a form field.
  T? updateValue<T>(F field, T? value, {bool notify = true}) {
    _values[field] = value;

    // Update widget state if available
    _fieldKeys[field]?.currentState?.didChange(value);

    if (notify) {
      notifyListeners();
    }

    return value;
  }

  /// Get the error of a form field.
  String? getFieldError(F field) {
    return getFieldForcedError(field) ??
        _fieldKeys[field]?.currentState?.errorText;
  }

  /// Get the forced error of a form field.
  String? getFieldForcedError(F field) {
    return _forcedErrors[field.name];
  }

  /// Set the error of a form field.
  void setError(F field, String error, {bool notify = true}) {
    _forcedErrors[field.name] = error;
    if (notify) {
      notifyListeners();
    }
  }

  /// Check if a form field has an error.
  bool hasFieldError(F field) {
    return getFieldError(field) != null;
  }

  /// Get the validators of a form field. Use `localize` to localize the
  /// validators.
  List<Validator>? validators(F field) {
    return field.validators;
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
  bool validateField(F field) {
    final isValid = fieldKey(field).currentState?.validate();

    notifyListeners();
    return isValid ?? false;
  }

  /// Check if the form fields have been interacted with.
  bool isDirty(Set<F> fields) {
    return fields.every((field) {
      return _fieldKeys[field]?.currentState?.hasInteractedByUser ?? false;
    });
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
  bool get hasChanged => _fieldKeys.values.any((field) {
    if (field.currentWidget case final FormField formField) {
      return field.currentState?.value != formField.initialValue;
    }

    return false;
  });

  /// Save the form.
  void save() {
    key.currentState?.save();
    notifyListeners(); // Notify listeners after save
  }

  /// Get the values of the form fields.
  Map<F, dynamic> getValues() {
    return _fieldKeys.map(
      (key, field) => MapEntry(key as F, field.currentState?.value),
    );
  }
}
