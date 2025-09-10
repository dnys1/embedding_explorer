import 'package:jaspr/jaspr.dart';

/// Select component inspired by shadcn/ui Select
class Select extends StatelessComponent {
  const Select({
    super.key,
    required this.children,
    this.value,
    this.placeholder,
    this.className,
    this.disabled = false,
    this.id,
    this.name,
    this.required = false,
  });

  final List<Component> children;
  final String? value;
  final String? placeholder;
  final String? className;
  final bool disabled;
  final String? id;
  final String? name;
  final bool required;

  @override
  Component build(BuildContext context) {
    return select(
      classes: [
        // Base select styles inspired by shadcn/ui
        'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'placeholder:text-muted-foreground',
        'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      attributes: {
        if (value != null) 'value': value!,
        if (id != null) 'id': id!,
        if (name != null) 'name': name!,
        if (disabled) 'disabled': 'true',
        if (required) 'required': 'true',
      },
      [
        if (placeholder != null)
          option(
            attributes: {'value': '', 'disabled': 'true'},
            [text(placeholder!)],
          ),
        ...children,
      ],
    );
  }
}

/// Option component for Select
class Option extends StatelessComponent {
  const Option({
    super.key,
    required this.value,
    required this.children,
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
      attributes: {
        'value': value,
        if (disabled) 'disabled': 'true',
        if (selected) 'selected': 'true',
      },
      children,
    );
  }
}
