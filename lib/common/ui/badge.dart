import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

enum BadgeVariant {
  primary,
  secondary,
  destructive,
  outline;

  String get classes => switch (this) {
    BadgeVariant.primary =>
      'border-transparent bg-primary text-primary-foreground hover:bg-primary/80',
    BadgeVariant.secondary =>
      'border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80',
    BadgeVariant.destructive =>
      'border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80',
    BadgeVariant.outline => 'text-foreground',
  };
}

class Badge extends StatelessComponent {
  const Badge({
    super.key,
    this.children = const [],
    this.variant = BadgeVariant.primary,
    this.className,
  });

  final List<Component> children;
  final BadgeVariant variant;
  final String? className;

  @override
  Component build(BuildContext context) {
    return span(
      classes: [
        'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs',
        'font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
        variant.classes,
        className,
      ].clsx,
      children,
    );
  }
}
