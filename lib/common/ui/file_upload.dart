import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../../util/file_size.dart';
import 'ui.dart';

/// A reusable file upload component with drag-and-drop functionality
class FileUpload extends StatelessComponent {
  final String label;
  final String accept;
  final String inputId;
  final String dropText;
  final String supportedFormats;
  final web.File? selectedFile;
  final void Function(web.File?) onFileChanged;

  const FileUpload({
    required this.label,
    required this.accept,
    required this.inputId,
    required this.dropText,
    required this.supportedFormats,
    required this.selectedFile,
    required this.onFileChanged,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-4', [
      Label(children: [text(label)]),
      div(
        classes: [
          'relative cursor-pointer group border-2 border-dashed rounded-lg p-6 text-center transition-colors',
          if (selectedFile != null)
            'border-border bg-accent/50'
          else
            'border-border hover:border-accent-foreground hover:bg-accent/50',
        ].join(' '),
        events: {
          'click': (_) {
            final fileInput =
                web.document.querySelector('#$inputId')
                    as web.HTMLInputElement?;
            fileInput?.click();
          },
          'drop': (e) {
            e.preventDefault();
            final files = (e as web.DragEvent).dataTransfer?.files;
            if (files != null && files.length > 0) {
              final file = files.item(0);
              onFileChanged(file);
            }
          },
          'dragover': (e) => e.preventDefault(),
          'dragenter': (e) => e.preventDefault(),
        },
        [
          if (selectedFile case final selectedFile?) ...[
            div(classes: 'space-y-2', [
              Badge(
                variant: BadgeVariant.secondary,
                children: [text(selectedFile.name)],
              ),
              p(classes: 'text-sm text-muted-foreground', [
                text(humanReadableFileSize(selectedFile.size)),
              ]),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () => onFileChanged(null),
                events: {'click': (e) => e.stopPropagation()},
                children: [text('Remove file')],
              ),
            ]),
          ] else ...[
            div(classes: 'space-y-2', [
              div(classes: 'mx-auto w-12 h-12 text-muted-foreground', [
                // Upload icon placeholder
                div(
                  classes: 'w-full h-full bg-muted-foreground/20 rounded-full',
                  [],
                ),
              ]),
              div(classes: 'space-y-1', [
                p(classes: 'text-sm text-foreground', [
                  text('$dropText, or '),
                  span(classes: 'text-primary font-medium', [text('browse')]),
                ]),
                p(classes: 'text-xs text-muted-foreground', [
                  text(supportedFormats),
                ]),
              ]),
            ]),
          ],
        ],
      ),
      // Hidden file input
      input(
        classes: 'hidden',
        attributes: {'type': 'file', 'accept': accept, 'id': inputId},
        events: {
          'change': (e) {
            final files = (e.target as web.HTMLInputElement).files;
            if (files != null && files.length > 0) {
              final file = files.item(0);
              onFileChanged(file);
            }
          },
        },
      ),
    ]);
  }
}
