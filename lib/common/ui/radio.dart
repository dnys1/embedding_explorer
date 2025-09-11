import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

class Radio extends StatelessComponent {
  const Radio({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.className,
    this.disabled = false,
    this.id,
    this.name,
  });

  final String value;
  final String? groupValue;
  final void Function(String)? onChanged;
  final String? className;
  final bool disabled;
  final String? id;
  final String? name;

  bool get isChecked => groupValue == value;

  @override
  Component build(BuildContext context) {
    return input(
      id: id,
      type: InputType.radio,
      classes: [
        'aspect-square h-4 w-4 rounded-full border border-primary text-primary ring-offset-background focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      ].clsx,
      name: name,
      value: value,
      disabled: disabled,
      attributes: {if (isChecked) 'checked': 'checked'},
      events: {
        if (onChanged case final onChanged? when !disabled)
          'change': (event) {
            final target = event.target as HTMLInputElement;
            if (target.checked) {
              onChanged(value);
            }
          },
      },
    );
  }
}

class RadioGroup extends StatelessComponent {
  const RadioGroup({
    super.key,
    required this.children,
    this.value,
    this.onValueChange,
    this.className,
    this.name,
    this.disabled = false,
  });

  final List<Component> children;
  final String? value;
  final void Function(String)? onValueChange;
  final String? className;
  final String? name;
  final bool disabled;

  @override
  Component build(BuildContext context) {
    return div(
      classes: ['grid gap-2', className].clsx,
      attributes: {
        'role': 'radiogroup',
        if (name case final name?) 'data-name': name,
      },
      [
        for (final child in children)
          if (child is Radio)
            Radio(
              key: child.key,
              value: child.value,
              groupValue: value,
              onChanged: disabled ? null : (onValueChange ?? child.onChanged),
              className: child.className,
              disabled: disabled || child.disabled,
              id: child.id,
              name: name ?? child.name,
            )
          else
            child,
      ],
    );
  }
}

class RadioGroupItem extends StatelessComponent {
  const RadioGroupItem({
    super.key,
    required this.value,
    this.className,
    this.disabled = false,
    this.id,
  });

  final String value;
  final String? className;
  final bool disabled;
  final String? id;

  @override
  Component build(BuildContext context) {
    return Radio(
      key: key,
      value: value,
      className: className,
      disabled: disabled,
      id: id,
    );
  }
}
