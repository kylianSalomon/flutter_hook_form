## 4.0.0

### Breaking Changes

* 💥 **New `FieldSchema` interface**: Form schemas now use an `enum` implementing the `FieldSchema<T>` interface instead of a class with `static final HookField` declarations.

  ```dart
  // Before (3.x)
  class MyFormSchema extends FormSchema {
    static final email = HookField<String>(validators: [RequiredValidator()]);
  }

  // After (4.0)
  enum MyFormSchema<T> implements FieldSchema<T> {
    email<String>(validators: [RequiredValidator(), EmailValidator()]);

    const MyFormSchema({this.validators});

    @override
    final List<Validator<T>>? validators;
  }
  ```

* 💥 **`useFormContext` no longer accepts a type parameter**: Drop the generic argument at all call sites.

  ```dart
  // Before
  final form = useFormContext<SignInFormFields>(context);
  // After
  final form = useFormContext(context);
  ```

* 💥 **`HookedFormField` type parameters updated**: Now requires `<F extends FieldSchema, T>` for improved type inference.

* 💥 **`getNotifier` return type narrowed to `ValueListenable<T?>`**: The value is now read-only from outside the controller; use `updateValue` to change it.

* 💥 **Dart SDK requirement upgraded**: Minimum Dart SDK version is now `^3.10.4`.

### New Features

* ✨ **`form.listen` extension for reactive field listening**: Subscribe to one or more fields and derive state — the widget rebuilds only when the watched fields change.

  ```dart
  // Single field
  final email = form.listen({Fields.email}, (get) => get<String>(Fields.email));

  // Derived state across multiple fields
  final canSubmit = form.listen(
    {Fields.email, Fields.password},
    (get) => get<String>(Fields.email) != null && get<String>(Fields.password) != null,
  );
  ```

* ✨ **Cross-field validation**: New `CrossFieldValidator<T>` base class plus built-in `MatchesValidator<T>` and `DateAfterValidator`.

* ✨ **New example project**: Comprehensive example demonstrating schemas, validation, and cross-field validation.

### Improvements

* ♻️ **Unified per-field notifier architecture**: `FormFieldsController` now uses a single `_FieldNotifier` per field, eliminating double-notify bugs.
* ♻️ **Simplified `getValue`**: Reads exclusively from the field's notifier, seeded from `initialValues`.
* ♻️ **`updateValue(notify: false)` writes silently** via `setSilently` — value is always stored even when listeners are suppressed.
* ♻️ **`reset` triggers a single notification per field**.

### Deprecated

* ⚠️ **`useFieldValue`**: Use `form.listen({field}, (get) => get<T>(field))` instead.

---

## 4.0.0-rc.3

### Breaking Changes

* 💥 **`useFormContext` no longer accepts a type parameter**: The hook is now untyped for simplicity. Update call sites by dropping the generic argument.

  **Before (rc.2):**
  ```dart
  final form = useFormContext<SignInFormFields>(context);
  ```

  **After (rc.3):**
  ```dart
  final form = useFormContext(context);
  ```

* 💥 **`getNotifier` return type narrowed to `ValueListenable<T?>`**: Previously returned `ValueNotifier<T?>`, which allowed external mutation. The value is now read-only from outside the controller; use `updateValue` to change it.

### Improvements

* ♻️ **Unified per-field notifier architecture**: `FormFieldsController` now uses a single `_FieldNotifier` per field (instead of two separate maps — one typed, one untyped). This eliminates a class of double-notify bugs and makes `form.listen`, `getNotifier`, and `updateValue` all share the same reactive source of truth.
* ♻️ **Simplified `getValue`**: No longer reads widget state as a side channel — the canonical value is always the field's notifier, seeded from `initialValues`.
* ♻️ **`updateValue(notify: false)` writes silently**: Uses `setSilently` instead of skipping the notifier entirely, so the value is always stored even when listeners are suppressed.
* ♻️ **`reset` triggers a single notification per field**: Reset no longer requires a separate loop over change-notifiers.

## 4.0.0-rc.1

### Breaking Changes

* 💥 **New `FieldSchema` interface**: Form schemas now use an `enum` implementing the `FieldSchema` interface instead of a class with `static final HookField` declarations. This reduces boilerplate and improves type safety.

  **Before (3.x):**
  ```dart
  class MyFormSchema extends FormSchema {
    static final email = HookField<String>(validators: [RequiredValidator()]);
    static final password = HookField<String>(validators: [MinLengthValidator(8)]);

    @override
    List<HookField> get fields => [email, password];
  }
  ```

  **After (4.x):**
  ```dart
  enum MyFormSchema<T> implements FieldSchema<T> {
    email<String>(validators: [RequiredValidator(), EmailValidator()]),
    password<String>(validators: [RequiredValidator(), MinLengthValidator(8)]);

    const MyFormSchema({this.validators});

    @override
    final List<Validator<T>>? validators;
  }
  ```

* 💥 **`HookedFormField` type parameters updated**: Now requires `<F extends FieldSchema, T>` for improved type inference across form field widgets.

* 💥 **Dart SDK requirement upgraded**: Minimum Dart SDK version is now `^3.10.4`.

### New Features

* ✨ **Cross-field validation support**: New `CrossFieldValidator<T>` base class enables validation that depends on other field values in the form.

* ✨ **New cross-field validators**:
  * `MatchesValidator<T>` - Validates that a field value matches another field (e.g., password confirmation)
  * `DateAfterValidator` - Validates that a date field is after another date field

* ✨ **New example project**: Added a comprehensive example project demonstrating form schemas, validation, and cross-field validation.

## 3.0.1

* 📝: Update README.md to include instructions for creating a schema and overriding fields in FormSchema

## 3.0.0

### Breaking changes

* 💥 **FormSchema** generator has been removed as the generated code did not justify keeping the generator. Indeed, the only perk of the generator was to avoid having to write by hand the id of each hook field.

Migration guide: Simply expose the generated form schema and remove the file that was used for generation.

## 2.0.8

### Improvements

* 📝 : update code comments to pass static analysis.

## 2.0.7

### Fix

* 🐛 Fix "_type 'LabeledGlobalKey<T>' is not a subtype of type 'GlobalKey<R>_" error that occured when using `isDirty` function.

## 2.0.6

* 🔧 Upgrade dart SDK to ^3.8.0

## 2.0.5

### Fix

* 🐛 Missing default return when localizing forced error code.

## 2.0.4

### Improvements

* Update path dependency version constraint to allow for minor updates

## 2.0.3

### Improvements

* 🐛 Fix unnecessary array creation in useForm hook keys parameter.

## 2.0.2

### Improvements

* ♻️ Update initialization business logic to avoid loosing initial value state on rebuild.

## 2.0.1

### Improvements

* 🐛 Fix `MimeTypeValidator` for failing on valid files.

## 2.0.0

### Breaking changes

* 💥 `FormProvider` has been renamed to `HookedFormProvider`
* 💥 `FormFieldScheme` and `HookedFieldId` have been merged into `HookField`
* 💥 `FormSchema` now declare a `fields` property to setup form fiels instead of using `super` constructor
* 💥 `builder` syntax has changed on `HookedFormField` allowing to declare anonymous parameters.

### Improvements

* 🐛 Fix `PatternValidator` for failing on empty strings. Now fails only on non-empty values.

### New Features

* ✨ `FormController` can now be initialized
  * Generated `FormSchema` declare a static to initialized each `HookField`
  * `withInitialValue` method has been added to `HookField` to initialized a hook field with a given value.

## 1.1.1

### Improvements

* ✨ Enhanced `FormFieldsController` with improved validation and error handling:
  * Added optional `notify` and `clearErrors` parameters to `validate()` method for more control
  * Added `setError()` method with `notify` parameter to control rebuilds
  * Introduced `clearForcedErrors()` method to manage form errors independently
  * Added new state tracking properties:
    * `hasBeenInteracted` - Detects if any field has been interacted with by user
    * `hasChanged` - Checks if any field value differs from its initial value

### Fix

* 🐛 Update form generator to correctly identify closing brackets for generic types in annotations.

## 1.1.0

### New Features

* ✨ Introduced `HookedFieldId<F, T>` with generic type parameters for improved type safety:
  * The form schema type `F` is now included in the field ID
  * This enables better type inference when using form fields
  * No need to specify form schema type in most widget usages

* 🔄 Added reactive form capabilities:
  * Form controller now properly notifies listeners when field values change
  * Added `registerFieldChange` method to track field modifications
  * Added methods to check if fields are dirty: `isDirty`, `areAnyDirty`, `areAllDirty`

* ✨ Introduced `HookedFormField` and `HookedTextFormField`:
  * Updated to use the new `fieldHook` parameter instead of `fieldKey`
  * Better type inference from field hooks
  * Added support for tracking field changes

### Improvements

* 📝 Comprehensive documentation updates:
  * Added examples for custom form fields
  * Improved explanation of form initialization
  * Added section on writing custom form fields
  * Updated code examples to use the latest API

* 🐛 Fixed validation issues:
  * Resolved bug where forced errors took precedence over validation errors
  * Improved error clearing during validation
  * Better handling of field rebuilds after validation

### Breaking Changes

* 🔄 Renamed parameter from `fieldKey` to `fieldHook` in form field widgets
  * Update your code to use `fieldHook: MySchema.field` instead of `fieldKey: MySchema.field`
  * This change better reflects the purpose of the parameter

## 1.0.0

### Breaking Changes

* ⚠️ Validator usage has been updated to support internationalization:
  * Validators are now declared in a list instead of being chained in a function.
  * Validators now return `errorCode` instead of error messages
  * Error messages are handled through the `FormErrorMessages` class
  * Custom validators need to extend `Validator<T>` and provide an `errorCode`
  * See the [documentation](README.md#custom-validation-messages--internationalization) for migration details

* ✨ Add code generation support for form schemas
* 🌍 Add built-in internationalization support
* 🛠️ Improve code organization and maintainability

## 0.0.4

* Add comprehensive documentation
* Update exports
* Add example for package demonstration

## 0.0.3

* Downgrade mime package to 1.0.6

## 0.0.2

* Add test suite and improve comments

## 0.0.1

* Init project
