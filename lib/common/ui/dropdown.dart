import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../../util/clsx.dart';

class Dropdown extends StatefulComponent {
  const Dropdown({
    super.key,
    required this.trigger,
    required this.children,
    this.alignment = DropdownAlignment.end,
    this.className,
    this.disabled = false,
  });

  final Component trigger;
  final List<Component> children;
  final DropdownAlignment alignment;
  final String? className;
  final bool disabled;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  bool _isOpen = false;

  void _toggleDropdown() {
    if (!component.disabled) {
      setState(() {
        _isOpen = !_isOpen;
        if (_isOpen) {
          // Add click outside listener when dropdown opens
          context.binding.addPostFrameCallback(() {
            document.addEventListener('click', _clickOutsideListener);
          });
        } else {
          // Remove listener when dropdown closes
          document.removeEventListener('click', _clickOutsideListener);
        }
      });
    }
  }

  void _closeDropdown() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        document.removeEventListener('click', _clickOutsideListener);
      });
    }
  }

  EventListener? _clickOutsideListener;

  @override
  void initState() {
    super.initState();
    _clickOutsideListener = _handleClickOutside.toJS;
  }

  @override
  void dispose() {
    if (_clickOutsideListener != null) {
      document.removeEventListener('click', _clickOutsideListener);
    }
    super.dispose();
  }

  void _handleClickOutside(Event event) {
    _closeDropdown();
  }

  @override
  Component build(BuildContext context) {
    final alignmentClass = switch (component.alignment) {
      DropdownAlignment.start => 'left-0',
      DropdownAlignment.center => 'left-1/2 transform -translate-x-1/2',
      DropdownAlignment.end => 'right-0',
    };

    return div(
      classes: ['relative inline-block text-left', component.className].clsx,
      [
        // Trigger button
        button(
          classes: component.disabled ? 'opacity-50 cursor-not-allowed' : '',
          events: {
            'click': (event) {
              event.stopPropagation();
              _toggleDropdown();
            },
          },
          [component.trigger],
        ),

        // Dropdown menu
        if (_isOpen)
          div(
            classes: [
              'absolute z-50 mt-2 w-56 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none',
              alignmentClass,
            ].clsx,
            events: {
              'click': (event) {
                event.stopPropagation();
              },
            },
            [div(classes: 'py-1', component.children)],
          ),
      ],
    );
  }
}

class DropdownItem extends StatelessComponent {
  const DropdownItem({
    super.key,
    required this.children,
    this.onPressed,
    this.className,
    this.disabled = false,
    this.destructive = false,
  });

  final List<Component> children;
  final VoidCallback? onPressed;
  final String? className;
  final bool disabled;
  final bool destructive;

  @override
  Component build(BuildContext context) {
    final baseClasses = [
      'block px-4 py-2 text-sm w-full text-left transition-colors',
      if (disabled)
        'text-muted-foreground cursor-not-allowed'
      else if (destructive)
        'text-destructive hover:bg-destructive/10 hover:text-destructive cursor-pointer'
      else
        'text-foreground hover:bg-muted hover:text-foreground cursor-pointer',
      className,
    ].clsx;

    return button(
      classes: baseClasses,
      attributes: {if (disabled) 'disabled': 'true'},
      events: {
        if (!disabled && onPressed != null)
          'click': (event) {
            event.stopPropagation();
            onPressed!();
            // Close dropdown after item is clicked
            context.findAncestorStateOfType<_DropdownState>()?._closeDropdown();
          },
      },
      children,
    );
  }
}

class DropdownSeparator extends StatelessComponent {
  const DropdownSeparator({super.key, this.margin = 'my-1'});

  final String margin;

  @override
  Component build(BuildContext context) {
    return div(classes: '$margin h-px bg-muted', []);
  }
}

enum DropdownAlignment { start, center, end }
