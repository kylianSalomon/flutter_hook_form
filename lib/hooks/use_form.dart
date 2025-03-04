import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/form_field_controller.dart';
import '../models/form_schema.dart';

/// A hook that provides a [FormFieldsController] to manage form field states.
///
/// This hook is used to create a [FormFieldsController] instance that can be
/// used to manage the state of form fields.
///
/// The [FormFieldsController] is a [Listenable] that can be used to listen to
/// changes in the form field states.
///
/// Be aware that this hook is a `flutter_hooks` hook and needs to be used
/// inside a [HookWidget]. For more information about `flutter_hooks`, please
/// refer to the [flutter_hooks documentation](https://pub.dev/packages/flutter_hooks).
FormFieldsController<F> useForm<F extends FormSchema>({
  required F formSchema,
}) {
  final controller = useMemoized(
    () {
      return FormFieldsController<F>(
        GlobalKey<FormState>(debugLabel: 'FormFieldsController'),
        formSchema,
      );
    },
  );

  return useListenable(controller);
}
