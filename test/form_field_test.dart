// DartNative has no WidgetTester: these tests drive the FormField's State by
// hand (mount, builds) with the SDK's stateSet* helpers.

import 'package:dartnative/dartnative.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hook_form/src/widget/form_field.dart';
import 'package:test/test.dart';

class _Context implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String? _required(String? value) =>
    (value == null || value.isEmpty) ? 'required' : null;

class _Host {
  _Host(ValidationMode mode, {this.focusNode}) {
    final widget = FormField<String>(
      validator: _required,
      validationMode: mode,
      focusNode: focusNode,
      builder: (_) => const SizedBox(),
    );
    state = widget.createState() as FormFieldState<String>;
    stateSetWidget(state, widget);
    stateSetContext(state, _context);
    stateSetMarkDirty(state, (_) {});
    stateSetMounted(state, value: true);
    state.initState();
    build();
  }

  final FocusNode? focusNode;
  final _context = _Context();
  late final FormFieldState<String> state;

  void build() => state.build(_context);

  /// A user edit followed by the rebuild it schedules.
  void type(String value) {
    state.didChange(value);
    build();
  }
}

void main() {
  test('disabled validates only on validate()', () {
    final host = _Host(ValidationMode.disabled);
    host.type('');
    expect(host.state.errorText, isNull);

    expect(host.state.validate(), isFalse);
    expect(host.state.errorText, 'required');
  });

  test('always validates on every build', () {
    final host = _Host(ValidationMode.always);
    expect(host.state.errorText, 'required');
  });

  test('onUserInteraction validates once edited', () {
    final host = _Host(ValidationMode.onUserInteraction);
    expect(host.state.errorText, isNull);

    host.type('');
    expect(host.state.errorText, 'required');
    host.type('a');
    expect(host.state.errorText, isNull);
  });

  test('onUserInteractionIfError clears the error but does not raise it', () {
    final host = _Host(ValidationMode.onUserInteractionIfError);
    host.type('');
    expect(host.state.errorText, isNull);

    host.state.validate();
    host.type('a');
    expect(host.state.errorText, isNull);
    host.type('');
    expect(host.state.errorText, isNull);
  });

  test('afterFirstUnfocus waits for the user to leave the field', () {
    final node = FocusNode();
    final host = _Host(ValidationMode.afterFirstUnfocus, focusNode: node);

    node.setHasFocusFromNative(true);
    host.type('');
    expect(host.state.errorText, isNull);

    node.setHasFocusFromNative(false);
    host.build();
    expect(host.state.errorText, 'required');
    expect(host.state.validatesOnChange, isTrue);

    host.type('a');
    expect(host.state.errorText, isNull);
  });

  test('afterFirstUnfocus ignores leaving an untouched field', () {
    final node = FocusNode();
    final host = _Host(ValidationMode.afterFirstUnfocus, focusNode: node);

    node.setHasFocusFromNative(true);
    node.setHasFocusFromNative(false);
    host.build();
    expect(host.state.errorText, isNull);
  });

  test('onUnfocus validates when the field loses the focus', () {
    final node = FocusNode();
    final host = _Host(ValidationMode.onUnfocus, focusNode: node);

    node.setHasFocusFromNative(true);
    host.type('');
    expect(host.state.errorText, isNull);

    node.setHasFocusFromNative(false);
    expect(host.state.errorText, 'required');
  });

  test('reset restores the initial value and clears the error', () {
    final host = _Host(ValidationMode.onUserInteraction);
    host.type('');
    expect(host.state.hasError, isTrue);

    host.state.reset();
    host.build();
    expect(host.state.value, isNull);
    expect(host.state.hasError, isFalse);
    expect(host.state.hasInteractedByUser, isFalse);
  });
}
