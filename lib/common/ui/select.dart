import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../../util/clsx.dart';

class Select extends StatelessComponent {
  const Select({
    super.key,
    this.children = const [],
    this.value,
    this.placeholder,
    this.className,
    this.disabled = false,
    this.id,
    this.name,
    this.required = false,
    this.onChange,
  });

  final List<Component> children;
  final String? value;
  final String? placeholder;
  final String? className;
  final bool disabled;
  final String? id;
  final String? name;
  final bool required;
  final void Function(String)? onChange;

  @override
  Component build(BuildContext context) {
    return select(
      id: id,
      name: name,
      classes: [
        'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'placeholder:text-muted-foreground',
        'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      ].clsx,
      value: value,
      disabled: disabled,
      required: required,
      onChange: (event) => onChange?.call(event.single),
      [
        if (placeholder case final placeholder?)
          Option(
            value: '',
            disabled: true,
            selected: value == null || value!.isEmpty,
            children: [text(placeholder)],
          ),
        ...children,
      ],
    );
  }
}

class MultiSelect extends StatelessComponent {
  const MultiSelect({
    super.key,
    this.children = const [],
    this.placeholder,
    this.className,
    this.disabled = false,
    this.id,
    this.name,
    this.required = false,
    this.size = 4,
    this.onChange,
  });

  final List<Component> children;
  final String? placeholder;
  final String? className;
  final bool disabled;
  final String? id;
  final String? name;
  final bool required;
  final int size;
  final void Function(List<String>)? onChange;

  @override
  Component build(BuildContext context) {
    return select(
      id: id,
      name: name,
      classes: [
        'w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      ].clsx,
      multiple: true,
      size: size,
      disabled: disabled,
      required: required,
      events: {
        if (onChange case final onChange?)
          'change': (event) {
            final select = event.target as HTMLSelectElement;
            final selectedOptions = select.selectedOptions;
            final selectedValues = [
              for (var i = 0; i < selectedOptions.length; i++)
                (selectedOptions.item(i)! as HTMLOptionElement).value,
            ];
            onChange(selectedValues);
          },
      },
      children,
    );
  }
}

class OptionGroup extends StatelessComponent {
  const OptionGroup({
    super.key,
    required this.label,
    this.children = const [],
    this.disabled = false,
  });

  final String label;
  final List<Component> children;
  final bool disabled;

  @override
  Component build(BuildContext context) {
    return optgroup(label: label, disabled: disabled, children);
  }
}

class Option extends StatelessComponent {
  const Option({
    super.key,
    required this.value,
    this.children = const [],
    this.disabled = false,
    this.selected = false,
  });

  final String value;
  final List<Component> children;
  final bool disabled;
  final bool selected;

  @override
  Component build(BuildContext context) {
    return option(
      value: value,
      disabled: disabled,
      selected: selected,
      children,
    );
  }
}
