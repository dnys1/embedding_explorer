import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

enum AvatarSize {
  sm,
  md,
  lg,
  xl;

  String get classes => switch (this) {
    sm => 'h-8 w-8',
    md => 'h-10 w-10',
    lg => 'h-12 w-12',
    xl => 'h-16 w-16',
  };
}

class Avatar extends StatelessComponent {
  const Avatar({
    super.key,
    this.src,
    this.alt,
    this.fallback,
    this.size = AvatarSize.md,
    this.className,
  });

  final String? src;
  final String? alt;
  final String? fallback;
  final AvatarSize size;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        'relative flex shrink-0 overflow-hidden rounded-full',
        size.classes,
        className,
      ].clsx,
      [
        if (src case final src?)
          img(
            src: src,
            classes: 'aspect-square h-full w-full',
            attributes: {'alt': ?alt},
          )
        else if (fallback case final fallback?)
          div(
            classes:
                'flex h-full w-full items-center justify-center rounded-full bg-muted',
            [
              span(
                classes: 'text-xs font-medium uppercase text-muted-foreground',
                [text(fallback)],
              ),
            ],
          )
        else
          div(
            classes:
                'flex h-full w-full items-center justify-center rounded-full bg-muted',
            [
              span(classes: 'text-muted-foreground', [text('👤')]),
            ],
          ),
      ],
    );
  }
}
