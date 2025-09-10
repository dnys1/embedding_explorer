import 'package:jaspr/jaspr.dart';

/// Badge component inspired by shadcn/ui Badge
enum BadgeVariant { primary, secondary, destructive, outline }

class Badge extends StatelessComponent {
  const Badge({
    super.key,
    required this.children,
    this.variant = BadgeVariant.primary,
    this.className,
  });

  final List<Component> children;
  final BadgeVariant variant;
  final String? className;

  @override
  Component build(BuildContext context) {
    final variantClasses = _getVariantClasses(variant);

    return span(
      classes: [
        // Base badge styles
        'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
        variantClasses,
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      children,
    );
  }

  String _getVariantClasses(BadgeVariant variant) {
    switch (variant) {
      case BadgeVariant.primary:
        return 'border-transparent bg-primary text-primary-foreground hover:bg-primary/80';
      case BadgeVariant.secondary:
        return 'border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80';
      case BadgeVariant.destructive:
        return 'border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80';
      case BadgeVariant.outline:
        return 'text-foreground';
    }
  }
}
