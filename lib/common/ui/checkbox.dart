import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

class Checkbox extends StatelessComponent {
  const Checkbox({
    super.key,
    this.checked = false,
    this.onChanged,
    this.className,
    this.disabled = false,
    this.id,
    this.name,
    this.value,
  });

  final bool checked;
  final void Function(bool)? onChanged;
  final String? className;
  final bool disabled;
  final String? id;
  final String? name;
  final String? value;

  @override
  Component build(BuildContext context) {
    return input(
      classes: [
        'peer h-4 w-4 shrink-0 rounded-sm border border-primary ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        if (checked)
          'data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground',
        className,
      ].clsx,
      attributes: {
        'type': 'checkbox',
        if (checked) 'checked': 'checked',
        'id': ?id,
        'name': ?name,
        'value': ?value,
        if (disabled) 'disabled': 'true',
      },
      events: {
        if (onChanged case final onChanged? when !disabled)
          'change': (event) =>
              onChanged((event.target as HTMLInputElement).checked),
      },
    );
  }
}

/// Radio button component inspired by shadcn/ui Radio Group
class RadioButton extends StatelessComponent {
  const RadioButton({
    super.key,
    this.checked = false,
    this.onChanged,
    this.className,
    this.disabled = false,
    this.id,
    this.name,
    this.value,
  });

  final bool checked;
  final void Function(bool)? onChanged;
  final String? className;
  final bool disabled;
  final String? id;
  final String? name;
  final String? value;

  @override
  Component build(BuildContext context) {
    return input(
      classes: [
        'aspect-square h-4 w-4 rounded-full border border-primary text-primary ring-offset-background focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      ].clsx,
      attributes: {
        'type': 'radio',
        if (checked) 'checked': 'checked',
        'id': ?id,
        'name': ?name,
        'value': ?value,
        if (disabled) 'disabled': 'true',
      },
      events: {
        if (onChanged case final onChanged? when !disabled)
          'change': (event) =>
              onChanged((event.target as HTMLInputElement).checked),
      },
    );
  }
}
