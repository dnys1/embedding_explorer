import 'package:jaspr/jaspr.dart';

/// Button variants following shadcn/ui design
enum ButtonVariant { primary, secondary, destructive, outline, ghost, link }

/// Button sizes following shadcn/ui design
enum ButtonSize { sm, md, lg, icon }

/// A button component inspired by shadcn/ui Button
class Button extends StatelessComponent {
  const Button({
    super.key,
    required this.children,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.className,
    this.disabled = false,
    this.type = 'button',
  });

  final List<Component> children;
  final void Function()? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final String? className;
  final bool disabled;
  final String type;

  @override
  Component build(BuildContext context) {
    final variantClasses = _getVariantClasses(variant);
    final sizeClasses = _getSizeClasses(size);

    return button(
      classes: [
        // Base button styles
        'inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:pointer-events-none disabled:opacity-50',
        variantClasses,
        sizeClasses,
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      events: {
        if (onPressed != null && !disabled) 'click': (_) => onPressed!(),
      },
      attributes: {'type': type, if (disabled) 'disabled': 'true'},
      children,
    );
  }

  String _getVariantClasses(ButtonVariant variant) {
    switch (variant) {
      case ButtonVariant.primary:
        return 'bg-primary text-primary-foreground hover:bg-primary/90';
      case ButtonVariant.secondary:
        return 'bg-secondary text-secondary-foreground hover:bg-secondary/80';
      case ButtonVariant.destructive:
        return 'bg-destructive text-destructive-foreground hover:bg-destructive/90';
      case ButtonVariant.outline:
        return 'border border-input bg-background hover:bg-accent hover:text-accent-foreground';
      case ButtonVariant.ghost:
        return 'hover:bg-accent hover:text-accent-foreground';
      case ButtonVariant.link:
        return 'text-primary underline-offset-4 hover:underline';
    }
  }

  String _getSizeClasses(ButtonSize size) {
    switch (size) {
      case ButtonSize.sm:
        return 'h-9 rounded-md px-3';
      case ButtonSize.md:
        return 'h-10 px-4 py-2';
      case ButtonSize.lg:
        return 'h-11 rounded-md px-8';
      case ButtonSize.icon:
        return 'h-10 w-10';
    }
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
