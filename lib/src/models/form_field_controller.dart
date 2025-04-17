import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'form_schema.dart';
import 'types.dart';
import 'validator.dart';

/// A type that represents the initial values of a form field.
typedef InitialFieldValues<F extends FormSchema>
    = Set<InitializedField<F, dynamic>>;

/// A controller that manages form field states and validation
class FormFieldsController<F extends FormSchema> extends ChangeNotifier {
  /// Creates a [FormFieldsController].
  FormFieldsController(
    this.key,
    F formSchema, {
    InitialFieldValues<F>? initialValues,
  })  : _formSchema = formSchema,
        _initialValues = initialValues,
        _values = {
          ...?initialValues?.fold<Map<String, dynamic>>({}, (map, e) {
            map[e.fieldId.toString()] = e.initialValue;
            return map;
          })
        };

  /// The form key.
  final FormKey key;

  /// The form schema.
  final F _formSchema;

  /// The field keys.
  final _fieldKeys = <String, GlobalKey<FormFieldState>>{};

  /// The initial values.
  final InitialFieldValues<F>? _initialValues;

  /// The forced errors.
  final _forcedErrors = <String, String>{};

  /// The field values.
  final Map<String, dynamic> _values;

  /// Get or create a GlobalKey for a form field
  GlobalKey<FormFieldState<T>> fieldKey<T>(HookField<F, T> hookField) {
    return _fieldKeys.putIfAbsent(
            hookField.toString(),
            () =>
                GlobalKey<FormFieldState<T>>(debugLabel: hookField.toString()))
        as GlobalKey<FormFieldState<T>>;
  }

  /// Get the value of a form field.
  T? getValue<T>(HookField<F, T> hookField) {
    final fieldKey = hookField.toString();
    // First try to get from widget state if available
    final widgetValue = _fieldKeys[fieldKey]?.currentState?.value as T?;
    if (widgetValue != null) {
      _values[fieldKey] = widgetValue;
      return widgetValue;
    }
    // Fallback to stored value
    return _values[fieldKey] as T?;
  }

  /// Get the initial value of a form field.
  T? getInitialValue<T>(HookField<F, T> hookField) {
    return _initialValues
        ?.firstWhereOrNull((e) => e.fieldId.id == hookField.id)
        ?.initialValue as T?;
  }

  /// Update the value of a form field.
  T? updateValue<T>(
    HookField<F, T> hookField,
    T? value, {
    bool notify = true,
  }) {
    final fieldKey = hookField.toString();
    _values[fieldKey] = value;

    // Update widget state if available
    _fieldKeys[fieldKey]?.currentState?.didChange(value);

    if (notify) {
      notifyListeners();
    }

    return value;
  }

  /// Get the error of a form field.
  String? getFieldError<T>(HookField<F, T> hookField) {
    return getFieldForcedError(hookField) ??
        _fieldKeys[hookField.toString()]?.currentState?.errorText;
  }

  /// Get the forced error of a form field.
  String? getFieldForcedError<T>(HookField<F, T> hookField) {
    return _forcedErrors[hookField.toString()];
  }

  /// Set the error of a form field.
  void setError<T>(
    HookField<F, T> hookField,
    String error, {
    bool notify = true,
  }) {
    _forcedErrors[hookField.toString()] = error;
    if (notify) {
      notifyListeners();
    }
  }

  /// Check if a form field has an error.
  bool hasFieldError<T>(HookField<F, T> hookField) {
    return getFieldError(hookField) != null;
  }

  /// Get the validators of a form field. Use `localize` to localize the
  /// validators.
  List<Validator<T>>? validators<T>(HookField<F, T> hookField) {
    return _formSchema.field(hookField)?.validators;
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
  bool validateField<T>(HookField<F, T> hookField) {
    final isValid = fieldKey(hookField).currentState?.validate();

    notifyListeners();
    return isValid ?? false;
  }

  /// Check if the form fields have been interacted with.
  bool isDirty<T>(Set<HookField<F, T>> hookFields) {
    return hookFields.every(
      (hookField) =>
          fieldKey(hookField).currentState?.hasInteractedByUser ?? false,
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
