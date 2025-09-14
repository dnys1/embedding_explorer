import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../../util/clsx.dart';

final class FormKey implements GlobalKey {
  final _key = GlobalKey();

  @override
  Form? get currentComponent => _key.currentComponent as Form?;

  @override
  BuildContext? get currentContext => _key.currentContext;
}

/// Form validation callback function
typedef FormValidator<T> = String? Function(T? value);

/// Form submission callback
typedef FormSubmissionCallback = void Function();

/// An InheritedComponent that provides FormState to descendant widgets
class _FormScope extends InheritedComponent {
  const _FormScope({
    required super.key,
    required this.formState,
    required this.generation,
    required super.child,
  });

  final FormState formState;
  final int generation;

  /// The Form associated with this widget
  Form get form => formState.component;

  @override
  bool updateShouldNotify(_FormScope oldWidget) {
    return generation != oldWidget.generation;
  }

  static FormState? maybeOf(BuildContext context) {
    final _FormScope? scope = context
        .dependOnInheritedComponentOfExactType<_FormScope>();
    return scope?.formState;
  }

  static FormState of(BuildContext context) {
    final FormState? formState = maybeOf(context);
    assert(formState != null, 'No Form found in context');
    return formState!;
  }
}

/// A form component with validation support similar to Flutter's Form widget
class Form extends StatefulComponent {
  const Form({
    this.formKey,
    required this.child,
    this.onSubmit,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.className,
  });

  final FormKey? formKey;
  final Component child;
  final FormSubmissionCallback? onSubmit;
  final VoidCallback? onChanged;
  final AutovalidateMode autovalidateMode;
  final String? className;

  /// Returns the [FormState] of the closest [Form] widget which encloses the
  /// given context, or null if none is found.
  static FormState? maybeOf(BuildContext context) {
    return _FormScope.maybeOf(context);
  }

  /// Returns the [FormState] of the closest [Form] widget which encloses the
  /// given context.
  static FormState of(BuildContext context) {
    return _FormScope.of(context);
  }

  @override
  FormState createState() => FormState();
}

class FormState extends State<Form> {
  int _generation = 0;
  bool _hasInteractedByUser = false;
  final Set<FormFieldState<dynamic>> _fields = <FormFieldState<dynamic>>{};
  final Map<String, FormFieldState<dynamic>> _fieldsByName = {};

  /// Register a form field with this form
  void _register(FormFieldState<dynamic> field) {
    _fields.add(field);
    _fieldsByName[field.name] = field;
  }

  /// Unregister a form field from this form
  void _unregister(FormFieldState<dynamic> field) {
    _fields.remove(field);
    _fieldsByName.remove(field.name);
  }

  /// Called when a form field has changed. This will cause all form fields
  /// to rebuild, useful if form fields have interdependencies.
  void _fieldDidChange() {
    component.onChanged?.call();

    _hasInteractedByUser = _fields.any((field) => field.hasInteractedByUser);
    _forceRebuild();
  }

  void _forceRebuild() {
    setState(() {
      ++_generation;
    });
  }

  /// Validate all form fields
  bool validate() {
    _hasInteractedByUser = true;
    _forceRebuild();
    return _validate();
  }

  bool _validate() {
    bool hasError = false;
    for (final field in _fields) {
      final bool isFieldValid = field.validate();
      hasError |= !isFieldValid;
    }
    return !hasError;
  }

  /// Reset all form fields
  void reset() {
    for (final field in _fields) {
      field.reset();
    }
    _hasInteractedByUser = false;
    _fieldDidChange();
  }

  /// Save all form fields
  void save() {
    for (final field in _fields) {
      field.save();
    }
  }

  /// Get the current value of a form field by name
  T? getFieldValue<T>(String fieldName) {
    final field = _fieldsByName[fieldName];
    return field?.value as T?;
  }

  /// Get all field values as a Map
  Map<String, dynamic> getFieldValues() {
    final values = <String, dynamic>{};
    for (final entry in _fieldsByName.entries) {
      values[entry.key] = entry.value.value;
    }
    return values;
  }

  void _handleSubmit(Event event) {
    event.preventDefault();
    if (validate()) {
      save();
      component.onSubmit?.call();
    }
  }

  @override
  Component build(BuildContext context) {
    switch (component.autovalidateMode) {
      case AutovalidateMode.always:
        _validate();
      case AutovalidateMode.onUserInteraction:
        if (_hasInteractedByUser) {
          _validate();
        }
      case AutovalidateMode.disabled:
        break;
    }

    return _FormScope(
      key: component.formKey?._key,
      formState: this,
      generation: _generation,
      child: form(
        classes: ['space-y-4', component.className].clsx,
        events: {
          if (component.onSubmit != null)
            'submit': (event) => _handleSubmit(event),
        },
        [component.child],
      ),
    );
  }
}

/// Auto-validation modes for form fields
enum AutovalidateMode {
  /// Never auto-validate
  disabled,

  /// Auto-validate after first interaction
  onUserInteraction,

  /// Always auto-validate
  always,
}

/// Base class for form field state
abstract class FormFieldState<T> {
  String get name;
  T? get value;
  String? get errorText;
  bool get hasError => errorText != null;
  bool get hasInteractedByUser;

  bool validate();
  void reset();
  void save();
  void didChange(T? value);
}

/// A form field wrapper component
class FormField<T> extends StatefulComponent {
  const FormField({
    super.key,
    required this.name,
    required this.builder,
    this.validator,
    this.onSaved,
    this.initialValue,
    this.autovalidateMode,
    this.enabled = true,
  });

  final String name;
  final Component Function(FormFieldState<T> field) builder;
  final FormValidator<T>? validator;
  final void Function(T? value)? onSaved;
  final T? initialValue;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;

  @override
  State<FormField<T>> createState() => _FormFieldState<T>();
}

class _FormFieldState<T> extends State<FormField<T>>
    implements FormFieldState<T> {
  T? _value;
  String? _errorText;
  bool _hasInteracted = false;

  FormState? _formState;

  @override
  String get name => component.name;

  @override
  T? get value => _value;

  @override
  String? get errorText => _errorText;

  @override
  bool get hasError => errorText != null;

  @override
  bool get hasInteractedByUser => _hasInteracted;

  @override
  void initState() {
    super.initState();
    _value = component.initialValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Find the parent form and register this field
    final newFormState = _findFormState(context);
    if (_formState != newFormState) {
      _formState?._unregister(this);
      _formState = newFormState;
      _formState?._register(this);
    }
  }

  @override
  void dispose() {
    _formState?._unregister(this);
    super.dispose();
  }

  @override
  void didChange(T? value) {
    setState(() {
      _value = value;
      _hasInteracted = true;
    });
    _formState?._fieldDidChange();
    _validate();
  }

  void _validate() {
    // Auto-validate if enabled
    final autovalidateMode =
        component.autovalidateMode ??
        _formState?.component.autovalidateMode ??
        AutovalidateMode.disabled;

    if (autovalidateMode == AutovalidateMode.always ||
        (autovalidateMode == AutovalidateMode.onUserInteraction &&
            _hasInteracted)) {
      validate();
    }
  }

  /// Find the parent FormState by walking up the widget tree
  FormState? _findFormState(BuildContext context) {
    return _FormScope.maybeOf(context);
  }

  @override
  bool validate() {
    final error = component.validator?.call(_value);
    setState(() {
      _errorText = error;
    });
    return error == null;
  }

  @override
  void reset() {
    setState(() {
      _value = component.initialValue;
      _errorText = null;
      _hasInteracted = false;
    });
  }

  @override
  void save() {
    component.onSaved?.call(_value);
  }

  void setValue(T? newValue) {
    didChange(newValue);
  }

  @override
  Component build(BuildContext context) {
    return component.builder(this);
  }
}

/// A text form field component that integrates with Form validation
class TextFormField extends FormField<String> {
  TextFormField({
    super.key,
    required super.name,
    super.validator,
    super.onSaved,
    super.initialValue,
    super.autovalidateMode,
    super.enabled = true,
    this.placeholder,
    this.obscureText = false,
    this.maxLines = 1,
    this.className,
    this.decoration,
  }) : super(
         builder: (field) => _TextFormFieldBuilder(
           field: field as _FormFieldState<String>,
           placeholder: placeholder,
           obscureText: obscureText,
           maxLines: maxLines,
           className: className,
           decoration: decoration,
           enabled: enabled,
         ),
       );

  final String? placeholder;
  final bool obscureText;
  final int maxLines;
  final String? className;
  final InputDecoration? decoration;
}

/// Builder widget for TextFormField
class _TextFormFieldBuilder extends StatelessComponent {
  const _TextFormFieldBuilder({
    required this.field,
    this.placeholder,
    this.obscureText = false,
    this.maxLines = 1,
    this.className,
    this.decoration,
    this.enabled = true,
  });

  final _FormFieldState<String> field;
  final String? placeholder;
  final bool obscureText;
  final int maxLines;
  final String? className;
  final InputDecoration? decoration;
  final bool enabled;

  @override
  Component build(BuildContext context) {
    final hasError = field.hasError;

    return div(classes: 'space-y-1', [
      // Label
      if (decoration?.label != null)
        label(
          classes: [
            'text-sm font-medium',
            enabled ? 'text-foreground' : 'text-muted-foreground',
          ].clsx,
          [text(decoration!.label!)],
        ),

      // Input field
      if (maxLines == 1)
        input(
          classes: [
            'flex h-10 w-full rounded-md border px-3 py-2 text-sm ring-offset-background',
            'file:border-0 file:bg-transparent file:text-sm file:font-medium',
            'placeholder:text-muted-foreground',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
            if (enabled) ...[
              if (hasError) ...[
                'border-destructive bg-background',
                'focus-visible:ring-destructive',
              ] else ...[
                'border-input bg-background',
                'focus-visible:ring-ring',
              ],
            ] else ...[
              'border-input bg-muted cursor-not-allowed opacity-50',
            ],
            className,
          ].clsx,
          attributes: {
            'type': obscureText ? 'password' : 'text',
            if (placeholder != null) 'placeholder': placeholder!,
            'value': field.value ?? '',
            if (!enabled) 'disabled': 'true',
          },
          events: enabled
              ? {
                  'input': (event) {
                    field.setValue((event.target as HTMLInputElement).value);
                  },
                }
              : {},
        )
      else
        textarea(
          classes: [
            'flex min-h-[80px] w-full rounded-md border px-3 py-2 text-sm ring-offset-background',
            'placeholder:text-muted-foreground',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
            if (enabled) ...[
              if (hasError) ...[
                'border-destructive bg-background',
                'focus-visible:ring-destructive',
              ] else ...[
                'border-input bg-background',
                'focus-visible:ring-ring',
              ],
            ] else ...[
              'border-input bg-muted cursor-not-allowed opacity-50',
            ],
            className,
          ].clsx,
          attributes: {
            if (placeholder != null) 'placeholder': placeholder!,
            'rows': maxLines.toString(),
            if (!enabled) 'disabled': 'true',
          },
          events: enabled
              ? {
                  'input': (event) {
                    field.setValue((event.target as HTMLTextAreaElement).value);
                  },
                }
              : {},
          [text(field.value ?? '')],
        ),

      // Error message
      if (hasError)
        p(classes: 'text-sm text-destructive', [text(field.errorText!)]),

      // Help text
      if (decoration?.helperText != null && !hasError)
        p(classes: 'text-sm text-muted-foreground', [
          text(decoration!.helperText!),
        ]),
    ]);
  }
}

/// Input decoration configuration
class InputDecoration {
  const InputDecoration({
    this.label,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String? label;
  final String? helperText;
  final String? hintText;
  final Component? prefixIcon;
  final Component? suffixIcon;
}

/// Convenience validators
class Validators {
  /// Requires a non-empty value
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates minimum length
  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value == null || value.length < min) {
        return 'Must be at least $min characters long';
      }
      return null;
    };
  }

  /// Validates maximum length
  static String? Function(String?) maxLength(int max) {
    return (String? value) {
      if (value != null && value.length > max) {
        return 'Must be no more than $max characters long';
      }
      return null;
    };
  }

  /// Combines multiple validators
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
