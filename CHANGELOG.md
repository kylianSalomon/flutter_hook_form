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
