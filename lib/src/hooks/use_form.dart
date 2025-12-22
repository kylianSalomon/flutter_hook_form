import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';
import 'package:flutter_hook_form/src/models/form_field_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';


/// A hook that provides a [FormFieldsController] to manage form field states.
///
///
/// The [FormFieldsController] is a [Listenable] that can be used to listen to
/// changes in the form field states and created from a [FormSchema] instance.
///
/// **Careful !**: this hook is a `flutter_hooks` hook and needs to be used
/// inside a [HookWidget]. For more information about `flutter_hooks`, please
/// refer to the [flutter_hooks documentation](https://pub.dev/packages/flutter_hooks).
FormFieldsController<F> useForm<F extends FieldSchema>({
  InitialFieldValues<F, dynamic>? initialValues,
  List<Object?> keys = const <Object>[],
}) {
  final controller = useMemoized(() {
    return FormFieldsController<F>(
      GlobalKey<FormState>(debugLabel: 'FormFieldsController'),
      initialValues: initialValues,
    );
  }, keys);

  return useListenable(controller);
}
