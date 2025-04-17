import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/form_field_controller.dart';
import '../models/form_schema.dart';

/// A hook that provides a [FormFieldsController] to manage form field states.
///
///
/// The [FormFieldsController] is a [Listenable] that can be used to listen to
/// changes in the form field states and created from a [FormSchema] instance.
///
/// **Careful !**: this hook is a `flutter_hooks` hook and needs to be used
/// inside a [HookWidget]. For more information about `flutter_hooks`, please
/// refer to the [flutter_hooks documentation](https://pub.dev/packages/flutter_hooks).
FormFieldsController<F> useForm<F extends FormSchema>({
  required F formSchema,
  InitialFieldValues<F>? initialValues,
  List<Object?> keys = const <Object>[],
}) {
  final controller = useMemoized(
    () {
      return FormFieldsController<F>(
        GlobalKey<FormState>(debugLabel: 'FormFieldsController'),
        formSchema,
        initialValues: initialValues,
      );
    },
    [keys],
  );

  return useListenable(controller);
}
