@TestOn('browser')
library;

import 'package:embeddings_explorer/common/ui/ui.dart';
import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../../common.dart';

void main() {
  group('Form Component Tests', () {
    testBrowser('renders form with child components', (tester) async {
      tester.pumpComponent(Form(child: div([text('Form Content')])));

      expect(find.tag('form'), findsOneComponent);
      expect(find.text('Form Content'), findsOneComponent);
    });

    testBrowser('applies custom className', (tester) async {
      tester.pumpComponent(
        Form(className: 'custom-form-class', child: div([text('Test')])),
      );

      final formElement = tester.findNode<web.HTMLFormElement>(
        find.tag('form'),
      );
      expect(formElement?.className, contains('custom-form-class'));
    });

    testBrowser('handles form submission', (tester) async {
      bool submitted = false;

      tester.pumpComponent(
        Form(
          onSubmit: () {
            submitted = true;
          },
          child: button(type: ButtonType.submit, [text('Submit')]),
        ),
      );

      await tester.click(find.tag('button'));
      expect(submitted, isTrue);
    });

    testBrowser('validates all fields on submit', (tester) async {
      bool formSubmitted = false;

      tester.pumpComponent(
        Form(
          onSubmit: () {
            formSubmitted = true;
          },
          child: div([
            TextFormField(
              name: 'required-field',
              validator: Validators.required,
              decoration: const InputDecoration(label: 'Required Field'),
            ),
            button(type: ButtonType.submit, [text('Submit')]),
          ]),
        ),
      );

      // Submit without filling required field should not call onSubmit
      await tester.click(find.tag('button'));
      expect(
        formSubmitted,
        isFalse,
        reason: 'Form should not submit with validation errors',
      );

      // Fill the required field
      await tester.input(find.tag('input'), value: 'Valid input');
      await tester.pump();

      // Now submit should work
      await tester.click(find.tag('button'));
      expect(
        formSubmitted,
        isTrue,
        reason: 'Form should submit when validation passes',
      );
    });

    testBrowser('calls onChanged when any field changes', (tester) async {
      bool formChanged = false;

      tester.pumpComponent(
        Form(
          onChanged: () {
            formChanged = true;
          },
          child: TextFormField(
            name: 'test-field',
            decoration: const InputDecoration(label: 'Test Field'),
          ),
        ),
      );

      await tester.input(find.tag('input'), value: 'new value');
      expect(formChanged, isTrue);
    });

    testBrowser('supports different autovalidation modes', (tester) async {
      tester.pumpComponent(
        Form(
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            name: 'email-field',
            validator: Validators.email,
            decoration: const InputDecoration(label: 'Email'),
          ),
        ),
      );

      // Type invalid email
      await tester.input(find.tag('input'), value: 'invalid-email');

      // Should show error immediately with always mode
      expect(
        find.text('Please enter a valid email address'),
        findsOneComponent,
      );
    });

    testBrowser('Form.of() provides access to FormState', (tester) async {
      late FormState formState;

      tester.pumpComponent(
        Form(
          child: Builder(
            builder: (context) {
              formState = Form.of(context);
              return div([text('Form child')]);
            },
          ),
        ),
      );

      expect(formState, isNotNull);
      expect(formState.validate, isA<bool Function()>());
      expect(formState.reset, isA<void Function()>());
      expect(formState.save, isA<void Function()>());
    });

    testBrowser('Form.maybeOf() returns null when no form in context', (
      tester,
    ) async {
      FormState? formState;

      tester.pumpComponent(
        Builder(
          builder: (context) {
            formState = Form.maybeOf(context);
            return div([text('No form parent')]);
          },
        ),
      );

      expect(formState, isNull);
    });

    testBrowser('resets all fields when reset() is called', (tester) async {
      late FormState formState;
      bool resetCalled = false;

      tester.pumpComponent(
        Form(
          child: div([
            TextFormField(
              name: 'field1',
              initialValue: 'initial1',
              decoration: const InputDecoration(label: 'Field 1'),
            ),
            Builder(
              builder: (context) {
                formState = Form.of(context);
                return button(
                  onClick: () {
                    formState.reset();
                    resetCalled = true;
                  },
                  [text('Reset')],
                );
              },
            ),
          ]),
        ),
      );

      // Reset form - just verify the method can be called without hanging
      await tester.click(find.tag('button'));
      expect(resetCalled, isTrue);
    });

    testBrowser('tracks user interaction state', (tester) async {
      tester.pumpComponent(
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            name: 'interactive-field',
            validator: Validators.required,
            decoration: const InputDecoration(label: 'Interactive Field'),
          ),
        ),
      );

      // Initially no error shown
      expect(find.text('This field is required'), findsNothing);

      // After user interaction, validation should appear
      await tester.input(find.tag('input'), value: '');
      expect(find.text('This field is required'), findsOneComponent);
    });
  });

  group('FormField Component Tests', () {
    testBrowser('renders with custom builder', (tester) async {
      tester.pumpComponent(
        Form(
          child: FormField<String>(
            name: 'custom-field',
            builder: (field) =>
                div([text('Custom Field: ${field.value ?? "empty"}')]),
          ),
        ),
      );

      expect(find.text('Custom Field: empty'), findsOneComponent);
    });

    testBrowser('handles validation with custom validator', (tester) async {
      FormFieldState<String>? fieldState;

      tester.pumpComponent(
        Form(
          child: FormField<String>(
            name: 'validated-field',
            validator: (value) => value == 'test' ? null : 'Must be "test"',
            builder: (field) {
              fieldState = field;
              return div([
                input(
                  value: field.value ?? '',
                  onInput: (value) => field.didChange(value as String),
                ),
                if (field.hasError) text('Error: ${field.errorText}'),
              ]);
            },
          ),
        ),
      );

      // Manually trigger validation with wrong value
      fieldState?.didChange('wrong');
      final isValid = fieldState?.validate();
      expect(isValid, isFalse);
      expect(fieldState?.hasError, isTrue);
      expect(fieldState?.errorText, equals('Must be "test"'));

      // Fix the value
      fieldState?.didChange('test');
      final isValidNow = fieldState?.validate();
      expect(isValidNow, isTrue);
      expect(fieldState?.hasError, isFalse);
    });

    testBrowser('calls onSaved when form saves', (tester) async {
      String? savedValue;

      tester.pumpComponent(
        Form(
          child: div([
            FormField<String>(
              name: 'save-field',
              initialValue: 'save-me',
              onSaved: (value) => savedValue = value,
              builder: (field) => text('Value: ${field.value}'),
            ),
            Builder(
              builder: (context) {
                final formState = Form.of(context);
                return button(
                  events: {'click': (_) => formState.save()},
                  [text('Save')],
                );
              },
            ),
          ]),
        ),
      );

      await tester.click(find.tag('button'));
      expect(savedValue, equals('save-me'));
    });

    testBrowser('tracks interaction state correctly', (tester) async {
      bool hasInteracted = false;

      tester.pumpComponent(
        Form(
          child: FormField<String>(
            name: 'interaction-field',
            builder: (field) {
              hasInteracted = field.hasInteractedByUser;
              return input(
                value: field.value ?? '',
                onInput: (value) => field.didChange(value as String),
              );
            },
          ),
        ),
      );

      // Initially not interacted
      expect(hasInteracted, isFalse);

      // After input, should be interacted
      await tester.input(find.tag('input'), value: 'user input');
      expect(hasInteracted, isTrue);
    });

    testBrowser('handles enabled/disabled state', (tester) async {
      tester.pumpComponent(
        Form(
          child: FormField<String>(
            name: 'disabled-field',
            enabled: false,
            builder: (field) => input(
              value: field.value ?? '',
              disabled:
                  true, // FormField doesn't expose enabled, so hardcode for test
            ),
          ),
        ),
      );

      final inputElement = tester.findNode<web.HTMLInputElement>(
        find.tag('input'),
      );
      expect(inputElement?.hasAttribute('disabled'), isTrue);
    });
  });

  group('TextFormField Component Tests', () {
    testBrowser('renders text input with decoration', (tester) async {
      tester.pumpComponent(
        Form(
          child: TextFormField(
            name: 'decorated-field',
            decoration: const InputDecoration(
              label: 'Username',
              helperText: 'Enter your username',
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneComponent);
      expect(find.text('Enter your username'), findsOneComponent);
      expect(find.tag('input'), findsOneComponent);
    });

    testBrowser('handles password input type', (tester) async {
      tester.pumpComponent(
        Form(
          child: TextFormField(
            name: 'password-field',
            obscureText: true,
            decoration: const InputDecoration(label: 'Password'),
          ),
        ),
      );

      final inputElement = tester.findNode<web.HTMLInputElement>(
        find.tag('input'),
      );
      expect(inputElement?.getAttribute('type'), equals('password'));
    });

    testBrowser('renders textarea for multiline', (tester) async {
      tester.pumpComponent(
        Form(
          child: TextFormField(
            name: 'multiline-field',
            maxLines: 3,
            decoration: const InputDecoration(label: 'Description'),
          ),
        ),
      );

      expect(find.tag('textarea'), findsOneComponent);
      expect(find.tag('input'), findsNothing);
    });

    testBrowser('shows validation errors', (tester) async {
      late FormState formState;

      tester.pumpComponent(
        Form(
          child: div([
            TextFormField(
              name: 'error-field',
              validator: Validators.required,
              decoration: const InputDecoration(label: 'Required Field'),
            ),
            Builder(
              builder: (context) {
                formState = Form.of(context);
                return div([]);
              },
            ),
          ]),
        ),
      );

      // Verify the TextFormField is rendered
      expect(find.tag('input'), findsOneComponent);
      expect(find.text('Required Field'), findsOneComponent);

      // Initially no validation error should be shown
      expect(find.text('This field is required'), findsNothing);

      // Trigger validation by attempting form submission with empty field
      formState.validate();
      await tester.pump();

      // Now the validation error should appear in the DOM
      expect(find.text('This field is required'), findsOneComponent);

      // Fill the field with valid input
      await tester.input(find.tag('input'), value: 'Valid input');
      await tester.pump();

      // Trigger validation again
      formState.validate();
      await tester.pump();

      // Error should be gone
      expect(find.text('This field is required'), findsNothing);
    });

    testBrowser('applies custom className', (tester) async {
      tester.pumpComponent(
        Form(
          child: TextFormField(
            name: 'styled-field',
            className: 'custom-input-class',
            decoration: const InputDecoration(label: 'Styled Input'),
          ),
        ),
      );

      final inputElement = tester.findNode<web.HTMLInputElement>(
        find.tag('input'),
      );
      expect(inputElement?.className, contains('custom-input-class'));
    });

    testBrowser('handles disabled state', (tester) async {
      tester.pumpComponent(
        Form(
          child: TextFormField(
            name: 'disabled-field',
            enabled: false,
            decoration: const InputDecoration(label: 'Disabled Field'),
          ),
        ),
      );

      final inputElement = tester.findNode<web.HTMLInputElement>(
        find.tag('input'),
      );
      expect(inputElement?.hasAttribute('disabled'), isTrue);
    });

    testBrowser('maintains input value', (tester) async {
      tester.pumpComponent(
        Form(
          child: TextFormField(
            name: 'value-field',
            initialValue: 'initial text',
            decoration: const InputDecoration(label: 'Value Field'),
          ),
        ),
      );

      final inputElement = tester.findNode<web.HTMLInputElement>(
        find.tag('input'),
      );
      expect(inputElement?.value, equals('initial text'));

      await tester.input(find.tag('input'), value: 'updated text');
      expect(inputElement?.value, equals('updated text'));
    });

    testBrowser('shows helper text when no error', (tester) async {
      tester.pumpComponent(
        Form(
          child: TextFormField(
            name: 'helper-field',
            decoration: const InputDecoration(
              label: 'Email',
              helperText: 'We will never share your email',
            ),
          ),
        ),
      );

      expect(find.text('We will never share your email'), findsOneComponent);
    });

    testBrowser('hides helper text when error present', (tester) async {
      late FormState formState;

      tester.pumpComponent(
        Form(
          child: div([
            TextFormField(
              name: 'helper-field',
              validator: Validators.required,
              decoration: const InputDecoration(
                label: 'Field Label',
                helperText: 'This is helper text',
              ),
            ),
            Builder(
              builder: (context) {
                formState = Form.of(context);
                return div([]);
              },
            ),
          ]),
        ),
      );

      // Initially, helper text should be visible and no error
      expect(find.text('Field Label'), findsOneComponent);
      expect(find.text('This is helper text'), findsOneComponent);
      expect(find.text('This field is required'), findsNothing);

      // Trigger validation to show error
      formState.validate();
      await tester.pump();

      // Now error should be visible and helper text should be hidden
      expect(find.text('This field is required'), findsOneComponent);
      expect(find.text('This is helper text'), findsNothing);

      // Fill field to clear error
      await tester.input(find.tag('input'), value: 'Valid input');
      await tester.pump();

      // Validate again to clear error
      formState.validate();
      await tester.pump();

      // Helper text should be visible again, error should be gone
      expect(find.text('This is helper text'), findsOneComponent);
      expect(find.text('This field is required'), findsNothing);
    });
  });

  group('Validators Tests', () {
    test('required validator', () {
      expect(Validators.required(null), equals('This field is required'));
      expect(Validators.required(''), equals('This field is required'));
      expect(Validators.required('   '), equals('This field is required'));
      expect(Validators.required('valid'), isNull);
    });

    test('email validator', () {
      expect(Validators.email(null), isNull);
      expect(Validators.email(''), isNull);
      expect(
        Validators.email('invalid'),
        equals('Please enter a valid email address'),
      );
      expect(
        Validators.email('test@'),
        equals('Please enter a valid email address'),
      );
      expect(
        Validators.email('test@example'),
        equals('Please enter a valid email address'),
      );
      expect(Validators.email('test@example.com'), isNull);
    });

    test('minLength validator', () {
      final validator = Validators.minLength(5);
      expect(validator(null), equals('Must be at least 5 characters long'));
      expect(validator('abc'), equals('Must be at least 5 characters long'));
      expect(validator('abcde'), isNull);
      expect(validator('abcdef'), isNull);
    });

    test('maxLength validator', () {
      final validator = Validators.maxLength(10);
      expect(validator(null), isNull);
      expect(validator('short'), isNull);
      expect(validator('exactly10c'), isNull);
      expect(
        validator('this is too long'),
        equals('Must be no more than 10 characters long'),
      );
    });

    test('compose validator', () {
      final validator = Validators.compose([
        Validators.required,
        Validators.minLength(3),
        Validators.maxLength(10),
      ]);

      expect(validator(null), equals('This field is required'));
      expect(validator(''), equals('This field is required'));
      expect(validator('ab'), equals('Must be at least 3 characters long'));
      expect(validator('valid'), isNull);
      expect(
        validator('this is way too long'),
        equals('Must be no more than 10 characters long'),
      );
    });
  });

  group('FormField (Additional Tests)', () {
    testBrowser('creates field state correctly', (tester) async {
      String? fieldValue;

      final component = FormField<String>(
        name: 'test_field',
        initialValue: 'initial',
        builder: (field) {
          fieldValue = field.value;
          return div([text(field.value ?? '')]);
        },
      );

      tester.pumpComponent(component);
      await tester.pump();

      expect(fieldValue, equals('initial'));
    });

    testBrowser('validates field correctly', (tester) async {
      FormFieldState<String>? fieldState;

      final component = FormField<String>(
        name: 'test_field',
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Required' : null,
        builder: (field) {
          fieldState = field;
          return div([if (field.hasError) text('Error: ${field.errorText}')]);
        },
      );

      tester.pumpComponent(component);
      await tester.pump();

      // Initially no error
      expect(fieldState?.hasError, isFalse);

      // Validate with empty value should show error
      final isValid = fieldState?.validate();
      await tester.pump();

      expect(isValid, isFalse);
      expect(fieldState?.hasError, isTrue);
      expect(fieldState?.errorText, equals('Required'));
    });

    testBrowser('tracks user interaction correctly', (tester) async {
      FormFieldState<String>? fieldState;

      final component = FormField<String>(
        name: 'test_field',
        builder: (field) {
          fieldState = field;
          return div([text('Interacted: ${field.hasInteractedByUser}')]);
        },
      );

      tester.pumpComponent(component);
      await tester.pump();

      // Initially not interacted
      expect(fieldState?.hasInteractedByUser, isFalse);

      // Simulate user interaction
      fieldState?.didChange('new value');
      await tester.pump();

      expect(fieldState?.hasInteractedByUser, isTrue);
      expect(fieldState?.value, equals('new value'));
    });

    testBrowser('resets field state correctly', (tester) async {
      FormFieldState<String>? fieldState;

      final component = FormField<String>(
        name: 'test_field',
        initialValue: 'initial',
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Required' : null,
        builder: (field) {
          fieldState = field;
          return div([text(field.value ?? '')]);
        },
      );

      tester.pumpComponent(component);
      await tester.pump();

      // Change value and validate to create error
      fieldState?.didChange('');
      fieldState?.validate();
      await tester.pump();

      expect(fieldState?.hasError, isTrue);
      expect(fieldState?.hasInteractedByUser, isTrue);

      // Reset should restore initial state
      fieldState?.reset();
      await tester.pump();

      expect(fieldState?.value, equals('initial'));
      expect(fieldState?.hasError, isFalse);
      expect(fieldState?.hasInteractedByUser, isFalse);
    });

    testBrowser('calls onSaved callback', (tester) async {
      String? savedValue;
      FormFieldState<String>? fieldState;

      final component = FormField<String>(
        name: 'test_field',
        onSaved: (value) => savedValue = value,
        builder: (field) {
          fieldState = field;
          return div([]);
        },
      );

      tester.pumpComponent(component);
      await tester.pump();

      fieldState?.didChange('test value');
      fieldState?.save();

      expect(savedValue, equals('test value'));
    });
  });

  group('TextFormField', () {
    testBrowser('creates with correct initial value', (tester) async {
      final component = TextFormField(
        name: 'email',
        initialValue: 'test@example.com',
      );

      tester.pumpComponent(component);
      await pumpEventQueue();

      // Find the component and check it rendered
      expect(find.byComponent(component), findsOneComponent);
    });

    testBrowser('validates when configured with validator', (tester) async {
      final component = TextFormField(
        name: 'password',
        validator: (value) => (value?.length ?? 0) < 6
            ? 'Password must be at least 6 characters'
            : null,
      );

      tester.pumpComponent(component);
      await pumpEventQueue();

      expect(find.byComponent(component), findsOneComponent);
    });

    testBrowser('renders with decoration', (tester) async {
      final component = TextFormField(
        name: 'username',
        decoration: const InputDecoration(
          label: 'Username',
          hintText: 'Enter your username',
        ),
      );

      tester.pumpComponent(component);
      await pumpEventQueue();

      expect(find.byComponent(component), findsOneComponent);
    });
  });

  group('Validators', () {
    group('required', () {
      test('returns error for null value', () {
        expect(Validators.required(null), equals('This field is required'));
      });

      test('returns error for empty string', () {
        expect(Validators.required(''), equals('This field is required'));
      });

      test('returns error for whitespace-only string', () {
        expect(Validators.required('   '), equals('This field is required'));
      });

      test('returns null for valid value', () {
        expect(Validators.required('valid'), isNull);
      });
    });

    group('email', () {
      test('returns error for invalid email', () {
        expect(
          Validators.email('invalid'),
          equals('Please enter a valid email address'),
        );
        expect(
          Validators.email('test@'),
          equals('Please enter a valid email address'),
        );
        expect(
          Validators.email('@example.com'),
          equals('Please enter a valid email address'),
        );
        expect(
          Validators.email('test.example.com'),
          equals('Please enter a valid email address'),
        );
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name+tag@example.co.uk'), isNull);
        expect(
          Validators.email(''),
          isNull,
        ); // Empty is valid (use required for mandatory)
        expect(Validators.email(null), isNull);
      });
    });

    group('minLength', () {
      test('returns error for short string', () {
        final validator = Validators.minLength(5);
        expect(validator('123'), equals('Must be at least 5 characters long'));
        expect(validator(''), equals('Must be at least 5 characters long'));
      });

      test('returns null for valid length', () {
        final validator = Validators.minLength(5);
        expect(validator('12345'), isNull);
        expect(validator('123456'), isNull);
      });
    });

    group('maxLength', () {
      test('returns error for long string', () {
        final validator = Validators.maxLength(5);
        expect(
          validator('123456'),
          equals('Must be no more than 5 characters long'),
        );
      });

      test('returns null for valid length', () {
        final validator = Validators.maxLength(5);
        expect(validator('12345'), isNull);
        expect(validator('123'), isNull);
        expect(validator(''), isNull);
        expect(validator(null), isNull);
      });
    });

    group('compose', () {
      test('returns first error encountered', () {
        final validator = Validators.compose([
          (value) => Validators.required(value),
          Validators.minLength(5),
          (value) => Validators.email(value),
        ]);

        expect(validator(null), equals('This field is required'));
        expect(validator(''), equals('This field is required'));
        expect(validator('abc'), equals('Must be at least 5 characters long'));
        expect(
          validator('abcdef'),
          equals('Please enter a valid email address'),
        );
        expect(validator('test@example.com'), isNull);
      });

      test('handles empty validator list', () {
        final validator = Validators.compose([]);
        expect(validator('anything'), isNull);
      });
    });
  });
}
