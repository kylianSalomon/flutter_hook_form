import 'package:flutter/material.dart';
import 'package:flutter_hook_form/flutter_hook_form.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

enum SignUp { username, email, hasCompany, companyName }

/// Pumps a form rendering a [HookedTextFormField] for each of [textFields]
/// and returns its controller.
Future<FormFieldsController<SignUp>> pumpForm(
  WidgetTester tester, {
  Map<SignUp, FieldConfig> validators = const {},
  Set<SignUp> textFields = const {SignUp.username, SignUp.email},
  bool focusOnInvalid = false,
  ValidationMode validateOn = ValidationMode.disabled,
  Map<SignUp, AutovalidateMode> widgetModes = const {},
  List<Widget> children = const [],
}) async {
  late FormFieldsController<SignUp> controller;

  await tester.pumpWidget(
    MaterialApp(
      home: HookBuilder(
        builder: (context) {
          controller = useForm<SignUp>(
            validators: validators,
            focusOnInvalid: focusOnInvalid,
            autoScrollWhenFocusOnInvalid: false,
            validateOn: validateOn,
          );

          return Scaffold(
            body: HookedForm(
              form: controller,
              child: Column(
                children: [
                  for (final field in textFields)
                    HookedTextFormField<SignUp>(
                      fieldHook: field,
                      autovalidateMode: widgetModes[field],
                    ),
                  ...children,
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  return controller;
}

Finder textField(SignUp field) => find.byWidgetPredicate(
  (widget) =>
      widget is HookedTextFormField<SignUp> && widget.fieldHook == field,
);

void main() {
  group('Forced errors', () {
    testWidgets('a forced error disappears when the field changes', (
      tester,
    ) async {
      final form = await pumpForm(
        tester,
        validators: {.username: .required<String>()},
      );

      form.setError(.username, 'username_taken');
      await tester.pump();
      expect(find.text('username_taken'), findsOneWidget);

      await tester.enterText(textField(.username), 'john2');
      await tester.pump();

      expect(find.text('username_taken'), findsNothing);
      expect(form.getFieldForcedError(.username), isNull);
      expect(form.validate(), isTrue);
    });

    testWidgets('a forced error stays while the field does not change', (
      tester,
    ) async {
      final form = await pumpForm(tester);
      await tester.enterText(textField(.username), 'john');

      form.setError(.username, 'username_taken');
      await tester.enterText(textField(.email), 'john@doe.com');
      await tester.pump();

      expect(find.text('username_taken'), findsOneWidget);
      expect(form.validate(), isFalse);
    });

    testWidgets('setErrors shows every error and focuses the first field', (
      tester,
    ) async {
      final form = await pumpForm(tester, focusOnInvalid: true);

      // Map order differs from enum order on purpose.
      form.setErrors({.email: 'email_taken', .username: 'username_taken'});
      await tester.pump();

      expect(find.text('email_taken'), findsOneWidget);
      expect(find.text('username_taken'), findsOneWidget);
      expect(form.focusNodeFor(.username).hasFocus, isTrue);
      expect(form.focusNodeFor(.email).hasFocus, isFalse);
    });

    testWidgets('setErrors with notify: false stores without showing', (
      tester,
    ) async {
      final form = await pumpForm(tester, focusOnInvalid: true);

      form.setErrors({.username: 'username_taken'}, notify: false);
      await tester.pump();

      expect(find.text('username_taken'), findsNothing);
      expect(form.focusNodeFor(.username).hasFocus, isFalse);
      expect(form.getFieldForcedError(.username), 'username_taken');
    });

    testWidgets('setErrorsByName resolves names and ignores unknown keys', (
      tester,
    ) async {
      final form = await pumpForm(tester);

      form.setErrorsByName({'email': 'email_taken', 'unknown': 'nope'});
      await tester.pump();

      expect(find.text('email_taken'), findsOneWidget);
      expect(find.text('nope'), findsNothing);
    });

    testWidgets('clearForcedErrors respects notify', (tester) async {
      final form = await pumpForm(tester);

      form.setError(.username, 'username_taken');
      await tester.pump();
      form.clearForcedErrors(notify: false);
      await tester.pump();
      // Cleared, but the field was not refreshed.
      expect(form.getFieldForcedError(.username), isNull);
      expect(find.text('username_taken'), findsOneWidget);

      form.setError(.username, 'username_taken');
      await tester.pump();
      form.clearForcedErrors();
      await tester.pump();
      expect(find.text('username_taken'), findsNothing);
    });
  });

  group('Validation mode', () {
    testWidgets('validateOn in the schema drives the field', (tester) async {
      await pumpForm(
        tester,
        validators: {
          .email: .required<String>().email().validateOn(.onUserInteraction),
          .username: .required<String>().minLength(3),
        },
      );

      await tester.enterText(textField(.email), 'not-an-email');
      await tester.enterText(textField(.username), 'jo');
      await tester.pump();

      expect(find.text('Invalid email address'), findsOneWidget);
      expect(find.text('Must be at least 3 characters'), findsNothing);
    });

    testWidgets('the form default applies, the widget argument wins', (
      tester,
    ) async {
      await pumpForm(
        tester,
        validateOn: .onUserInteraction,
        widgetModes: {.username: .disabled},
        validators: {
          .email: .required<String>().email(),
          .username: .required<String>().minLength(3),
        },
      );

      await tester.enterText(textField(.email), 'not-an-email');
      await tester.enterText(textField(.username), 'jo');
      await tester.pump();

      expect(find.text('Invalid email address'), findsOneWidget);
      expect(find.text('Must be at least 3 characters'), findsNothing);
    });

    testWidgets('afterFirstUnfocus waits for the first unfocus after edit', (
      tester,
    ) async {
      final form = await pumpForm(
        tester,
        validators: {
          .email: .required<String>().email().validateOn(.afterFirstUnfocus),
        },
      );

      // Focusing and leaving without editing stays silent.
      await tester.tap(textField(.email));
      await tester.tap(textField(.username));
      await tester.pump();
      expect(find.text('Required'), findsNothing);

      await tester.tap(textField(.email));
      await tester.enterText(textField(.email), 'john@');
      await tester.pump();
      expect(find.text('Invalid email address'), findsNothing);

      // Leaving the field shows the error.
      form.focusNodeFor(.username).requestFocus();
      await tester.pump();
      expect(find.text('Invalid email address'), findsOneWidget);

      // From then on, every change revalidates.
      await tester.enterText(textField(.email), 'john@doe.com');
      await tester.pump();
      expect(find.text('Invalid email address'), findsNothing);

      await tester.enterText(textField(.email), '');
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('Wizard', () {
    Future<(FormFieldsController<SignUp>, PageController)> pumpWizard(
      WidgetTester tester,
    ) async {
      late FormFieldsController<SignUp> controller;
      final pages = PageController();
      addTearDown(pages.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useForm<SignUp>(
                focusOnInvalid: true,
                autoScrollWhenFocusOnInvalid: false,
                validators: {
                  .username: .required<String>(),
                  .email: .required<String>().email(),
                },
              );

              return Scaffold(
                body: HookedForm(
                  form: controller,
                  child: PageView(
                    controller: pages,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      HookedTextFormField<SignUp>(fieldHook: .username),
                      HookedTextFormField<SignUp>(fieldHook: .email),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      return (controller, pages);
    }

    /// Unfocuses first: a focused text field keeps its page alive.
    Future<void> goTo(WidgetTester tester, PageController pages, int page) {
      FocusManager.instance.primaryFocus?.unfocus();
      pages.jumpToPage(page);
      return tester.pumpAndSettle();
    }

    testWidgets('validateFields checks the current step only', (tester) async {
      final (form, _) = await pumpWizard(tester);

      expect(form.validateFields({.username}), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      expect(form.focusNodeFor(.username).hasFocus, isTrue);

      await tester.enterText(textField(.username), 'john');
      expect(form.validateFields({.username}), isTrue);
    });

    testWidgets('fields on other pages are checked on their stored value', (
      tester,
    ) async {
      final (form, pages) = await pumpWizard(tester);

      await tester.enterText(textField(.username), 'john');
      await goTo(tester, pages, 1);
      expect(form.fieldKey(.username).currentState, isNull);

      // username is not mounted, but its stored value is valid.
      expect(form.validateFields({.username}), isTrue);
      expect(form.validateField(.username), isTrue);

      await tester.enterText(textField(.email), 'john@doe.com');
      expect(form.validate(), isTrue);

      // An invalid value on an unmounted page fails the final validate.
      form.updateValue<String>(.username, '');
      expect(form.validateField(.username), isFalse);
      expect(form.validate(), isFalse);
    });

    testWidgets('a step never visited fails the final validate', (
      tester,
    ) async {
      final (form, _) = await pumpWizard(tester);

      await tester.enterText(textField(.username), 'john');

      expect(form.fieldKey(.email).currentState, isNull);
      expect(form.validate(), isFalse);
    });

    testWidgets('a forced error on another page shows when it mounts', (
      tester,
    ) async {
      final (form, pages) = await pumpWizard(tester);

      await tester.enterText(textField(.username), 'john');
      await goTo(tester, pages, 1);
      await tester.enterText(textField(.email), 'john@doe.com');
      expect(form.fieldKey(.username).currentState, isNull);

      form.setErrors({.username: 'username_taken'});
      expect(form.validate(), isFalse);

      await goTo(tester, pages, 0);
      expect(find.text('username_taken'), findsOneWidget);
    });
  });

  group('requiredIf', () {
    Future<FormFieldsController<SignUp>> pumpCompanyForm(
      WidgetTester tester, {
      AutovalidateMode? companyNameMode,
    }) {
      return pumpForm(
        tester,
        textFields: {},
        validators: {
          .hasCompany: .optional<bool>(),
          .companyName: .optional<String>().requiredIf(
            SignUp.hasCompany,
            (value) => value == true,
          ),
        },
        children: [
          HookedFormField<bool, SignUp>(
            fieldHook: .hasCompany,
            builder: (value, onChanged, _) => Checkbox(
              value: value ?? false,
              onChanged: onChanged,
            ),
          ),
          HookedTextFormField<SignUp>(
            fieldHook: .companyName,
            autovalidateMode: companyNameMode,
          ),
        ],
      );
    }

    testWidgets('requires the field only while the condition holds', (
      tester,
    ) async {
      final form = await pumpCompanyForm(tester);

      expect(form.validate(), isTrue);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      // Unchecking the source revalidates the field: the error goes away.
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(find.text('Required'), findsNothing);
      expect(form.validate(), isTrue);
    });

    testWidgets('revalidates a field that validates on interaction', (
      tester,
    ) async {
      await pumpCompanyForm(
        tester,
        companyNameMode: AutovalidateMode.onUserInteraction,
      );

      await tester.enterText(textField(.companyName), 'Acme');
      await tester.enterText(textField(.companyName), '');
      await tester.pump();
      expect(find.text('Required'), findsNothing);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('is checked on the stored value when not mounted', (
      tester,
    ) async {
      // companyName is never rendered.
      final form = await pumpForm(
        tester,
        textFields: {.username},
        validators: {
          .companyName: .optional<String>().requiredIf(
            SignUp.hasCompany,
            (value) => value == true,
          ),
        },
      );

      expect(form.validate(), isTrue);
      form.updateValue(.hasCompany, true);
      expect(form.validate(), isFalse);
      form.updateValue(.companyName, 'Acme');
      expect(form.validate(), isTrue);
    });
  });
}
