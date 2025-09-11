import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

enum SeparatorOrientation {
  horizontal,
  vertical;

  String get classes => switch (this) {
    horizontal => 'h-[1px] w-full',
    vertical => 'h-full w-[1px]',
  };
}

class Separator extends StatelessComponent {
  const Separator({
    super.key,
    this.orientation = SeparatorOrientation.horizontal,
    this.className,
    this.decorative = true,
  });

  final SeparatorOrientation orientation;
  final String? className;
  final bool decorative;

  @override
  Component build(BuildContext context) {
    return div(
      classes: ['shrink-0 bg-border', orientation.classes, className].clsx,
      attributes: {
        if (!decorative) 'role': 'separator',
        if (orientation == SeparatorOrientation.vertical)
          'aria-orientation': 'vertical'
        else
          'aria-orientation': 'horizontal',
      },
      [],
    );
  }
}

enum ToggleVariant {
  default$,
  outline;

  String classes({required bool pressed}) => switch (this) {
    default$ => pressed ? 'bg-accent text-accent-foreground' : 'bg-transparent',
    outline =>
      pressed
          ? 'bg-accent text-accent-foreground border border-input'
          : 'border border-input bg-transparent hover:bg-accent hover:text-accent-foreground',
  };
}

enum ToggleSize {
  sm,
  md,
  lg;

  String get classes => switch (this) {
    sm => 'h-9 px-2.5',
    md => 'h-10 px-3',
    lg => 'h-11 px-5',
  };
}

class Toggle extends StatelessComponent {
  const Toggle({
    super.key,
    this.children = const [],
    this.pressed = false,
    this.onPressed,
    this.variant = ToggleVariant.default$,
    this.size = ToggleSize.md,
    this.className,
    this.disabled = false,
  });

  final List<Component> children;
  final bool pressed;
  final void Function(bool)? onPressed;
  final ToggleVariant variant;
  final ToggleSize size;
  final String? className;
  final bool disabled;

  @override
  Component build(BuildContext context) {
    return button(
      classes: [
        'inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors hover:bg-muted hover:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:pointer-events-none disabled:opacity-50',
        variant.classes(pressed: pressed),
        size.classes,
        className,
      ].clsx,
      attributes: {
        'type': 'button',
        'aria-pressed': pressed.toString(),
        if (disabled) 'disabled': 'true',
      },
      events: {
        if (onPressed case final onPressed? when !disabled)
          'click': (_) => onPressed(!pressed),
      },
      children,
    );
  }
}
