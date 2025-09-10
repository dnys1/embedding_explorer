import 'package:jaspr/jaspr.dart';

/// Input component inspired by shadcn/ui Input
class Input extends StatelessComponent {
  const Input({
    super.key,
    this.type = 'text',
    this.placeholder,
    this.value,
    this.className,
    this.disabled = false,
    this.readOnly = false,
    this.id,
    this.name,
    this.required = false,
  });

  final String type;
  final String? placeholder;
  final String? value;
  final String? className;
  final bool disabled;
  final bool readOnly;
  final String? id;
  final String? name;
  final bool required;

  @override
  Component build(BuildContext context) {
    return input(
      classes: [
        // Base input styles inspired by shadcn/ui
        'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'file:border-0 file:bg-transparent file:text-sm file:font-medium',
        'placeholder:text-muted-foreground',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      attributes: {
        'type': type,
        if (placeholder != null) 'placeholder': placeholder!,
        if (value != null) 'value': value!,
        if (id != null) 'id': id!,
        if (name != null) 'name': name!,
        if (disabled) 'disabled': 'true',
        if (readOnly) 'readonly': 'true',
        if (required) 'required': 'true',
      },
    );
  }
}

/// Textarea component inspired by shadcn/ui Textarea
class Textarea extends StatelessComponent {
  const Textarea({
    super.key,
    this.placeholder,
    this.value,
    this.className,
    this.disabled = false,
    this.readOnly = false,
    this.id,
    this.name,
    this.required = false,
    this.rows,
    this.cols,
  });

  final String? placeholder;
  final String? value;
  final String? className;
  final bool disabled;
  final bool readOnly;
  final String? id;
  final String? name;
  final bool required;
  final int? rows;
  final int? cols;

  @override
  Component build(BuildContext context) {
    return textarea(
      classes: [
        // Base textarea styles inspired by shadcn/ui
        'flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'placeholder:text-muted-foreground',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      attributes: {
        if (placeholder != null) 'placeholder': placeholder!,
        if (id != null) 'id': id!,
        if (name != null) 'name': name!,
        if (disabled) 'disabled': 'true',
        if (readOnly) 'readonly': 'true',
        if (required) 'required': 'true',
        if (rows != null) 'rows': rows!.toString(),
        if (cols != null) 'cols': cols!.toString(),
      },
      [if (value != null) text(value!)],
    );
  }
}

/// Label component inspired by shadcn/ui Label
class Label extends StatelessComponent {
  const Label({
    super.key,
    required this.children,
    this.htmlFor,
    this.className,
  });

  final List<Component> children;
  final String? htmlFor;
  final String? className;

  @override
  Component build(BuildContext context) {
    return label(
      classes: [
        'text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      attributes: {if (htmlFor != null) 'for': htmlFor!},
      children,
    );
  }
}
