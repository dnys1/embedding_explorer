import '../../util/clsx.dart';
import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

class Textarea extends StatelessComponent {
  const Textarea({
    super.key,
    this.placeholder,
    this.value,
    this.className,
    this.disabled = false,
    this.readOnly = false,
    this.id,
    this.name,
    this.required = false,
    this.rows = 3,
    this.cols,
    this.onInput,
    this.onChange,
  });

  final String? placeholder;
  final String? value;
  final String? className;
  final bool disabled;
  final bool readOnly;
  final String? id;
  final String? name;
  final bool required;
  final int rows;
  final int? cols;
  final void Function(String)? onInput;
  final void Function(String)? onChange;

  @override
  Component build(BuildContext context) {
    return textarea(
      classes: [
        'flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
        'placeholder:text-muted-foreground',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        if (disabled) 'disabled:cursor-not-allowed disabled:opacity-50',
        'resize-none',
        className,
      ].clsx,
      attributes: {
        'placeholder': ?placeholder,
        'value': ?value,
        'id': ?id,
        'name': ?name,
        if (disabled) 'disabled': 'true',
        if (readOnly) 'readonly': 'true',
        if (required) 'required': 'true',
        'rows': rows.toString(),
        'cols': ?cols?.toString(),
      },
      events: {
        if (onInput case final onInput?)
          'input': (event) => onInput((event.target as HTMLInputElement).value),
        if (onChange case final onChange?)
          'change': (event) =>
              onChange((event.target as HTMLInputElement).value),
      },
      [],
    );
  }
}
