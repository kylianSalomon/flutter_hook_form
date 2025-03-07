import 'package:flutter/widgets.dart';

import '../models/types.dart';
import '../models/validator.dart';

/// An extension on the [ValidatorFn] type.
extension CommonValidators<T> on ValidatorFn<T> {
  /// Localize the validator function.
  ValidatorFn2<T> localize(BuildContext context) =>
      (T? value) => this.call(value, context);
}
