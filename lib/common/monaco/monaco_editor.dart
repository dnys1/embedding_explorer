import 'package:jaspr/jaspr.dart';

import 'monaco_editor_model.dart';

/// A reusable Monaco editor component that follows the model-view pattern
class MonacoEditor extends StatefulComponent {
  const MonacoEditor({super.key, required this.model});

  final MonacoEditorModel model;

  @override
  State<MonacoEditor> createState() => _MonacoEditorState();
}

class _MonacoEditorState extends State<MonacoEditor> {
  MonacoEditorModel get model => component.model;

  @override
  Component build(BuildContext context) {
    if (model.disposed) {
      return div([]);
    }
    if (model.error case final error?) {
      return div(classes: 'p-4 bg-red-50 border border-red-200 rounded-md', [
        p(classes: 'text-sm text-red-600', [text('Error: $error')]),
      ]);
    }

    return ValueListenableBuilder(
      listenable: model.isLoading,
      builder: (context, isLoading) {
        return div(
          styles: Styles(height: model.height?.px),
          classes:
              'relative w-full border border-input rounded-md overflow-hidden',
          [
            // Editor container
            Component.element(
              key: Key(model.containerId),
              tag: 'div',
              id: model.containerId,
              classes: 'w-full h-full',
            ),
            if (isLoading)
              div(
                classes:
                    'absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center',
                [
                  div(classes: 'text-sm text-gray-600', [
                    text('Initializing editor...'),
                  ]),
                ],
              ),
          ],
        );
      },
    );
  }
}
