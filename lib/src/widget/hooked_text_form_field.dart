import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hooks/use_form_context.dart';
import '../models/form_field_controller.dart';
import '../models/form_schema.dart';
import '../validators/validators.dart';
import 'hooked_form.dart';

/// A text form field that integrates with flutter_hook_form.
class HookedTextFormField<F extends FormSchema> extends StatelessWidget {
  /// Creates a [HookedTextFormField] that gets the form from context.
  ///
  /// This widget wraps a standard [TextFormField] and connects it to a [FormFieldsController].
  ///
  /// Use the recommended [HookedForm] to wrap your form to provide the form
  /// controller to this widget. If not, use [HookedTextFormField.explicit] to provide
  /// the form controller explicitly.
  ///
  /// If you want to notify the form when the field value changes, set
  /// [notifyOnChange] to `true`.
  /// ```dart
  /// /// Recommended
  /// HookedForm( // <--- Form is provided via context
  ///   form: form,
  ///   child: HookedTextFormField<MyFormSchema>(
  ///     fieldKey: MyFormSchema.fieldKey,
  ///     builder: (field) => MyWidget(field: field),
  ///   ),
  /// )
  ///
  /// /// Alternative
  /// Form(
  ///   key: form.key,
  ///   child: HookedTextFormField.explicit(
  ///     form: form, // <--- Form is provided explicitly
  ///     fieldKey: MyFormSchema.fieldKey,
  ///     builder: (field) => MyWidget(field: field),
  ///   ),
  /// )
  /// ```
  const HookedTextFormField({
    super.key,
    required this.fieldHook,
    this.forceErrorText,
    this.validator,
    this.autovalidateMode,
    this.enabled,
    this.initialValue,
    this.onSaved,
    this.restorationId,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    this.toolbarOptions,
    this.showCursor,
    this.obscuringCharacter,
    this.obscureText,
    this.autocorrect,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions,
    this.maxLengthEnforcement,
    this.maxLines,
    this.minLines,
    this.expands,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapAlwaysCalled,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.ignorePointers,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.scrollPadding,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.enableIMEPersonalizedLearning,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.undoController,
    this.onAppPrivateCommand,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.dragStartBehavior,
    this.contentInsertionConfiguration,
    this.statesController,
    this.clipBehavior,
    this.scribbleEnabled,
    this.canRequestFocus,
    this.autofocus,
    this.controller,
    this.decoration,
    this.focusNode,
    this.groupId,
    this.keyboardType,
    this.readOnly,
    this.strutStyle,
    this.textAlign,
    this.textAlignVertical,
    this.textCapitalization,
    this.textDirection,
    this.textInputAction,
    this.style,
    this.textStyle,
    this.magnifierConfiguration,
    this.scrollController,
    this.notifyOnChange = false,
  }) : _form = null;

  /// Creates a [HookedTextFormField] with an explicitly provided form.
  ///
  /// Consider using [HookedTextFormField.explicit] if you did not use [HookedForm] to
  /// wrap your form or use [FormProvider] to provide the form.
  ///
  /// If you want to notify the form when the field value changes, set
  /// [notifyOnChange] to `true`.
  ///
  /// ```dart
  /// /// Recommended way of using the [HookedTextFormField.explicit] constructor
  /// Form(
  ///   key: form.key,
  ///   child: HookedTextFormField.explicit(
  ///     fieldKey: MyFormSchema.fieldKey,
  ///     form: form,
  ///   ),
  /// )
  ///
  /// /// Works but not recommended
  /// HookedForm(
  ///   form: form,
  ///   child: HookedTextFormField.explicit(// <-- Should use regular constructor
  ///     fieldKey: MyFormSchema.fieldKey,
  ///     form: form,
  ///   ),
  /// )
  const HookedTextFormField.explicit({
    super.key,
    required this.fieldHook,
    required FormFieldsController<F> form,
    this.forceErrorText,
    this.validator,
    this.autovalidateMode,
    this.enabled,
    this.initialValue,
    this.onSaved,
    this.restorationId,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    this.toolbarOptions,
    this.showCursor,
    this.obscuringCharacter,
    this.obscureText,
    this.autocorrect,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions,
    this.maxLengthEnforcement,
    this.maxLines,
    this.minLines,
    this.expands,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapAlwaysCalled,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.ignorePointers,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.scrollPadding,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.enableIMEPersonalizedLearning,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.undoController,
    this.onAppPrivateCommand,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.dragStartBehavior,
    this.contentInsertionConfiguration,
    this.statesController,
    this.clipBehavior,
    this.scribbleEnabled,
    this.canRequestFocus,
    this.autofocus,
    this.controller,
    this.decoration,
    this.focusNode,
    this.groupId,
    this.keyboardType,
    this.readOnly,
    this.strutStyle,
    this.textAlign,
    this.textAlignVertical,
    this.textCapitalization,
    this.textDirection,
    this.textInputAction,
    this.style,
    this.textStyle,
    this.magnifierConfiguration,
    this.scrollController,
    this.notifyOnChange = false,
  }) : _form = form;

  /// The form controller, if provided directly.
  final FormFieldsController<F>? _form;

  /// The field identifier from the form schema.
  final HookField<F, String> fieldHook;

  /// Optional error text to force the field into an error state.
  final String? forceErrorText;

  /// Optional validator function that overrides the form's validators.
  final String? Function(String?)? validator;

  /// Controls when auto-validation occurs.
  final AutovalidateMode? autovalidateMode;

  /// Whether the field is enabled.
  final bool? enabled;

  /// Initial value for the field.
  final String? initialValue;

  /// Callback when the form is saved.
  final void Function(String?)? onSaved;

  /// Restoration ID for saving and restoring the field state.
  final String? restorationId;

  /// The toolbar options for the text form field.
  @Deprecated(
    'Use `contextMenuBuilder` instead. '
    'This feature was deprecated after v3.3.0-0.5.pre.',
  )
  final ToolbarOptions? toolbarOptions;

  /// Whether to show the cursor.
  final bool? showCursor;

  /// The character to use when obscuring text.
  final String? obscuringCharacter;

  /// Whether to obscure text.
  final bool? obscureText;

  /// Whether to autocorrect text.
  final bool? autocorrect;

  /// The smart dashes type.
  final SmartDashesType? smartDashesType;

  /// The smart quotes type.
  final SmartQuotesType? smartQuotesType;

  /// Whether to enable suggestions.
  final bool? enableSuggestions;

  /// The max length enforcement.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// The maximum number of lines the text can have.
  final int? maxLines;

  /// The minimum number of lines the text can have.
  final int? minLines;

  /// Whether the text can expand to fit the content.
  final bool? expands;

  /// The maximum length of the text.
  final int? maxLength;

  /// The callback that is called when the text changes.
  final void Function(String)? onChanged;

  /// The callback that is called when the text is tapped.
  final void Function()? onTap;

  /// The callback that is called when the text is tapped always.
  final bool? onTapAlwaysCalled;

  /// The callback that is called when the text is tapped outside.
  final void Function(PointerDownEvent)? onTapOutside;

  /// The callback that is called when the text editing is completed.
  final VoidCallback? onEditingComplete;

  /// The callback that is called when the text field is submitted.
  final void Function(String)? onFieldSubmitted;

  /// The input formatters for the text form field.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to ignore pointers.
  final bool? ignorePointers;

  /// The width of the cursor.
  final double? cursorWidth;

  /// The height of the cursor.
  final double? cursorHeight;

  /// The radius of the cursor.
  final Radius? cursorRadius;

  /// The color of the cursor.
  final Color? cursorColor;

  /// The color of the cursor when there is an error.
  final Color? cursorErrorColor;

  /// The appearance of the keyboard.
  final Brightness? keyboardAppearance;

  /// The padding of the scroll view.
  final EdgeInsets? scrollPadding;

  /// Whether to enable interactive selection.
  final bool? enableInteractiveSelection;

  /// The selection controls for the text form field.
  final TextSelectionControls? selectionControls;

  /// The counter for the text form field.
  final Widget? Function(BuildContext,
      {required int currentLength,
      required bool isFocused,
      required int? maxLength})? buildCounter;

  /// The scroll physics for the text form field.
  final ScrollPhysics? scrollPhysics;

  /// The autofill hints for the text form field.
  final List<String>? autofillHints;

  /// Whether to enable IME personalized learning.
  final bool? enableIMEPersonalizedLearning;

  /// The mouse cursor for the text form field.
  final MouseCursor? mouseCursor;

  /// The context menu builder for the text form field.
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;

  /// The spell check configuration for the text form field.
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// The undo controller for the text form field.
  final UndoHistoryController? undoController;

  /// The app private command for the text form field.
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand;

  /// Whether the cursor opacity animates.
  final bool? cursorOpacityAnimates;

  /// The selection height style for the text form field.
  final BoxHeightStyle? selectionHeightStyle;

  /// The selection width style for the text form field.
  final BoxWidthStyle? selectionWidthStyle;

  /// The drag start behavior for the text form field.
  final DragStartBehavior? dragStartBehavior;

  /// The content insertion configuration for the text form field.
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// The states controller for the text form field.
  final WidgetStatesController? statesController;

  /// The clip behavior for the text form field.
  final Clip? clipBehavior;

  /// Whether to enable scribble.
  final bool? scribbleEnabled;

  /// Whether to enable request focus.
  final bool? canRequestFocus;

  /// Whether to autofocus the text form field.
  final bool? autofocus;

  /// The controller for the text form field.
  final TextEditingController? controller;

  /// The decoration for the text form field.
  final InputDecoration? decoration;

  /// The focus node for the text form field.
  final FocusNode? focusNode;

  /// The group id for the text form field.
  final Object? groupId;

  /// The keyboard type for the text form field.
  final TextInputType? keyboardType;

  /// Whether the text form field is read only.
  final bool? readOnly;

  /// The strut style for the text form field.
  final StrutStyle? strutStyle;

  /// The text alignment for the text form field.
  final TextAlign? textAlign;

  /// The text alignment vertical for the text form field.
  final TextAlignVertical? textAlignVertical;

  /// The text capitalization for the text form field.
  final TextCapitalization? textCapitalization;

  /// The text direction for the text form field.
  final TextDirection? textDirection;

  /// The text input action for the text form field.
  final TextInputAction? textInputAction;

  /// The style for the text form field.
  final TextStyle? style;

  /// The text style for the text form field.
  final TextStyle? textStyle;

  /// The magnifier configuration for the text form field.
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// The scroll controller for the text form field.
  final ScrollController? scrollController;

  /// Whether to notify form listeners when the field value changes.
  ///
  /// Default to `false` to avoid any unwanted rebuilds.
  final bool notifyOnChange;

  @override
  Widget build(BuildContext context) {
    final form = _form ?? useFormContext<F>(context);

    return TextFormField(
      key: form.fieldKey(fieldHook),
      validator: validator ?? form.validators(fieldHook)?.localize(context),
      forceErrorText: forceErrorText ??
          forceErrorText ??
          form
              .getFieldForcedError(fieldHook)
              .localize(context, form.getValue(fieldHook)),
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      initialValue: form.getValue(fieldHook) ?? initialValue,
      onSaved: onSaved,
      restorationId: restorationId,
      toolbarOptions: toolbarOptions,
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
        form.updateValue(fieldHook, value, notify: notifyOnChange);
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
      scribbleEnabled: scribbleEnabled ?? true,
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
