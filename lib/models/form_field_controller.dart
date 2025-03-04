import 'package:flutter/widgets.dart';

import 'form_schema.dart';
import 'types.dart';

/// A controller that manages form field states and validation
class FormFieldsController<F extends FormSchema> extends ChangeNotifier {
  FormFieldsController(
    this.key,
    F formSchema,
  ) : _formSchema = formSchema;

  final FormKey key;
  final F _formSchema;
  final _fieldKeys = <String, GlobalKey<FormFieldState>>{};
  final _forcedErrors = <String, String>{};

  /// Get or create a GlobalKey for a form field
  GlobalKey<FormFieldState<T>> fieldKey<T>(TypedId<T> fieldId) {
    return _fieldKeys.putIfAbsent(
      fieldId.id,
      () => GlobalKey<FormFieldState<T>>(debugLabel: '${fieldId.id}'),
    ) as GlobalKey<FormFieldState<T>>;
  }

  T? getValue<T>(TypedId<T> fieldId) {
    return _fieldKeys[fieldId.id]?.currentState?.value as T?;
  }

  T? updateValue<T>(TypedId<T> fieldId, T? value) {
    _fieldKeys[fieldId.id]?.currentState?.didChange(value);

    return value;
  }

  String? getFieldError<T>(TypedId<T> fieldId) {
    return _fieldKeys[fieldId.id]?.currentState?.errorText;
  }

  void setError<T>(TypedId<T> fieldId, String error) {
    _forcedErrors[fieldId.id] = error;
  }

  bool hasFieldError<T>(TypedId<T> fieldId) {
    return getFieldError(fieldId) != null;
  }

  ValidatorFn<T>? validators<T>(TypedId<T> fieldId) {
    return _formSchema.field(fieldId)?.validators;
  }

  bool validate() {
    _forcedErrors.clear();

    final isValid = key.currentState?.validate() ?? false;
    notifyListeners(); // Notify listeners after validation
    return isValid;
  }

  void save() {
    key.currentState?.save();
    notifyListeners(); // Notify listeners after save
  }

  Map<String, dynamic> getValues() {
    return _fieldKeys.map(
      (key, field) => MapEntry(key, field.currentState?.value),
    );
  }
}
