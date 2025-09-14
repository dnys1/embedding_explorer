import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../../util/clsx.dart';

class Input extends StatelessComponent {
  const Input({
    super.key,
    this.type = InputType.text,
    this.placeholder,
    this.value,
    this.className,
    this.disabled = false,
    this.readOnly = false,
    this.id,
    this.name,
    this.required = false,
    this.onChange,
  });

  factory Input.text({
    Key? key,
    String? placeholder,
    String? value,
    String? className,
    bool disabled = false,
    bool readOnly = false,
    String? id,
    String? name,
    bool required = false,
    void Function(String event)? onChange,
  }) {
    return Input(
      key: key,
      type: InputType.text,
      placeholder: placeholder,
      value: value,
      className: className,
      disabled: disabled,
      readOnly: readOnly,
      id: id,
      name: name,
      required: required,
      onChange: (e) => onChange?.call((e.target as HTMLInputElement).value),
    );
  }

  final InputType type;
  final String? placeholder;
  final String? value;
  final String? className;
  final bool disabled;
  final bool readOnly;
  final String? id;
  final String? name;
  final bool required;
  final void Function(Event event)? onChange;

  @override
  Component build(BuildContext context) {
    return input(
      id: id,
      classes: [
        'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'file:border-0 file:bg-transparent file:text-sm file:font-medium',
        'placeholder:text-muted-foreground',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      ].clsx,
      type: type,
      disabled: disabled,
      name: name,
      value: value,
      events: {'change': ?onChange},
      attributes: {
        'placeholder': ?placeholder,
        if (readOnly) 'readonly': 'true',
        if (required) 'required': 'true',
      },
    );
  }
}
