import 'package:flutter/widgets.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';
import 'package:flutter_hook_form/src/models/form_field_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Extension on [FormFieldsController] providing reactive field listening.
extension FormListenExtension<F extends FieldSchema<dynamic>>
    on FormFieldsController<F> {
  /// Listens to changes on the specified [fields] and rebuilds the widget
  /// when any of their values change.
  ///
  /// The [selector] receives a typed [get] accessor to read the current value
  /// of any field in [fields]. The return value of [selector] is returned
  /// by [listen].
  ///
  /// **Requires a [HookWidget] build context** — must be called inside a
  /// [HookWidget] or [HookBuilder], following the same rules as all hooks.
  ///
  /// ```dart
  /// // Single field
  /// final email = form.listen(
  ///   {Fields.email},
  ///   (get) => get<String>(Fields.email),
  /// );
  ///
  /// // Combined logic across multiple fields
  /// final canSubmit = form.listen(
  ///   {Fields.email, Fields.password},
  ///   (get) => get<String>(Fields.email) != null &&
  ///             get<String>(Fields.password) != null,
  /// );
  ///
  /// // Derived state
  /// final isEmpty = form.listen(
  ///   {Fields.firstName, Fields.lastName},
  ///   (get) => (get<String>(Fields.firstName) ?? '').isEmpty &&
  ///             (get<String>(Fields.lastName) ?? '').isEmpty,
  /// );
  /// ```
  R listen<R>(
    Set<F> fields,
    R Function(T? Function<T>(FieldSchema<T> field) get) selector,
  ) {
    final merged = useMemoized(
      () => Listenable.merge(fields.map(fieldListenable).toList()),
      [...fields],
    );
    useListenable(merged);

    T? getter<T>(FieldSchema<T> field) => getValue<T>(field);
    return selector(getter);
  }
}
