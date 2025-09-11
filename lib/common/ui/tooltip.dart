import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

enum TooltipSide {
  top,
  right,
  bottom,
  left;

  String get classes => switch (this) {
    top => 'bottom-full left-1/2 transform -translate-x-1/2 mb-2',
    right => 'left-full top-1/2 transform -translate-y-1/2 ml-2',
    bottom => 'top-full left-1/2 transform -translate-x-1/2 mt-2',
    left => 'right-full top-1/2 transform -translate-y-1/2 mr-2',
  };
}

class Tooltip extends StatefulComponent {
  const Tooltip({
    super.key,
    required this.child,
    required this.content,
    this.side = TooltipSide.top,
    this.className,
    this.contentClassName,
    this.delayDuration = 700,
  });

  final Component child;
  final String content;
  final TooltipSide side;
  final String? className;
  final String? contentClassName;
  final int delayDuration;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  bool _isVisible = false;

  @override
  Component build(BuildContext context) {
    return div(classes: ['relative inline-block', component.className].clsx, [
      div(
        events: {
          'mouseenter': (_) => setState(() => _isVisible = true),
          'mouseleave': (_) => setState(() => _isVisible = false),
        },
        [component.child],
      ),
      if (_isVisible)
        div(
          classes: [
            'absolute z-50 overflow-hidden rounded-md border bg-popover px-3 py-1.5 text-sm text-popover-foreground shadow-md animate-in fade-in-0 zoom-in-95',
            component.side.classes,
            component.contentClassName,
          ].clsx,
          attributes: {'role': 'tooltip'},
          [text(component.content)],
        ),
    ]);
  }
}
