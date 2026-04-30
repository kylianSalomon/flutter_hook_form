import 'package:flutter_hook_form/src/models/field_schema.dart';
import 'package:flutter_hook_form/src/models/form_field_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A hook that listens to a specific field's value changes.
///
/// This hook provides granular reactivity - the widget will only rebuild
/// when the specified field's value changes, not when other fields change.
///
/// ```dart
/// class MyWidget extends HookWidget {
///   @override
///   Widget build(BuildContext context) {
///     final form = useFormContext<SignInFields>(context);
///
///     // This widget rebuilds ONLY when email changes
///     final email = useFieldValue<SignInFields, String>(form, SignInFields.email);
///
///     return Text('Email: $email');
///   }
/// }
/// ```
///
/// For listening to multiple fields, call the hook multiple times:
///
/// ```dart
/// final email = useFieldValue(form, SignInFields.email);
/// final password = useFieldValue(form, SignInFields.password);
/// ```
///
/// **Note**: This hook requires `flutter_hooks` and must be used inside a
/// [HookWidget] or a widget that uses [HookBuilder].
@Deprecated(
  'Use form.listen({field}, (get) => get<T>(field)) instead. '
  'Deprecated in 4.0.0.',
)
T? useFieldValue<F extends FieldSchema<dynamic>, T>(
  FormFieldsController<F> form,
  F field,
) {
  final notifier = form.getNotifier<T>(field as FieldSchema<T>);
  return useValueListenable(notifier);
}
