import 'package:flutter/widgets.dart';

/// A type alias for a form key.
typedef FormKey = GlobalKey<FormState>;

/// A type alias for a validator function.
typedef ValidatorFn<T> = String? Function(T? value, BuildContext context);

/// A type alias for a validator function.
typedef ValidatorFn2<T> = String? Function(T? value);

/// A type alias for a form validator.
typedef FormValidator<E> = String? Function(
  Map<E, GlobalKey<FormFieldState>> fields,
);
