import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hook_form/src/models/field_schema.dart';

import '../hooks/use_form_context.dart';
import '../models/form_field_controller.dart';
import '../validators/validators.dart';

/// A text form field that integrates with flutter_hook_form.
class const HookedTextFormField<F extends FieldSchema<String>>({
  super.key,

  /// The form controller, if provided directly.
  final FormFieldsController<FieldSchema<dynamic>>? _form,

  /// The field identifier from the form schema.
  required final F fieldHook,

  /// Optional error text to force the field into an error state.
  final String? forceErrorText,

  /// Optional validator function that overrides the form's validators.
  final String? Function(String?)? validator,

  /// Controls when auto-validation occurs.
  final AutovalidateMode? autovalidateMode,

  /// Whether the field is enabled.
  final bool? enabled,

  /// Initial value for the field.
  final String? initialValue,

  /// Callback when the form is saved.
  final void Function(String?)? onSaved,

  /// Restoration ID for saving and restoring the field state.
  final String? restorationId,

  /// The toolbar options for the text form field.
  @Deprecated(
    'Use `contextMenuBuilder` instead. '
    'This feature was deprecated after v3.3.0-0.5.pre.',
  )
  final ToolbarOptions? toolbarOptions,

  /// Whether to show the cursor.
  final bool? showCursor,

  /// The character to use when obscuring text.
  final String? obscuringCharacter,

  /// Whether to obscure text.
  final bool? obscureText,

  /// Whether to autocorrect text.
  final bool? autocorrect,

  /// The smart dashes type.
  final SmartDashesType? smartDashesType,

  /// The smart quotes type.
  final SmartQuotesType? smartQuotesType,

  /// Whether to enable suggestions.
  final bool? enableSuggestions,

  /// The max length enforcement.
  final MaxLengthEnforcement? maxLengthEnforcement,

  /// The maximum number of lines the text can have.
  final int? maxLines,

  /// The minimum number of lines the text can have.
  final int? minLines,

  /// Whether the text can expand to fit the content.
  final bool? expands,

  /// The maximum length of the text.
  final int? maxLength,

  /// The callback that is called when the text changes.
  final void Function(String)? onChanged,

  /// The callback that is called when the text is tapped.
  final void Function()? onTap,

  /// The callback that is called when the text is tapped always.
  final bool? onTapAlwaysCalled,

  /// The callback that is called when the text is tapped outside.
  final void Function(PointerDownEvent)? onTapOutside,

  /// The callback that is called when the text editing is completed.
  final VoidCallback? onEditingComplete,

  /// The callback that is called when the text field is submitted.
  final void Function(String)? onFieldSubmitted,

  /// The input formatters for the text form field.
  final List<TextInputFormatter>? inputFormatters,

  /// Whether to ignore pointers.
  final bool? ignorePointers,

  /// The width of the cursor.
  final double? cursorWidth,

  /// The height of the cursor.
  final double? cursorHeight,

  /// The radius of the cursor.
  final Radius? cursorRadius,

  /// The color of the cursor.
  final Color? cursorColor,

  /// The color of the cursor when there is an error.
  final Color? cursorErrorColor,

  /// The appearance of the keyboard.
  final Brightness? keyboardAppearance,

  /// The padding of the scroll view.
  final EdgeInsets? scrollPadding,

  /// Whether to enable interactive selection.
  final bool? enableInteractiveSelection,

  /// The selection controls for the text form field.
  final TextSelectionControls? selectionControls,

  /// The counter for the text form field.
  final Widget? Function(
    BuildContext, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  })?
  buildCounter,

  /// The scroll physics for the text form field.
  final ScrollPhysics? scrollPhysics,

  /// The autofill hints for the text form field.
  final List<String>? autofillHints,

  /// Whether to enable IME personalized learning.
  final bool? enableIMEPersonalizedLearning,

  /// The mouse cursor for the text form field.
  final MouseCursor? mouseCursor,

  /// The context menu builder for the text form field.
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder,

  /// The spell check configuration for the text form field.
  final SpellCheckConfiguration? spellCheckConfiguration,

  /// The undo controller for the text form field.
  final UndoHistoryController? undoController,

  /// The app private command for the text form field.
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand,

  /// Whether the cursor opacity animates.
  final bool? cursorOpacityAnimates,

  /// The selection height style for the text form field.
  final BoxHeightStyle? selectionHeightStyle,

  /// The selection width style for the text form field.
  final BoxWidthStyle? selectionWidthStyle,

  /// The drag start behavior for the text form field.
  final DragStartBehavior? dragStartBehavior,

  /// The content insertion configuration for the text form field.
  final ContentInsertionConfiguration? contentInsertionConfiguration,

  /// The states controller for the text form field.
  final WidgetStatesController? statesController,

  /// The clip behavior for the text form field.
  final Clip? clipBehavior,

  /// Whether to enable scribble.
  final bool? scribbleEnabled,

  /// Whether to enable request focus.
  final bool? canRequestFocus,

  /// Whether to autofocus the text form field.
  final bool? autofocus,

  /// The controller for the text form field.
  final TextEditingController? controller,

  /// The decoration for the text form field.
  final InputDecoration? decoration,

  /// The focus node for the text form field.
  final FocusNode? focusNode,

  /// The group id for the text form field.
  final Object? groupId,

  /// The keyboard type for the text form field.
  final TextInputType? keyboardType,

  /// Whether the text form field is read only.
  final bool? readOnly,

  /// The strut style for the text form field.
  final StrutStyle? strutStyle,

  /// The text alignment for the text form field.
  final TextAlign? textAlign,

  /// The text alignment vertical for the text form field.
  final TextAlignVertical? textAlignVertical,

  /// The text capitalization for the text form field.
  final TextCapitalization? textCapitalization,

  /// The text direction for the text form field.
  final TextDirection? textDirection,

  /// The text input action for the text form field.
  final TextInputAction? textInputAction,

  /// The style for the text form field.
  final TextStyle? style,

  /// The text style for the text form field.
  final TextStyle? textStyle,

  /// The magnifier configuration for the text form field.
  final TextMagnifierConfiguration? magnifierConfiguration,

  /// The scroll controller for the text form field.
  final ScrollController? scrollController,

  /// Whether to notify form listeners when the field value changes.
  ///
  /// Defaults to `true`. Required for [FormFieldsController.listen] to react
  /// to this field's changes. Set to `false` only if you need to suppress
  /// reactive updates for performance reasons.
  final bool notifyOnChange = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FormFieldsController<FieldSchema<dynamic>> form =
        _form ?? useFormContext(context);
    final typedField = fieldHook as FieldSchema<String>;

    return TextFormField(
      key: form.fieldKey(typedField),
      validator:
          validator ??
          (value) {
            final forcedError = form.getFieldForcedError(fieldHook);
            if (forcedError != null) {
              return forcedError.localize(
                context,
                form.getNotifier(typedField),
              );
            }
            return form
                .validators(fieldHook)
                ?.resolveMessage<String>(context)
                ?.call(value);
          },
      forceErrorText:
          forceErrorText ??
          form
              .getFieldForcedError(fieldHook)
              .localize(context, form.getNotifier(typedField)),
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      initialValue: form.getInitialValue(typedField) ?? initialValue,
      onSaved: onSaved,
      restorationId: restorationId,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter ?? '•',
      obscureText: obscureText ?? false,
      autocorrect: autocorrect ?? true,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions ?? true,
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines ?? 1,
      minLines: minLines,
      expands: expands ?? false,
      maxLength: maxLength,
      onChanged: (value) {
        onChanged?.call(value);
        form.updateValue(typedField, value, notify: notifyOnChange);
      },
      onTap: onTap,
      onTapAlwaysCalled: onTapAlwaysCalled ?? false,
      onTapOutside: onTapOutside,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      ignorePointers: ignorePointers,
      cursorWidth: cursorWidth ?? 2.0,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      cursorErrorColor: cursorErrorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding ?? const EdgeInsets.all(20),
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      buildCounter: buildCounter,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      scrollController: scrollController,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning ?? true,
      mouseCursor: mouseCursor,
      contextMenuBuilder: contextMenuBuilder,
      spellCheckConfiguration: spellCheckConfiguration,
      magnifierConfiguration: magnifierConfiguration,
      undoController: undoController,
      onAppPrivateCommand: onAppPrivateCommand,
      cursorOpacityAnimates: cursorOpacityAnimates,
      selectionHeightStyle: selectionHeightStyle ?? BoxHeightStyle.tight,
      selectionWidthStyle: selectionWidthStyle ?? BoxWidthStyle.tight,
      dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
      contentInsertionConfiguration: contentInsertionConfiguration,
      statesController: statesController,
      clipBehavior: clipBehavior ?? Clip.hardEdge,
      stylusHandwritingEnabled: scribbleEnabled ?? true,
      canRequestFocus: canRequestFocus ?? true,
      autofocus: autofocus ?? false,
      controller: controller,
      decoration: decoration,
      focusNode: focusNode,
      groupId: groupId ?? EditableText,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      strutStyle: strutStyle,
      textAlign: textAlign ?? TextAlign.start,
      textAlignVertical: textAlignVertical,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      textDirection: textDirection,
      textInputAction: textInputAction,
      style: style,
    );
  }
}
