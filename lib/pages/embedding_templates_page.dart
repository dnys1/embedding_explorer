import 'package:embeddings_explorer/components/ui/ui.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/template/template_editor.dart';
import '../components/template/template_editor_model.dart';
import '../models/configuration_manager.dart';
import '../models/embedding_template_config.dart';

class EmbeddingTemplatesPage extends StatefulComponent {
  const EmbeddingTemplatesPage({super.key});

  @override
  State<EmbeddingTemplatesPage> createState() => _EmbeddingTemplatesPageState();
}

class _EmbeddingTemplatesPageState extends State<EmbeddingTemplatesPage> {
  final ConfigurationManager _configManager = ConfigurationManager();
  bool _showCreateDialog = false;
  bool _showEditDialog = false;
  bool _showDeleteDialog = false;
  bool _showPreviewDialog = false;
  EmbeddingTemplateConfig? _editingTemplate;
  EmbeddingTemplateConfig? _deletingTemplate;
  EmbeddingTemplateConfig? _previewingTemplate;
  TemplateEditorModel? _editorModel;

  @override
  void initState() {
    super.initState();
    _configManager.addListener(_onConfigurationChanged);
  }

  @override
  void dispose() {
    _configManager.removeListener(_onConfigurationChanged);
    super.dispose();
  }

  void _onConfigurationChanged() {
    setState(() {});
  }

  void _showCreate() {
    _editorModel = TemplateEditorModel(configManager: _configManager);
    setState(() {
      _editingTemplate = null;
      _showCreateDialog = true;
    });
  }

  void _showEdit(EmbeddingTemplateConfig template) {
    _editorModel = TemplateEditorModel(
      configManager: _configManager,
      initialTemplate: template,
    );
    setState(() {
      _editingTemplate = template;
      _showEditDialog = true;
    });
  }

  void _showDelete(EmbeddingTemplateConfig template) {
    setState(() {
      _deletingTemplate = template;
      _showDeleteDialog = true;
    });
  }

  void _showPreview(EmbeddingTemplateConfig template) {
    setState(() {
      _previewingTemplate = template;
      _showPreviewDialog = true;
    });
  }

  void _hideDialogs() {
    setState(() {
      _showCreateDialog = false;
      _showEditDialog = false;
      _showDeleteDialog = false;
      _showPreviewDialog = false;
      _editingTemplate = null;
      _deletingTemplate = null;
      _previewingTemplate = null;
    });
    _editorModel = null;
  }

  void _saveTemplate() {
    if (_editorModel == null || !_editorModel!.validate()) return;

    final template = _editorModel!.createConfig(
      _editingTemplate?.id ?? _configManager.embeddingTemplates.generateId(),
    );

    _configManager.embeddingTemplates.set(template.id, template);
    _hideDialogs();
  }

  void _deleteTemplate() {
    if (_deletingTemplate != null) {
      _configManager.embeddingTemplates.remove(_deletingTemplate!.id);
      _hideDialogs();
    }
  }

  @override
  Component build(BuildContext context) {
    final templates = _configManager.embeddingTemplates.all;
    final dataSources = _configManager.dataSources.all;

    return div(classes: 'flex flex-col h-full', [
      // Page header
      div(classes: 'bg-white border-b px-6 py-4', [
        div(classes: 'flex justify-between items-center', [
          div([
            h1(classes: 'text-2xl font-bold text-foreground', [
              text('Embedding Templates'),
            ]),
            p(classes: 'mt-1 text-sm text-muted-foreground', [
              text(
                'Manage templates for transforming your data before embedding generation',
              ),
            ]),
          ]),
          if (dataSources.isNotEmpty)
            Button(onPressed: _showCreate, children: [text('+ Add Template')]),
        ]),
      ]),

      // Main content
      div(classes: 'flex-1 p-6', [
        if (dataSources.isEmpty)
          _buildNoDataSourcesState()
        else if (templates.isEmpty)
          _buildEmptyState()
        else
          _buildTemplatesList(templates),
      ]),

      // Dialogs
      if (_showCreateDialog || _showEditDialog) _buildCreateEditDialog(),
      if (_showDeleteDialog) _buildDeleteDialog(),
      if (_showPreviewDialog) _buildPreviewDialog(),
    ]);
  }

  Component _buildNoDataSourcesState() {
    return div(classes: 'text-center py-12', [
      div(classes: 'text-muted-foreground text-6xl mb-4', [text('🗃️')]),
      div(classes: 'text-xl font-semibold text-foreground mb-2', [
        text('No data sources available'),
      ]),
      div(classes: 'text-muted-foreground mb-6', [
        text(
          'You need to create a data source before you can create embedding templates.',
        ),
      ]),
      Button(
        variant: ButtonVariant.primary,
        size: ButtonSize.lg,
        onPressed: () {
          Router.of(context).push('/data-sources');
        },
        children: [text('Create Data Source First')],
      ),
    ]);
  }

  Component _buildEmptyState() {
    return div(classes: 'text-center py-12', [
      div(classes: 'text-muted-foreground text-6xl mb-4', [text('📝')]),
      div(classes: 'text-xl font-semibold text-foreground mb-2', [
        text('No embedding templates configured'),
      ]),
      div(classes: 'text-muted-foreground mb-6', [
        text(
          'Create your first template to define how data is transformed for embeddings',
        ),
      ]),
      Button(
        variant: ButtonVariant.primary,
        size: ButtonSize.lg,
        onPressed: _showCreate,
        children: [text('Create Your First Template')],
      ),
    ]);
  }

  Component _buildTemplatesList(List<EmbeddingTemplateConfig> templates) {
    return div(classes: 'space-y-4', [
      for (final template in templates) _buildTemplateCard(template),
    ]);
  }

  Component _buildTemplateCard(EmbeddingTemplateConfig template) {
    final dataSource = _configManager.dataSources.getById(
      template.dataSourceId,
    );

    return Card(
      className: 'hover:shadow-md transition-shadow',
      children: [
        div(classes: 'flex justify-between items-start', [
          div(classes: 'flex-1', [
            div(classes: 'flex items-center space-x-3 mb-2', [
              h3(classes: 'text-lg font-semibold text-foreground', [
                text(template.name),
              ]),
              Badge(
                variant: template.isValid
                    ? BadgeVariant.secondary
                    : BadgeVariant.destructive,
                children: [text(template.isValid ? 'Valid' : 'Invalid')],
              ),
            ]),
            if (template.description.isNotEmpty)
              p(classes: 'text-sm text-muted-foreground mb-3', [
                text(template.description),
              ]),

            // Data source info
            div(classes: 'mb-3', [
              p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                text('Data Source:'),
              ]),
              Badge(
                variant: dataSource != null
                    ? BadgeVariant.outline
                    : BadgeVariant.destructive,
                children: [
                  text(dataSource?.name ?? 'Missing: ${template.dataSourceId}'),
                ],
              ),
            ]),

            // Available fields
            if (template.availableFields.isNotEmpty)
              div(classes: 'mb-3', [
                p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                  text('Available Fields:'),
                ]),
                div(classes: 'flex flex-wrap gap-1', [
                  for (final field in template.availableFields)
                    Badge(
                      variant: BadgeVariant.secondary,
                      children: [text('{{$field}}')],
                    ),
                ]),
              ]),

            // Template preview (truncated)
            div(classes: 'mb-3', [
              p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                text('Template:'),
              ]),
              div(
                classes:
                    'bg-muted p-2 rounded text-xs font-mono max-h-16 overflow-hidden',
                [
                  text(
                    template.template.length > 100
                        ? '${template.template.substring(0, 100)}...'
                        : template.template,
                  ),
                ],
              ),
            ]),

            div(classes: 'text-xs text-muted-foreground', [
              text('Created ${_formatDate(template.createdAt)}'),
              if (template.updatedAt != template.createdAt)
                text(' • Updated ${_formatDate(template.updatedAt)}'),
            ]),
          ]),
          div(classes: 'flex space-x-2', [
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => _showPreview(template),
              children: [text('Preview')],
            ),
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => _showEdit(template),
              children: [text('Edit')],
            ),
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => _showDelete(template),
              className:
                  'text-destructive border-destructive hover:bg-destructive hover:text-destructive-foreground',
              children: [text('Delete')],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildCreateEditDialog() {
    final isEditing = _editingTemplate != null;
    if (_editorModel == null) return div([]);

    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-6xl w-full mx-4 max-h-[90vh] overflow-y-auto',
          children: [
            CardHeader(
              children: [
                div(classes: 'flex justify-between items-center', [
                  CardTitle(
                    children: [
                      text(isEditing ? 'Edit Template' : 'Create Template'),
                    ],
                  ),
                  button(
                    classes:
                        'text-muted-foreground hover:text-foreground transition-colors text-2xl',
                    events: {'click': (event) => _hideDialogs()},
                    [text('×')],
                  ),
                ]),
                CardDescription(
                  children: [
                    text(
                      isEditing
                          ? 'Update your embedding template with Monaco editor'
                          : 'Create a new embedding template with Monaco editor',
                    ),
                  ],
                ),
              ],
            ),

            CardContent(
              children: [
                // Error message if any
                ListenableBuilder(
                  listenable: _editorModel!,
                  builder: (context) {
                    if (_editorModel!.error case final error?) {
                      return div(
                        classes:
                            'mb-6 bg-red-50 border border-red-200 rounded-md p-4',
                        [
                          div(classes: 'flex', [
                            div(classes: 'flex-shrink-0', [
                              svg(
                                classes: 'h-5 w-5 text-red-400',
                                attributes: {
                                  'fill': 'currentColor',
                                  'viewBox': '0 0 20 20',
                                },
                                [
                                  path(
                                    attributes: {
                                      'fill-rule': 'evenodd',
                                      'd':
                                          'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z',
                                      'clip-rule': 'evenodd',
                                    },
                                    [],
                                  ),
                                ],
                              ),
                            ]),
                            div(classes: 'ml-3', [
                              h3(classes: 'text-sm font-medium text-red-800', [
                                text('Template Error'),
                              ]),
                              div(classes: 'mt-2 text-sm text-red-700', [
                                p([text(error)]),
                              ]),
                              div(classes: 'mt-4', [
                                button(
                                  classes:
                                      'bg-red-100 px-2 py-1 text-sm font-medium text-red-800 rounded-md hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2',
                                  events: {
                                    'click': (_) =>
                                        _editorModel!.dismissError(),
                                  },
                                  [text('Dismiss')],
                                ),
                              ]),
                            ]),
                          ]),
                        ],
                      );
                    }
                    return div([]);
                  },
                ),

                // Template Editor
                TemplateEditor(model: _editorModel!),
              ],
            ),

            CardFooter(
              children: [
                div(classes: 'flex justify-end space-x-3 w-full', [
                  Button(
                    variant: ButtonVariant.outline,
                    onPressed: _hideDialogs,
                    children: [text('Cancel')],
                  ),
                  ListenableBuilder(
                    listenable: _editorModel!,
                    builder: (context) {
                      return Button(
                        onPressed: _editorModel!.validate()
                            ? _saveTemplate
                            : null,
                        children: [text(isEditing ? 'Update' : 'Create')],
                      );
                    },
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _buildDeleteDialog() {
    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-md w-full mx-4',
          children: [
            CardHeader(
              children: [
                CardTitle(children: [text('Delete Template')]),
                CardDescription(
                  children: [
                    text(
                      'Are you sure you want to delete "${_deletingTemplate?.name}"? This action cannot be undone.',
                    ),
                  ],
                ),
              ],
            ),

            CardFooter(
              children: [
                div(classes: 'flex justify-end space-x-3 w-full', [
                  Button(
                    variant: ButtonVariant.outline,
                    onPressed: _hideDialogs,
                    children: [text('Cancel')],
                  ),
                  Button(
                    variant: ButtonVariant.destructive,
                    onPressed: _deleteTemplate,
                    children: [text('Delete')],
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _buildPreviewDialog() {
    if (_previewingTemplate == null) return div([]);

    final template = _previewingTemplate!;
    final dataSource = _configManager.dataSources.getById(
      template.dataSourceId,
    );

    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-2xl w-full mx-4 max-h-[80vh] overflow-y-auto',
          children: [
            CardHeader(
              children: [
                div(classes: 'flex justify-between items-center', [
                  CardTitle(children: [text('Template Preview')]),
                  button(
                    classes:
                        'text-muted-foreground hover:text-foreground transition-colors',
                    events: {'click': (event) => _hideDialogs()},
                    [text('×')],
                  ),
                ]),
                CardDescription(
                  children: [text('Preview of "${template.name}" template')],
                ),
              ],
            ),

            CardContent(
              children: [
                div(classes: 'space-y-4', [
                  // Template info
                  div([
                    h4(classes: 'font-medium text-foreground mb-2', [
                      text('Template Details'),
                    ]),
                    div(classes: 'text-sm space-y-1', [
                      div([
                        span(classes: 'font-medium', [text('Name: ')]),
                        span([text(template.name)]),
                      ]),
                      if (template.description.isNotEmpty)
                        div([
                          span(classes: 'font-medium', [text('Description: ')]),
                          span([text(template.description)]),
                        ]),
                      div([
                        span(classes: 'font-medium', [text('Data Source: ')]),
                        dataSource != null
                            ? Badge(
                                variant: BadgeVariant.outline,
                                children: [
                                  text(
                                    '${dataSource.name} (${dataSource.type.name.toUpperCase()})',
                                  ),
                                ],
                              )
                            : Badge(
                                variant: BadgeVariant.destructive,
                                children: [
                                  text('Missing: ${template.dataSourceId}'),
                                ],
                              ),
                      ]),
                      div([
                        span(classes: 'font-medium', [text('Status: ')]),
                        Badge(
                          variant: template.isValid
                              ? BadgeVariant.secondary
                              : BadgeVariant.destructive,
                          children: [
                            text(template.isValid ? 'Valid' : 'Invalid'),
                          ],
                        ),
                      ]),
                    ]),
                  ]),

                  // Available fields
                  if (template.availableFields.isNotEmpty)
                    div([
                      h4(classes: 'font-medium text-foreground mb-2', [
                        text('Available Fields'),
                      ]),
                      div(classes: 'flex flex-wrap gap-1', [
                        for (final field in template.availableFields)
                          Badge(
                            variant: BadgeVariant.secondary,
                            children: [text('{{$field}}')],
                          ),
                      ]),
                    ]),

                  // Raw template
                  div([
                    h4(classes: 'font-medium text-foreground mb-2', [
                      text('Template'),
                    ]),
                    div(classes: 'bg-muted p-4 rounded-md', [
                      pre(classes: 'text-sm font-mono whitespace-pre-wrap', [
                        text(template.template),
                      ]),
                    ]),
                  ]),

                  // Sample output
                  if (template.availableFields.isNotEmpty)
                    div([
                      h4(classes: 'font-medium text-foreground mb-2', [
                        text('Sample Output'),
                      ]),
                      p(classes: 'text-xs text-muted-foreground mb-2', [
                        text('Example with placeholder data:'),
                      ]),
                      div(classes: 'bg-muted p-4 rounded-md', [
                        pre(classes: 'text-sm whitespace-pre-wrap', [
                          text(_generateSampleOutput(template)),
                        ]),
                      ]),
                    ]),
                ]),
              ],
            ),

            CardFooter(
              children: [
                div(classes: 'flex justify-end w-full', [
                  Button(onPressed: _hideDialogs, children: [text('Close')]),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _generateSampleOutput(EmbeddingTemplateConfig template) {
    final sampleData = <String, String>{};
    for (final field in template.availableFields) {
      switch (field.toLowerCase()) {
        case 'title':
          sampleData[field] = 'Sample Article Title';
          break;
        case 'content':
          sampleData[field] = 'This is sample content for the article...';
          break;
        case 'author':
          sampleData[field] = 'John Doe';
          break;
        case 'date':
          sampleData[field] = '2024-01-15';
          break;
        case 'category':
          sampleData[field] = 'Technology';
          break;
        default:
          sampleData[field] = 'Sample $field value';
      }
    }

    String output = template.template;
    for (final MapEntry(key: field, value: value) in sampleData.entries) {
      output = output.replaceAll('{{$field}}', value);
    }
    return output;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
