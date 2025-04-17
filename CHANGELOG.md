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
