import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';

import '../models/form_field_controller.dart';

/// Internal InheritedWidget that provides the [FormFieldsController] to descendants.
///
/// This is a simple provider - granular field listening is handled by
/// [ValueNotifier]s in the controller, accessed via [useFieldValue].
class const _HookedFormProviderBase({
  required super.child,
  required final FormFieldsController form,
}) extends InheritedWidget {
  static FormFieldsController<FieldSchema> of(
    BuildContext context,
  ) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<_HookedFormProviderBase>();

    if (widget == null) {
      throw FlutterError(
        'HookedFormProvider.of() called with a context that does not contain a HookedFormProvider.\n'
        'No HookedFormProvider ancestor could be found starting from the context that was passed to '
        'HookedFormProvider.of(). This can happen if the context you use comes from a widget above the '
        'HookedFormProvider.\n'
        'The context used was:\n'
        '  $context',
      );
    }

    return widget.form;
  }

  @override
  bool updateShouldNotify(covariant _HookedFormProviderBase oldWidget) {
    return form != oldWidget.form;
  }
}

/// Provides a [FormFieldsController] to descendant widgets.
///
/// Use [useFormContext] to access the controller from descendants.
/// For granular field listening, use [useFieldValue] instead.
///
/// ```dart
/// HookedFormProvider<MyFields>(
///   form: myFormController,
///   child: MyFormWidget(),
/// )
/// ```
class const HookedFormProvider<F extends FieldSchema<dynamic>>({
  super.key,

  /// The form controller.
  required final FormFieldsController<F> form,

  /// The child of the form.
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HookedFormProviderBase(form: form, child: child);
  }
}

/// A hook that provides access to the [FormFieldsController] from context.
///
/// Use this hook to access the [FormFieldsController] from the [HookedFormProvider].
///
/// **Note**: This hook does NOT trigger rebuilds when field values change.
/// For granular field listening, use [useFieldValue] instead:
///
/// ```dart
/// // Access the form controller (no automatic rebuilds on value changes)
/// final form = useFormContext<MyFields>(context);
///
/// // Listen to a specific field (rebuilds only when this field changes)
/// final email = useFieldValue<MyFields, String>(form, MyFields.email);
/// ```
///
/// DO NOT use this hook to create a [FormFieldsController], please see
/// [useForm] instead.
FormFieldsController<FieldSchema> useFormContext(
  BuildContext context,
) {
  return _HookedFormProviderBase.of(context);
}
