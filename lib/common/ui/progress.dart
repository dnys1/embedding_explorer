import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

class Progress extends StatelessComponent {
  const Progress({
    super.key,
    required this.value,
    this.max = 100,
    this.className,
    this.indicatorClassName,
  });

  final double value;
  final double max;
  final String? className;
  final String? indicatorClassName;

  @override
  Component build(BuildContext context) {
    final percentage = (value / max * 100).clamp(0, 100);

    return div(
      classes: [
        'relative h-4 w-full overflow-hidden rounded-full bg-secondary',
        className,
      ].clsx,
      attributes: {
        'role': 'progressbar',
        'aria-valuemin': '0',
        'aria-valuemax': max.toString(),
        'aria-valuenow': value.toString(),
        'style': 'position: relative;',
      },
      [
        div(
          classes: [
            'h-full w-full flex-1 bg-primary transition-all',
            indicatorClassName,
          ].clsx,
          attributes: {
            'style': 'transform: translateX(-${100 - percentage}%);',
          },
          [],
        ),
      ],
    );
  }
}

class Skeleton extends StatelessComponent {
  const Skeleton({super.key, this.className, this.width, this.height});

  final String? className;
  final Unit? width;
  final Unit? height;

  @override
  Component build(BuildContext context) {
    return div(
      classes: ['animate-pulse rounded-md bg-muted', className].clsx,
      styles: Styles(width: width, height: height),
      [],
    );
  }
}
