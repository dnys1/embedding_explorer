import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

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
        'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'placeholder:text-muted-foreground',
        'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      ].clsx,
      attributes: {
        'value': ?value,
        'id': ?id,
        'name': ?name,
        if (disabled) 'disabled': 'true',
        if (required) 'required': 'true',
      },
      [
        if (placeholder case final placeholder?)
          option(
            attributes: {'value': '', 'disabled': 'true'},
            [text(placeholder)],
          ),
        ...children,
      ],
    );
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
      attributes: {
        'value': value,
        if (disabled) 'disabled': 'true',
        if (selected) 'selected': 'true',
      },
      children,
    );
  }
}
