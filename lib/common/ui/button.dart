import 'package:jaspr/jaspr.dart';

import '../../util/clsx.dart';

enum ButtonVariant {
  primary,
  secondary,
  destructive,
  outline,
  ghost,
  link;

  String get classes => switch (this) {
    ButtonVariant.primary =>
      'bg-primary text-primary-foreground hover:bg-primary/90',
    ButtonVariant.secondary =>
      'bg-secondary text-secondary-foreground hover:bg-secondary/80',
    ButtonVariant.destructive =>
      'bg-destructive text-destructive-foreground hover:bg-destructive/90',
    ButtonVariant.outline =>
      'border border-input bg-background hover:bg-accent hover:text-accent-foreground',
    ButtonVariant.ghost => 'hover:bg-accent hover:text-accent-foreground',
    ButtonVariant.link => 'text-primary underline-offset-4 hover:underline',
  };
}

enum ButtonSize {
  sm,
  md,
  lg,
  icon;

  String get classes => switch (this) {
    ButtonSize.sm => 'h-9 rounded-md px-3',
    ButtonSize.md => 'h-10 px-4 py-2',
    ButtonSize.lg => 'h-11 rounded-md px-8',
    ButtonSize.icon => 'h-10 w-10',
  };
}

class Button extends StatelessComponent {
  const Button({
    super.key,
    this.children = const [],
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.className,
    this.disabled = false,
    this.type = 'button',
    this.events,
  });

  final List<Component> children;
  final void Function()? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final String? className;
  final Map<String, EventCallback>? events;
  final bool disabled;
  final String type;

  @override
  Component build(BuildContext context) {
    return button(
      classes: [
        'inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:pointer-events-none disabled:opacity-50',
        variant.classes,
        size.classes,
        className,
      ].clsx,
      events: {
        ...?events,
        if (!disabled)
          'click': (e) {
            onPressed?.call();
            events?['click']?.call(e);
          },
      },
      attributes: {'type': type, if (disabled) 'disabled': 'true'},
      children,
    );
  }
}

/// Icon button convenience constructor
class IconButton extends StatelessComponent {
  const IconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = ButtonVariant.ghost,
    this.className,
    this.disabled = false,
  });

  final Component icon;
  final void Function()? onPressed;
  final ButtonVariant variant;
  final String? className;
  final bool disabled;

  @override
  Component build(BuildContext context) {
    return Button(
      onPressed: onPressed,
      variant: variant,
      size: ButtonSize.icon,
      className: className,
      disabled: disabled,
      children: [icon],
    );
  }
}
