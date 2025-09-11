import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart' as jaspr;
import 'package:jaspr/jaspr.dart';

class Card extends StatelessComponent {
  const Card({
    super.key,
    this.children = const [],
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
        'rounded-lg border bg-card text-card-foreground shadow-sm',
        padding,
        className,
      ].clsx,
      children,
    );
  }
}

class CardHeader extends StatelessComponent {
  const CardHeader({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: ['flex flex-col space-y-1.5 p-6', className].clsx,
      children,
    );
  }
}

enum Heading {
  h1,
  h2,
  h3,
  h4,
  h5,
  h6;

  Component build(List<Component> children, {String? classes}) {
    return switch (this) {
      h1 => jaspr.h1(classes: classes, children),
      h2 => jaspr.h2(classes: classes, children),
      h3 => jaspr.h3(classes: classes, children),
      h4 => jaspr.h4(classes: classes, children),
      h5 => jaspr.h5(classes: classes, children),
      h6 => jaspr.h6(classes: classes, children),
    };
  }
}

class CardTitle extends StatelessComponent {
  const CardTitle({
    super.key,
    this.children = const [],
    this.className,
    this.as = Heading.h3,
  });

  final List<Component> children;
  final String? className;
  final Heading as; // HTML tag to use

  @override
  Component build(BuildContext context) {
    final sizeClass = switch (as) {
      Heading.h1 => 'text-2xl',
      Heading.h2 => 'text-xl',
      Heading.h3 => 'text-lg',
      Heading.h4 => 'text-base',
      Heading.h5 => 'text-sm',
      Heading.h6 => 'text-xs',
    };
    final classes = [
      sizeClass,
      'font-semibold leading-none tracking-tight',
      className,
    ].clsx;
    return as.build(children, classes: classes);
  }
}

class CardDescription extends StatelessComponent {
  const CardDescription({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return p(
      classes: ['text-sm text-muted-foreground', className].clsx,
      children,
    );
  }
}

class CardContent extends StatelessComponent {
  const CardContent({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(classes: ['p-6 pt-0', className].clsx, children);
  }
}

class CardFooter extends StatelessComponent {
  const CardFooter({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: ['flex items-center p-6 pt-0', className].clsx,
      children,
    );
  }
}
