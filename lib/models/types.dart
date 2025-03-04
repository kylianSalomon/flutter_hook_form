import 'package:flutter/widgets.dart';

typedef FormKey = GlobalKey<FormState>;
typedef ValidatorFn<T> = String? Function(T? value, BuildContext context);
typedef ValidatorFn2<T> = String? Function(T? value);
typedef FormValidator<E> = String? Function(
  Map<E, GlobalKey<FormFieldState>> fields,
);
