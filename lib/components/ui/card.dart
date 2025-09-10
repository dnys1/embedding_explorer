import 'package:jaspr/jaspr.dart';

/// A card component inspired by shadcn/ui Card
/// Provides a container with consistent styling, padding, and borders
class Card extends StatelessComponent {
  const Card({
    super.key,
    required this.children,
    this.className,
    this.padding = 'p-6',
  });

  final List<Component> children;
  final String? className;
  final String padding;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        // Base card styles inspired by shadcn/ui
        'rounded-lg border bg-card text-card-foreground shadow-sm',
        padding,
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      children,
    );
  }
}

/// Card header component
class CardHeader extends StatelessComponent {
  const CardHeader({super.key, required this.children, this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        'flex flex-col space-y-1.5 p-6',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      children,
    );
  }
}

/// Card title component
class CardTitle extends StatelessComponent {
  const CardTitle({
    super.key,
    required this.children,
    this.className,
    this.as = 'h3',
  });

  final List<Component> children;
  final String? className;
  final String as; // HTML tag to use

  @override
  Component build(BuildContext context) {
    final classes = [
      'text-2xl font-semibold leading-none tracking-tight',
      className ?? '',
    ].where((c) => c.isNotEmpty).join(' ');

    switch (as) {
      case 'h1':
        return h1(classes: classes, children);
      case 'h2':
        return h2(classes: classes, children);
      case 'h3':
        return h3(classes: classes, children);
      case 'h4':
        return h4(classes: classes, children);
      case 'h5':
        return h5(classes: classes, children);
      case 'h6':
        return h6(classes: classes, children);
      default:
        return h3(classes: classes, children);
    }
  }
}

/// Card description component
class CardDescription extends StatelessComponent {
  const CardDescription({super.key, required this.children, this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return p(
      classes: [
        'text-sm text-muted-foreground',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      children,
    );
  }
}

/// Card content component
class CardContent extends StatelessComponent {
  const CardContent({super.key, required this.children, this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        'p-6 pt-0',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      children,
    );
  }
}

/// Card footer component
class CardFooter extends StatelessComponent {
  const CardFooter({super.key, required this.children, this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        'flex items-center p-6 pt-0',
        className ?? '',
      ].where((c) => c.isNotEmpty).join(' '),
      children,
    );
  }
}
