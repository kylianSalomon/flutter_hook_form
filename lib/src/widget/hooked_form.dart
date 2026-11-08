import 'package:dartnative/dartnative.dart';

import '../hooks/use_form_context.dart';
import '../models/form_field_controller.dart';

/// A form that integrates with flutter_hook_form.
///
/// Provides a [FormFieldsController] to its children via [HookedFormProvider].
/// DartNative has no `Form` widget: the controller drives the fields itself.
class HookedForm<E extends Enum> extends StatelessWidget {
  /// Creates a [HookedForm].
  const HookedForm({super.key, required this.form, required this.child});

  /// The form controller.
  final FormFieldsController<E> form;

  /// The child of the form.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HookedFormProvider<E>(form: form, child: child);
  }
}
