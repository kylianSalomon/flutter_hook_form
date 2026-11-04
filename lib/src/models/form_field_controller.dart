import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/validation_mode.dart';
import 'package:flutter_hook_form/src/models/validator.dart';
import 'package:flutter_hook_form/src/validators/field_config.dart';

import 'types.dart';

/// A type that represents the initial values of a form field.
typedef InitialFieldValues<E extends Enum, T> = Map<E, T>;

/// Single per-field value holder. Acts as the canonical store for the field's
/// value and as the [Listenable] that powers reactive subscribers.
///
/// Uses [setSilently] to update the value without firing listeners, which is
/// what `updateValue(field, value, notify: false)` needs.
class _FieldNotifier(var Object? _value)
    extends ChangeNotifier
    implements ValueListenable<Object?> {
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
class const _TypedFieldListenable<T>(final _FieldNotifier _inner)
    extends ValueListenable<T?> {
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
class FormFieldsController<E extends Enum>(
  /// The form key.
  final FormKey key, {

  final Map<E, FieldConfig>? _validators,

  /// Whether [validate] moves focus to the first invalid field by default.
  ///
  /// Can be overridden per call via `validate(focusOnInvalid: ...)`.
  final bool focusOnInvalid = false,

  /// Whether [validate] scrolls the first invalid field into view by
  /// default, when [focusOnInvalid] (or its per-call override) is `true`.
  ///
  /// Can be overridden per call via
  /// `validate(autoScrollWhenFocusOnInvalid: ...)`.
  final bool autoScrollWhenFocusOnInvalid = false,

  /// When fields validate themselves while the user edits them, for fields
  /// that do not set `FieldConfig.validateOn`. See [validationModeOf].
  final ValidationMode validateOn = ValidationMode.disabled,
}) {
  /// Creates a [FormFieldsController].
  this {
    _initialValues = {
      ...?_validators?.map((key, value) => MapEntry(key, value.initialValue)),
    };
    _fieldKeys = {};
    _fieldFocusNodes = {};
    _ownedFocusNodes = {};
    _forcedErrors = {};
  }

  /// The field keys.
  late final Map<E, GlobalKey<FormFieldState<Object?>>> _fieldKeys;

  /// The focus node for each field that opted into focus-on-invalid support.
  late final Map<E, FocusNode> _fieldFocusNodes;

  /// Fields whose [FocusNode] was created (and is therefore owned and
  /// disposed) by this controller, as opposed to one supplied by the caller.
  late final Set<E> _ownedFocusNodes;

  /// The forced errors, e.g. returned by a server.
  late final Map<E, String> _forcedErrors;

  late final InitialFieldValues<E, dynamic> _initialValues;

  /// Single source of truth for field values. One notifier per field, used
  /// by both [getNotifier] (typed read access) and [fieldListenable]
  /// (untyped change subscription for `form.listen`).
  final Map<E, _FieldNotifier> _fieldNotifiers = {};

  /// Lazily creates the notifier for [field], seeded with its initial value.
  _FieldNotifier _notifierFor(E field) {
    return _fieldNotifiers.putIfAbsent(
      field,
      () => _FieldNotifier(_initialValues[field]),
    );
  }

  /// Every field the controller knows of: declared in the schema, rendered
  /// by a hooked widget, or holding a forced error.
  Set<E> get _knownFields => {
    ...?_validators?.keys,
    ..._fieldKeys.keys,
    ..._forcedErrors.keys,
  };

  /// A mounted field's context, which sits below the [HookedForm] provider
  /// and lets cross-field validators run for fields that are not mounted.
  BuildContext? get _mountedFieldContext =>
      _fieldKeys.values.map((key) => key.currentContext).nonNulls.firstOrNull;

  /// When [field] validates itself while the user edits it: its
  /// `FieldConfig.validateOn`, or [validateOn] by default.
  ValidationMode validationModeOf(E field) {
    return _validators?[field]?.validationMode ?? validateOn;
  }

  /// Get or create a GlobalKey for a form field
  GlobalKey<FormFieldState> fieldKey(E field) {
    final key = _fieldKeys.putIfAbsent(
      field,
      () => GlobalKey<FormFieldState>(debugLabel: field.name),
    );

    return key;
  }

  /// Returns the [FocusNode] used to focus [field] when validation fails
  /// with [focusOnInvalid] enabled.
  ///
  /// Pass [external] to register a [FocusNode] you manage yourself (e.g. one
  /// created by a hook and wired into a custom [HookedFormField] builder).
  /// Without [external], a node is lazily created and owned by the
  /// controller, so it is disposed with [dispose].
  FocusNode focusNodeFor(E field, {FocusNode? external}) {
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
  ValueListenable<T?> getNotifier<T extends Object?>(E field) {
    final notifier = _notifierFor(field);
    if (notifier.value is! T?) {
      throw Exception(
        'Cannot return $notifier as a ValueListenable<T>, value is of type ${notifier._value?.runtimeType}',
      );
    }

    return _TypedFieldListenable<T>(notifier);
  }

  /// Returns a [Listenable] that fires when [field]'s value changes.
  ///
  /// Used by [FormListenExtension.listen] to subscribe to field changes
  /// without requiring type information. Backed by the same per-field
  /// notifier as [getNotifier], so updates fire both subscribers from a
  /// single source.
  Listenable fieldListenable(E field) => _notifierFor(field);

  /// Get the value of a form field.
  ///
  /// Reads from the field's notifier (the canonical store). Falls back to
  /// the initial-values map if no write has occurred yet.
  T? getValue<T>(E field) {
    if (_fieldNotifiers[field] case final notifier?) {
      return notifier.value as T?;
    }
    if (_initialValues[field] case final T value) {
      return value;
    }
    return null;
  }

  /// Get the initial value of a form field.
  T? getInitialValue<T extends Object?>(E field) {
    if (_initialValues[field] case final T value) {
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
  ///
  /// A forced error on [field] (see [setError]) describes the previous value,
  /// so it is removed and the field is revalidated. Mounted fields whose
  /// cross-field validators read [field] are revalidated when they show an
  /// error or validate on interaction.
  T? updateValue<T>(E field, T? value, {bool notify = true}) {
    final notifier = _notifierFor(field);
    if (notify) {
      notifier.value = value;
    } else {
      notifier.setSilently(value);
    }

    // Keep the FormField widget in sync with the canonical store so
    // validators, save(), and the rendered text reflect the same value.
    _fieldKeys[field]?.currentState?.didChange(value);

    if (_forcedErrors.remove(field) != null) {
      _fieldKeys[field]?.currentState?.validate();
    }
    _revalidateDependentsOf(field);

    return value;
  }

  /// Revalidates the mounted fields whose cross-field validators read
  /// [source], so their error follows [source]'s new value.
  void _revalidateDependentsOf(E source) {
    for (final MapEntry(key: field, value: config)
        in _validators?.entries ?? <MapEntry<E, FieldConfig>>[]) {
      final state = _fieldKeys[field]?.currentState;
      final readsSource = config.validators.any(
        (validator) =>
            validator is CrossFieldValidator && validator.field == source,
      );
      if (field == source || state == null || !readsSource) {
        continue;
      }

      final validatesOnChange = switch (state.widget.autovalidateMode) {
        AutovalidateMode.always => true,
        AutovalidateMode.onUserInteraction => state.hasInteractedByUser,
        _ => false,
      };
      if (state.hasError || validatesOnChange) {
        state.validate();
      }
    }
  }

  /// Get the error of a form field.
  String? getFieldError(E field) {
    return getFieldForcedError(field) ??
        _fieldKeys[field]?.currentState?.errorText;
  }

  /// Get the forced error of a form field.
  String? getFieldForcedError(E field) {
    return _forcedErrors[field];
  }

  /// Forces an error on [field], e.g. one returned by a server. [error] can
  /// be an error code, localized via `FormErrorMessages.parseErrorCode`.
  ///
  /// The error stays until the field's value changes, [clearForcedErrors]
  /// or [reset] is called, or `validate(clearErrors: true)` runs. When
  /// [notify] is `true`, the field shows the error right away.
  void setError(E field, String error, {bool notify = true}) {
    _forcedErrors[field] = error;
    if (notify) {
      _fieldKeys[field]?.currentState?.validate();
    }
  }

  /// Forces several errors at once, e.g. a server's 422 response mapped to
  /// fields. Merges with the forced errors already set; see [setError].
  ///
  /// When [notify] is `true`, the fields show their error right away and, if
  /// [focusOnInvalid] is enabled, the first one (in enum order) that is
  /// mounted gets the focus.
  ///
  /// ```dart
  /// final response = await api.register(payload);
  /// if (response.statusCode == 422) {
  ///   form.setErrors({.username: 'username_taken'});
  /// }
  /// ```
  void setErrors(Map<E, String> errors, {bool notify = true}) {
    _forcedErrors.addAll(errors);
    if (!notify) {
      return;
    }

    for (final field in errors.keys) {
      _fieldKeys[field]?.currentState?.validate();
    }
    if (focusOnInvalid) {
      _focusFirstInvalidField(
        errors.keys,
        scroll: autoScrollWhenFocusOnInvalid,
      );
    }
  }

  /// Same as [setErrors], with fields given by their enum `name`, e.g. the
  /// `errors` object of a JSON response. Unknown names are ignored.
  ///
  /// A name is resolved only for a field the controller knows: declared in
  /// the schema or rendered by a hooked widget.
  void setErrorsByName(Map<String, String> errors, {bool notify = true}) {
    setErrors({
      for (final field in _knownFields)
        if (errors[field.name] case final error?) field: error,
    }, notify: notify);
  }

  /// Check if a form field has an error.
  bool hasFieldError(E field) {
    return getFieldError(field) != null;
  }

  /// Get the validators of a form field. Use `localize` to localize the
  /// validators.
  List<Validator>? validators(E field) {
    return _validators?[field]?.validators;
  }

  /// Validate the form.
  ///
  /// If `notify` is `true`, the form will notify listeners after validation.
  /// Consider setting `notify` to `false` if you are using `validate` as a
  /// condition to enable or disable a button.
  ///
  /// Forced errors (see [setError]) are kept and make the form invalid until
  /// their field changes. Set `clearErrors` to `true` to drop them first.
  ///
  /// Fields that are not mounted, e.g. on another page of a wizard, are
  /// checked by running their schema validators on their stored value.
  ///
  /// If `focusOnInvalid` is `true` (defaults to the controller's
  /// [FormFieldsController.focusOnInvalid]) and validation fails, focus
  /// moves to the first invalid field's [FocusNode], if it has one — see
  /// [focusNodeFor]. When `autoScrollWhenFocusOnInvalid` is also `true`
  /// (defaults to [FormFieldsController.autoScrollWhenFocusOnInvalid]), that
  /// field is scrolled into view beforehand.
  bool validate({
    bool notify = true,
    bool clearErrors = false,
    bool? focusOnInvalid,
    bool? autoScrollWhenFocusOnInvalid,
  }) {
    if (clearErrors) {
      _forcedErrors.clear();
    }

    final mountedValid = key.currentState?.validate() ?? false;
    final context = _mountedFieldContext;
    final isValid =
        mountedValid &&
        _knownFields
            .where((field) => _fieldKeys[field]?.currentState == null)
            .every((field) => _validateField(field, context));

    if (!isValid && (focusOnInvalid ?? this.focusOnInvalid)) {
      _focusFirstInvalidField(
        _fieldKeys.keys,
        scroll:
            autoScrollWhenFocusOnInvalid ?? this.autoScrollWhenFocusOnInvalid,
      );
    }

    return isValid;
  }

  /// Validates only [fields], e.g. the current step of a wizard, and returns
  /// whether they are all valid. Mounted fields show their error; fields that
  /// are not mounted are checked like in [validate].
  ///
  /// Focus and scroll behave like in [validate], among [fields].
  bool validateFields(
    Set<E> fields, {
    bool? focusOnInvalid,
    bool? autoScrollWhenFocusOnInvalid,
  }) {
    final context = _mountedFieldContext;
    // Validate every field, not up to the first invalid one: each mounted
    // field must show its error.
    final results = [
      for (final field in fields) _validateField(field, context),
    ];
    final isValid = results.every((valid) => valid);

    if (!isValid && (focusOnInvalid ?? this.focusOnInvalid)) {
      _focusFirstInvalidField(
        fields,
        scroll:
            autoScrollWhenFocusOnInvalid ?? this.autoScrollWhenFocusOnInvalid,
      );
    }

    return isValid;
  }

  /// Validates [field] through its [FormFieldState] when it is mounted.
  /// Otherwise runs its schema validators on the stored value; cross-field
  /// validators need [context] (any mounted field's) and are skipped
  /// without it.
  bool _validateField(E field, BuildContext? context) {
    if (_fieldKeys[field]?.currentState case final state?) {
      return state.validate();
    }
    if (_forcedErrors.containsKey(field)) {
      return false;
    }

    final value = getValue<Object?>(field);
    // Dynamic calls: the stored value's static type is unknown here, and
    // the validators' function types are narrower than `Object?`.
    return validators(field)?.every((validator) {
          final Object? error = switch (validator) {
            FieldValidator() => (validator as dynamic).validator(value),
            CrossFieldValidator() when context != null =>
              (validator as dynamic).validator(value, context),
            CrossFieldValidator() => null,
          };
          return error == null;
        }) ??
        true;
  }

  /// Focuses (and optionally scrolls to) the mounted field in error that is
  /// declared first in the enum, among [fields].
  void _focusFirstInvalidField(Iterable<E> fields, {required bool scroll}) {
    final invalidField = minBy(
      fields.where(
        (field) => _fieldKeys[field]?.currentState?.hasError ?? false,
      ),
      (field) => field.index,
    );

    if (invalidField == null) {
      return;
    }

    if (scroll) {
      if (_fieldKeys[invalidField]?.currentContext case final context?) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    _fieldFocusNodes[invalidField]?.requestFocus();
  }

  /// Clears the forced errors. When [notify] is `true`, the affected fields
  /// are revalidated so the forced error disappears right away.
  void clearForcedErrors({bool notify = true}) {
    final fields = _forcedErrors.keys.toList();
    _forcedErrors.clear();
    if (notify) {
      for (final field in fields) {
        _fieldKeys[field]?.currentState?.validate();
      }
    }
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
      entry.value.value = _initialValues[entry.key];
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

  /// Validates [field]. A field that is not mounted is checked by running
  /// its schema validators on its stored value.
  bool validateField(E field) {
    return _validateField(field, _mountedFieldContext);
  }

  /// Check if the form fields have been interacted with.
  bool isDirty(Set<E> fields) {
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
  Map<E, dynamic> getValues() {
    return _fieldKeys.map(
      (key, field) => MapEntry(key, _fieldNotifiers[key]?.value),
    );
  }
}
