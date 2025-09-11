import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../../util/clsx.dart';

class Dialog extends StatefulComponent {
  const Dialog({
    super.key,
    required this.builder,
    this.isOpen = true,
    this.onClose,
    this.className,
    this.maxWidth = 'max-w-lg',
  });

  final ComponentBuilder builder;
  final bool isOpen;
  final void Function()? onClose;
  final String? className;
  final String maxWidth;

  @override
  State<Dialog> createState() => _DialogState();
}

class _DialogState extends State<Dialog> {
  web.EventListener? _keyDownHandler;

  @override
  void initState() {
    super.initState();
    if (component.isOpen) {
      _addKeyboardListener();
    }
  }

  @override
  void didUpdateComponent(Dialog oldWidget) {
    super.didUpdateComponent(oldWidget);

    // Add/remove keyboard listener based on dialog open state
    if (component.isOpen && !oldWidget.isOpen) {
      _addKeyboardListener();
    } else if (!component.isOpen && oldWidget.isOpen) {
      _removeKeyboardListener();
    }
  }

  @override
  void dispose() {
    _removeKeyboardListener();
    super.dispose();
  }

  void _addKeyboardListener() {
    _keyDownHandler ??= (web.KeyboardEvent event) {
      // Sometimes this is null like when autofilling (?)
      final key = event.getProperty('key'.toJS) as JSString?;
      if (key?.toDart == 'Escape') {
        event.preventDefault();
        component.onClose?.call();
      }
    }.toJS;
    web.document.addEventListener('keydown', _keyDownHandler!);
  }

  void _removeKeyboardListener() {
    if (_keyDownHandler != null) {
      web.document.removeEventListener('keydown', _keyDownHandler!);
      _keyDownHandler = null;
    }
  }

  @override
  Component build(BuildContext context) {
    if (!component.isOpen) return div([]);

    return div(
      classes: [
        // Overlay backdrop
        'fixed inset-0 z-50 bg-black bg-opacity-50 flex items-center justify-center',
        component.className,
      ].clsx,
      events: {
        if (component.onClose case final onClose?)
          'click': (event) {
            // Close if clicking the backdrop (not the content)
            if (event.target == event.currentTarget) {
              onClose();
            }
          },
      },
      [
        div(
          classes: [
            'grid w-full gap-4 border bg-background p-6 shadow-lg duration-200 rounded-lg mx-4 max-h-[90vh] overflow-y-auto overflow-x-hidden',
            component.maxWidth,
          ].clsx,
          [component.builder(context)],
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
    return div(classes: ['grid gap-4 min-w-0', className].clsx, children);
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
