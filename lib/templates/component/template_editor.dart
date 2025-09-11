import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../../common/monaco/monaco_editor.dart';
import 'template_editor_model.dart';

/// A component that provides a Monaco-based editor for embedding templates
/// with intellisense support for available data fields.
class TemplateEditor extends StatelessComponent {
  TemplateEditor({required this.model}) : super(key: ValueKey(model));

  final TemplateEditorModel model;

  @override
  Component build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (_) => TemplateEditorView(model: model),
    );
  }
}

class TemplateEditorView extends StatefulComponent {
  const TemplateEditorView({super.key, required this.model});

  final TemplateEditorModel model;

  @override
  State<TemplateEditorView> createState() => _TemplateEditorViewState();
}

class _TemplateEditorViewState extends State<TemplateEditorView> {
  TemplateEditorModel get model => component.model;

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-6', [
      _buildBasicFields(),
      _buildFieldManagement(),
      _buildTemplateEditor(),
      _buildPreview(),
    ]);
  }

  Component _buildBasicFields() {
    return div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
      div(classes: 'space-y-2', [
        label(
          classes: 'text-sm font-medium text-foreground',
          attributes: {'for': 'template-name'},
          [text('Name *')],
        ),
        ValueListenableBuilder(
          listenable: model.name,
          builder: (context, name) {
            return input(
              id: 'template-name',
              classes:
                  'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
              attributes: {'placeholder': 'Enter template name', 'value': name},
              events: {
                'input': (event) {
                  model.updateName((event.target as HTMLInputElement).value);
                },
              },
            );
          },
        ),
      ]),
      div(classes: 'space-y-2', [
        label(
          classes: 'text-sm font-medium text-foreground',
          attributes: {'for': 'template-desc'},
          [text('Description')],
        ),
        ValueListenableBuilder(
          listenable: model.description,
          builder: (context, description) {
            return input(
              id: 'template-desc',
              classes:
                  'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
              attributes: {
                'placeholder': 'Brief description',
                'value': description,
              },
              events: {
                'input': (event) {
                  model.updateDescription(
                    (event.target as HTMLInputElement).value,
                  );
                },
              },
            );
          },
        ),
      ]),
    ]);
  }

  Component _buildFieldManagement() {
    return div(classes: 'space-y-4', [
      div([
        h3(classes: 'text-lg font-medium text-foreground mb-2', [
          text('Data Source'),
        ]),
        p(classes: 'text-sm text-muted-foreground', [
          text(
            'Select a data source to load available fields for your template.',
          ),
        ]),
      ]),

      // Data source selector
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [
          text('Data Source *'),
        ]),
        ValueListenableBuilder(
          listenable: model.selectedDataSourceId,
          builder: (context, selectedId) {
            final dataSources = model.configManager.dataSources.all;
            return select(
              classes:
                  'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
              attributes: {'value': selectedId},
              events: {
                'change': (event) {
                  final newValue = (event.target as HTMLSelectElement).value;
                  model.updateDataSource(newValue);
                },
              },
              [
                option(
                  attributes: {'value': ''},
                  [text('Select a data source...')],
                ),
                for (final dataSource in dataSources)
                  option(
                    attributes: {'value': dataSource.id},
                    [
                      text(
                        '${dataSource.name} (${dataSource.type.name.toUpperCase()})',
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ]),

      // Show data source fields if available
      if (model.schemaFields.isNotEmpty)
        div([
          h4(classes: 'text-sm font-medium text-foreground mb-2', [
            text('Available Fields'),
          ]),
          p(classes: 'text-xs text-muted-foreground mb-2', [
            text('These fields are available from your selected data source.'),
          ]),
          div(classes: 'flex flex-wrap gap-2', [
            for (final field in model.schemaFields)
              span(
                classes:
                    'px-2 py-1 text-xs rounded border border-gray-300 text-gray-700',
                [text('{{$field}}')],
              ),
          ]),
        ]),
    ]);
  }

  Component _buildTemplateEditor() {
    return div([
      h3(classes: 'text-lg font-medium text-foreground mb-2', [
        text('Template'),
      ]),
      p(classes: 'text-sm text-muted-foreground mb-4', [
        text(
          'Use {{field}} syntax to reference fields. The editor provides auto-completion and syntax highlighting.',
        ),
      ]),
      MonacoEditor(model: model.editor),
    ]);
  }

  Component _buildPreview() {
    return ValueListenableBuilder(
      listenable: model.editor.value,
      builder: (context, _) {
        return div([
          h3(classes: 'text-lg font-medium text-foreground mb-2', [
            text('Preview'),
          ]),
          div(classes: 'bg-muted p-4 rounded-md border min-h-[120px]', [
            pre(classes: 'text-sm whitespace-pre-wrap font-mono', [
              text(model.previewText),
            ]),
          ]),
        ]);
      },
    );
  }
}
