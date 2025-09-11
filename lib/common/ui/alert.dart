import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

enum AlertVariant {
  default$,
  destructive;

  String get classes => switch (this) {
    default$ => 'bg-background text-foreground',
    destructive =>
      'border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive',
  };
}

class Alert extends StatelessComponent {
  const Alert({
    super.key,
    this.children = const [],
    this.variant = AlertVariant.default$,
    this.className,
  });

  final List<Component> children;
  final AlertVariant variant;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        'relative w-full rounded-lg border p-4',
        '[&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground',
        variant.classes,
        className,
      ].clsx,
      attributes: {'role': 'alert'},
      children,
    );
  }
}

class AlertTitle extends StatelessComponent {
  const AlertTitle({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return h5(
      classes: ['mb-1 font-medium leading-none tracking-tight', className].clsx,
      children,
    );
  }
}

class AlertDescription extends StatelessComponent {
  const AlertDescription({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: ['text-sm [&_p]:leading-relaxed', className].clsx,
      children,
    );
  }
}
