import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

class Label extends StatelessComponent {
  const Label({
    super.key,
    this.children = const [],
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
        className,
      ].clsx,
      attributes: {'for': ?htmlFor},
      children,
    );
  }
}
