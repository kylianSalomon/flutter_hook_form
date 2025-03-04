import 'package:collection/collection.dart';

import 'types.dart';

class FormFieldScheme<T> {
  const FormFieldScheme(
    this.id, {
    this.validators,
  });

  final TypedId<T> id;
  final ValidatorFn<T>? validators;
}

class TypedId<T> {
  const TypedId(this.id);

  final String id;
}

abstract class FormSchema {
  const FormSchema({
    required this.fields,
  });

  final Set<FormFieldScheme> fields;

  FormFieldScheme<T>? field<T>(TypedId<T> id) {
    return fields.firstWhereOrNull((e) => e.id == id) as FormFieldScheme<T>?;
  }
}
