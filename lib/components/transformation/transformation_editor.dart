import 'package:embeddings_explorer/components/transformation/transformation_model.dart';
import 'package:jaspr/jaspr.dart' hide Position;

/// A component that provides a Monaco-based editor for data transformation
/// with intellisense support for available data fields.
class TransformationEditor extends StatelessComponent {
  const TransformationEditor({super.key, required this.model});

  final TransformationModel model;

  @override
  Component build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (_) => TransformationEditorView(model: model),
    );
  }
}

class TransformationEditorView extends StatefulComponent {
  const TransformationEditorView({super.key, required this.model});

  final TransformationModel model;

  @override
  State<TransformationEditorView> createState() =>
      _TransformationEditorViewState();
}

class _TransformationEditorViewState extends State<TransformationEditorView> {
  static const double _editorHeight = 400.0; // Default height in pixels
  final bool _isResizing = false;

  TransformationModel get model => component.model;

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col h-full', [
      _buildHeader(),
      _buildFieldSelector(),
      _buildEditorContainer(),
      _buildPreview(),
    ]);
  }

  Component _buildHeader() {
    return div(classes: 'bg-white border-b border-gray-200 px-4 py-3', [
      div(classes: 'flex items-center justify-between', [
        div([
          h3(classes: 'text-lg font-medium text-gray-900', [
            text('Data Transformation Template'),
          ]),
          p(classes: 'text-sm text-gray-500 mt-1', [
            text(
              'Define how to combine your data fields into text for embedding',
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildFieldSelector() {
    if (model.availableFields.isEmpty) {
      return div(classes: 'bg-yellow-50 border-l-4 border-yellow-400 p-4', [
        div(classes: 'flex', [
          div(classes: 'ml-3', [
            p(classes: 'text-sm text-yellow-700', [
              text(
                'No data source selected. Please select a data source first.',
              ),
            ]),
          ]),
        ]),
      ]);
    }

    return div(classes: 'bg-gray-50 border-b border-gray-200 px-4 py-3', [
      h4(classes: 'text-sm font-medium text-gray-700 mb-2', [
        text('Available Fields'),
      ]),
      div(classes: 'flex flex-wrap gap-2', [
        for (final field in model.availableFields) _buildFieldTag(field),
      ]),
    ]);
  }

  Component _buildFieldTag(String field) {
    return button(
      classes: [
        'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs',
        'font-medium bg-blue-100 text-blue-800 hover:bg-blue-200',
        'cursor-pointer transition-colors duration-200',
      ].join(' '),
      events: {'click': (_) => model.insertField(field)},
      [
        text(field),
        span(classes: 'ml-1 text-blue-600', [text('{{$field}}')]),
      ],
    );
  }

  Component _buildEditorContainer() {
    // NOTE: Must be const to avoid recreation of the DOM container which
    // Monaco depends on. Changes will break the editor.
    return const Component.element(
      key: Key('transformation-editor'),
      tag: 'div',
      id: 'transformation-editor',
      classes: 'w-full',
      styles: Styles(height: Unit.pixels(_editorHeight)),
    );
  }

  // ignore: unused_element
  Component _buildResizeHandle() {
    return div(
      classes: [
        'h-3 bg-gray-50 border-t border-gray-200 cursor-row-resize',
        'hover:bg-gray-100 transition-colors duration-200',
        'flex items-center justify-center group relative',
        if (_isResizing) 'bg-blue-50 border-blue-200',
      ].join(' '),
      [
        // Resize indicator lines
        div(
          classes: [
            'flex flex-col space-y-0.5 opacity-60',
            'group-hover:opacity-100 transition-opacity duration-200',
            if (_isResizing) 'opacity-100',
          ].join(' '),
          [
            div(classes: 'w-6 h-px bg-gray-400 rounded-full', []),
            div(classes: 'w-6 h-px bg-gray-400 rounded-full', []),
          ],
        ),
        // Tooltip on hover
        if (_isResizing)
          div(
            classes: [
              'absolute -top-8 left-1/2 transform -translate-x-1/2',
              'bg-gray-900 text-white text-xs px-2 py-1 rounded',
              'pointer-events-none',
            ].join(' '),
            [text('${_editorHeight}px')],
          ),
      ],
    );
  }

  Component _buildPreview() {
    return ValueListenableBuilder(
      listenable: model.template,
      builder: (context, _) {
        return div(classes: 'bg-gray-50 border-t border-gray-200 p-4', [
          h4(classes: 'text-sm font-medium text-gray-700 mb-2', [
            text('Template Preview'),
          ]),
          div(
            classes: 'bg-white border border-gray-200 rounded-md p-3 text-sm',
            [
              pre(classes: 'whitespace-pre-wrap text-gray-800', [
                text(model.previewText),
              ]),
            ],
          ),
        ]);
      },
    );
  }
}
