import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';

class Dialog extends StatelessComponent {
  const Dialog({
    super.key,
    required this.child,
    this.isOpen = true,
    this.onClose,
    this.className,
  });

  final Component child;
  final bool isOpen;
  final void Function()? onClose;
  final String? className;

  @override
  Component build(BuildContext context) {
    if (!isOpen) return div([]);

    return div(
      classes: [
        // Overlay backdrop
        'fixed inset-0 z-50 bg-background/80 backdrop-blur-sm',
        className,
      ].clsx,
      events: {
        if (onClose case final onClose?)
          'click': (event) {
            // Close if clicking the backdrop (not the content)
            if (event.target == event.currentTarget) {
              onClose();
            }
          },
      },
      [
        div(
          classes:
              'fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg '
              'translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background '
              'p-6 shadow-lg duration-200 sm:rounded-lg',
          [child],
        ),
      ],
    );
  }
}

class DialogContent extends StatelessComponent {
  const DialogContent({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(classes: ['grid gap-4', className].clsx, children);
  }
}

class DialogHeader extends StatelessComponent {
  const DialogHeader({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        'flex flex-col space-y-1.5 text-center sm:text-left',
        className,
      ].clsx,
      children,
    );
  }
}

class DialogTitle extends StatelessComponent {
  const DialogTitle({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return h2(
      classes: [
        'text-lg font-semibold leading-none tracking-tight',
        className,
      ].clsx,
      children,
    );
  }
}

class DialogDescription extends StatelessComponent {
  const DialogDescription({
    super.key,
    this.children = const [],
    this.className,
  });

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

class DialogFooter extends StatelessComponent {
  const DialogFooter({super.key, this.children = const [], this.className});

  final List<Component> children;
  final String? className;

  @override
  Component build(BuildContext context) {
    return div(
      classes: [
        'flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2',
        className,
      ].clsx,
      children,
    );
  }
}
