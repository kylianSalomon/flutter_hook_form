import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';
import 'package:flutter_hook_form/src/models/validator.dart';

import 'types.dart';

/// A type that represents the initial values of a form field.
typedef InitialFieldValues<F extends FieldSchema<dynamic>, T> = Map<F, T>;

/// A [ChangeNotifier] subclass that exposes [notify] for use outside of
/// subclass context. Used to power per-field change notifications in
/// [FormFieldsController] without requiring type information.
class _FieldChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// A controller that manages form field states and validation
class FormFieldsController<F extends FieldSchema<dynamic>> {
  /// Creates a [FormFieldsController].
  FormFieldsController(
    this.key, {
    InitialFieldValues<F, Object?>? initialValues,
  }) : _initialValues = initialValues;

  /// The form key.
  final FormKey key;

  /// The field keys.
  final Map<FieldSchema<dynamic>, GlobalKey<FormFieldState<Object?>>> _fieldKeys = {};

  /// The initial values.
  final InitialFieldValues<F, Object?>? _initialValues;

  /// The forced errors.
  final _forcedErrors = <String, String>{};

  /// ValueNotifiers for each field - allows granular listening per field.
  final Map<FieldSchema<dynamic>, ValueNotifier<Object?>> _fieldNotifiers = {};

  /// Untyped change notifiers per field, used exclusively by [fieldListenable]
  /// to power [FormListenExtension.listen] without interfering with the typed
  /// [_fieldNotifiers] registry.
  final Map<FieldSchema<dynamic>, _FieldChangeNotifier> _fieldChangeNotifiers = {};

  /// Get or create a GlobalKey for a form field
  GlobalKey<FormFieldState<T>> fieldKey<T>(FieldSchema<T> field) {
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

  /// Returns the [ValueNotifier] for a specific field.
  ///
  /// Prefer [listen] for reactive field access. Use this directly only when
  /// integrating with [ValueListenableBuilder] outside a [HookWidget].
  ///
  /// ```dart
  /// // Recommended — inside HookWidget
  /// final email = form.listen({MyFields.email}, (get) => get<String>(MyFields.email));
  ///
  /// // With ValueListenableBuilder (works anywhere)
  /// ValueListenableBuilder<String?>(
  ///   valueListenable: form.getNotifier<String>(MyFields.email),
  ///   builder: (context, email, _) => Text('Email: $email'),
  /// )
  /// ```
  ValueNotifier<T?> getNotifier<T extends Object?>(FieldSchema<T> field) {
    final notifier = _fieldNotifiers.putIfAbsent(
      field,
      () {
        if (_initialValues?[field] case final T? value) {
          return ValueNotifier<T?>(value);
        }

        return ValueNotifier<T?>(null);
      },
    );

    if (notifier case final ValueNotifier<T?> value) {
      return value;
    }

    throw Exception('Invalid notifier type for field $field');
  }

  /// Returns a [Listenable] that fires when [field]'s value changes.
  ///
  /// Used by [FormListenExtension.listen] to subscribe to field changes
  /// without requiring type information. This is intentionally separate from
  /// [getNotifier] to avoid polluting the typed notifier registry with an
  /// untyped [Object?] entry that would break later typed [getNotifier] calls.
  Listenable fieldListenable(F field) {
    return _fieldChangeNotifiers.putIfAbsent(field, _FieldChangeNotifier.new);
  }

  /// Get the value of a form field.
  T? getValue<T>(FieldSchema<T> field) {
    // First try to get from widget state if available
    final widgetValue = _fieldKeys[field]?.currentState?.value as T?;
    if (widgetValue != null) {
      _syncNotifier(field, widgetValue);
      return widgetValue;
    }
    // Fallback to notifier value, then initial value
    if (_fieldNotifiers[field] case final notifier?) {
      return notifier.value as T?;
    }
    if (_initialValues?[field] case final T value) {
      return value;
    }
    return null;
  }

  /// Synchronizes the notifier value without triggering listeners if unchanged.
  void _syncNotifier<T>(FieldSchema<T> field, T? value) {
    final notifier = _fieldNotifiers[field];
    if (notifier != null && notifier.value != value) {
      notifier.value = value;
    }
  }

  /// Get the initial value of a form field.
  T? getInitialValue<T extends Object?>(FieldSchema<T> field) {
    if (_initialValues?[field] case final T value) {
      return value;
    }

    return null;
  }

  /// Update the value of a form field.
  ///
  /// When [notify] is `true` (default), all listeners on this field's
  /// [ValueNotifier] will be notified, causing widgets using [useFieldValue]
  /// or [ValueListenableBuilder] to rebuild.
  T? updateValue<T>(FieldSchema<T> field, T? value, {bool notify = true}) {
    if (notify) {
      // Get or create the notifier and update it (triggers listeners)
      final notifier = _fieldNotifiers.putIfAbsent(
        field,
        () {
          if (_initialValues?[field] case final T? value) {
            return ValueNotifier<T?>(value);
          }

          return ValueNotifier<T?>(null);
        },
      );
      notifier.value = value;
      _fieldChangeNotifiers[field]?.notify();
    } else {
      // Store value without creating notifier or notifying
      _fieldNotifiers[field]?.value = value;
    }

    // Update widget state if available
    _fieldKeys[field]?.currentState?.didChange(value);

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
      _fieldKeys[field]?.currentState?.validate();
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

    return isValid;
  }

  /// Clear the forced errors.
  void clearForcedErrors({bool notify = true}) {
    _forcedErrors.clear();
  }

  /// Reset the form.
  ///
  /// Resets all field values to their initial values and clears forced errors.
  void reset() {
    key.currentState?.reset();
    _forcedErrors.clear();

    // Reset notifiers to initial values
    for (final entry in _fieldNotifiers.entries) {
      final initialValue = _initialValues?[entry.key];
      entry.value.value = initialValue;
    }

    // Notify change listeners so form.listen rebuilds after reset
    for (final notifier in _fieldChangeNotifiers.values) {
      notifier.notify();
    }
  }

  /// Dispose of all resources.
  ///
  /// Call this method when the form is no longer needed to clean up
  /// the [ValueNotifier]s.
  void dispose() {
    for (final notifier in _fieldNotifiers.values) {
      notifier.dispose();
    }
    _fieldNotifiers.clear();
    for (final notifier in _fieldChangeNotifiers.values) {
      notifier.dispose();
    }
    _fieldChangeNotifiers.clear();
  }

  /// Validate the form field.
  bool validateField(F field) {
    return _fieldKeys[field]?.currentState?.validate() ?? false;
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
  }

  /// Get the values of the form fields.
  Map<F, dynamic> getValues() {
    return _fieldKeys.map(
      (key, field) => MapEntry(key as F, field.currentState?.value),
    );
  }
}
