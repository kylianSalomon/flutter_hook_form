import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';
import 'package:flutter_hook_form/src/models/validator.dart';

import 'types.dart';

/// A type that represents the initial values of a form field.
typedef InitialFieldValues<F extends FieldSchema<dynamic>, T> = Map<F, T>;

/// Single per-field value holder. Acts as the canonical store for the field's
/// value and as the [Listenable] that powers reactive subscribers.
///
/// Uses [setSilently] to update the value without firing listeners, which is
/// what `updateValue(field, value, notify: false)` needs.
class _FieldNotifier extends ChangeNotifier
    implements ValueListenable<Object?> {
  _FieldNotifier(this._value);

  Object? _value;

  @override
  Object? get value => _value;

  set value(Object? newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  // ignore: use_setters_to_change_properties
  void setSilently(Object? newValue) {
    _value = newValue;
  }
}

/// Read-only typed projection of a [_FieldNotifier].
///
/// Returned by [FormFieldsController.getNotifier] so callers can read the
/// field's value with the right static type and subscribe via
/// [ValueListenableBuilder] / `useValueListenable`. Mutation goes through
/// [FormFieldsController.updateValue] only.
///
/// Equality delegates to the wrapped notifier so multiple wrappers around the
/// same field compare equal — keeps `useValueListenable` from re-subscribing
/// on every rebuild.
class _TypedFieldListenable<T> extends ValueListenable<T?> {
  _TypedFieldListenable(this._inner);

  final _FieldNotifier _inner;

  @override
  T? get value => _inner.value as T?;

  @override
  void addListener(VoidCallback listener) => _inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _inner.removeListener(listener);

  @override
  bool operator ==(Object other) =>
      other is _TypedFieldListenable<T> && other._inner == _inner;

  @override
  int get hashCode => Object.hash(_TypedFieldListenable<T>, _inner);
}

/// A controller that manages form field states and validation
class FormFieldsController<F extends FieldSchema<dynamic>> {
  /// Creates a [FormFieldsController].
  FormFieldsController(
    this.key, {
    InitialFieldValues<F, Object?>? initialValues,
    this.focusOnInvalid = false,
    this.autoScrollWhenFocusOnInvalid = true,
  }) : _initialValues = initialValues;

  /// The form key.
  final FormKey key;

  /// Whether [validate] moves focus to the first invalid field by default.
  ///
  /// Can be overridden per call via `validate(focusOnInvalid: ...)`.
  final bool focusOnInvalid;

  /// Whether [validate] scrolls the first invalid field into view by
  /// default, when [focusOnInvalid] (or its per-call override) is `true`.
  ///
  /// Can be overridden per call via
  /// `validate(autoScrollWhenFocusOnInvalid: ...)`.
  final bool autoScrollWhenFocusOnInvalid;

  /// The field keys.
  final Map<FieldSchema<dynamic>, GlobalKey<FormFieldState<Object?>>>
  _fieldKeys = {};

  /// The focus node for each field that opted into focus-on-invalid support.
  final Map<FieldSchema<dynamic>, FocusNode> _fieldFocusNodes = {};

  /// Fields whose [FocusNode] was created (and is therefore owned and
  /// disposed) by this controller, as opposed to one supplied by the caller.
  final Set<FieldSchema<dynamic>> _ownedFocusNodes = {};

  /// The initial values.
  final InitialFieldValues<F, Object?>? _initialValues;

  /// The forced errors.
  final _forcedErrors = <String, String>{};

  /// Single source of truth for field values. One notifier per field, used
  /// by both [getNotifier] (typed read access) and [fieldListenable]
  /// (untyped change subscription for `form.listen`).
  final Map<FieldSchema<dynamic>, _FieldNotifier> _fieldNotifiers = {};

  /// Lazily creates the notifier for [field], seeded with its initial value.
  _FieldNotifier _notifierFor(FieldSchema<dynamic> field) {
    return _fieldNotifiers.putIfAbsent(
      field,
      () => _FieldNotifier(_initialValues?[field]),
    );
  }

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

  /// Returns the [FocusNode] used to focus [field] when validation fails
  /// with [focusOnInvalid] enabled.
  ///
  /// Pass [external] to register a [FocusNode] you manage yourself (e.g. one
  /// created by a hook and wired into a custom [HookedFormField] builder).
  /// Without [external], a node is lazily created and owned by the
  /// controller, so it is disposed with [dispose].
  FocusNode focusNodeFor<T>(FieldSchema<T> field, {FocusNode? external}) {
    if (external != null) {
      _fieldFocusNodes[field] = external;
      return external;
    }

    return _fieldFocusNodes.putIfAbsent(field, () {
      _ownedFocusNodes.add(field);
      return FocusNode(debugLabel: field.name);
    });
  }

  /// Returns a read-only [ValueListenable] for [field].
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
  ValueListenable<T?> getNotifier<T extends Object?>(FieldSchema<T> field) {
    return _TypedFieldListenable<T>(_notifierFor(field));
  }

  /// Returns a [Listenable] that fires when [field]'s value changes.
  ///
  /// Used by [FormListenExtension.listen] to subscribe to field changes
  /// without requiring type information. Backed by the same per-field
  /// notifier as [getNotifier], so updates fire both subscribers from a
  /// single source.
  Listenable fieldListenable(F field) => _notifierFor(field);

  /// Get the value of a form field.
  ///
  /// Reads from the field's notifier (the canonical store). Falls back to
  /// the initial-values map if no write has occurred yet.
  T? getValue<T>(FieldSchema<T> field) {
    if (_fieldNotifiers[field] case final notifier?) {
      return notifier.value as T?;
    }
    if (_initialValues?[field] case final T value) {
      return value;
    }
    return null;
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
  /// When [notify] is `true` (default), all listeners on this field are
  /// notified, causing widgets using [FormListenExtension.listen] or
  /// [ValueListenableBuilder] to rebuild. Setting [notify] to `false`
  /// writes silently — useful when the caller wants to update the value
  /// without triggering reactive rebuilds (e.g., during bulk updates).
  T? updateValue<T>(FieldSchema<T> field, T? value, {bool notify = true}) {
    final notifier = _notifierFor(field);
    if (notify) {
      notifier.value = value;
    } else {
      notifier.setSilently(value);
    }

    // Keep the FormField widget in sync with the canonical store so
    // validators, save(), and the rendered text reflect the same value.
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
  ///
  /// If `focusOnInvalid` is `true` (defaults to the controller's
  /// [FormFieldsController.focusOnInvalid]) and validation fails, focus
  /// moves to the first invalid field's [FocusNode], if it has one — see
  /// [focusNodeFor]. When `autoScrollWhenFocusOnInvalid` is also `true`
  /// (defaults to [FormFieldsController.autoScrollWhenFocusOnInvalid]), that
  /// field is scrolled into view beforehand.
  bool validate({
    bool notify = true,
    bool clearErrors = true,
    bool? focusOnInvalid,
    bool? autoScrollWhenFocusOnInvalid,
  }) {
    if (clearErrors) {
      _forcedErrors.clear();
    }

    final isValid = key.currentState?.validate() ?? false;

    if (!isValid && (focusOnInvalid ?? this.focusOnInvalid)) {
      _focusFirstInvalidField(
        scroll:
            autoScrollWhenFocusOnInvalid ?? this.autoScrollWhenFocusOnInvalid,
      );
    }

    return isValid;
  }

  /// Focuses (and optionally scrolls to) the invalid field declared first in
  /// the [FieldSchema] enum.
  void _focusFirstInvalidField({required bool scroll}) {
    final invalidField = minBy(
      _fieldKeys.entries.where(
        (entry) => entry.value.currentState?.hasError ?? false,
      ),
      (entry) => entry.key.index,
    );

    if (invalidField == null) {
      return;
    }

    if (scroll) {
      if (invalidField.value.currentContext case final context?) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    _fieldFocusNodes[invalidField.key]?.requestFocus();
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

    // Restore notifiers to initial values (loud notification so subscribers
    // rebuild). ValueNotifier-style equality means no-op resets don't fire.
    for (final entry in _fieldNotifiers.entries) {
      entry.value.value = _initialValues?[entry.key];
    }
  }

  /// Dispose of all resources.
  ///
  /// Call this method when the form is no longer needed to clean up
  /// the per-field notifiers and any [FocusNode] created by [focusNodeFor].
  /// [FocusNode]s supplied via `focusNodeFor(field, external: ...)` are
  /// owned by the caller and are left untouched.
  void dispose() {
    for (final notifier in _fieldNotifiers.values) {
      notifier.dispose();
    }
    _fieldNotifiers.clear();

    for (final field in _ownedFocusNodes) {
      _fieldFocusNodes[field]?.dispose();
    }
    _fieldFocusNodes.clear();
    _ownedFocusNodes.clear();
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
      (key, field) => MapEntry(key as F, _fieldNotifiers[key]?.value),
    );
  }
}
