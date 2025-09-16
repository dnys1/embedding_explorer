import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../component/create_edit_template_dialog.dart';
import '../component/delete_template_dialog.dart';
import '../component/preview_template_dialog.dart';
import '../model/embedding_template.dart';

class EmbeddingTemplatesPage extends StatefulComponent {
  const EmbeddingTemplatesPage({super.key});

  @override
  State<EmbeddingTemplatesPage> createState() => _EmbeddingTemplatesPageState();
}

class _EmbeddingTemplatesPageState extends State<EmbeddingTemplatesPage>
    with ConfigurationManagerListener {
  bool _showCreateDialog = false;
  bool _showEditDialog = false;
  bool _showDeleteDialog = false;
  bool _showPreviewDialog = false;
  EmbeddingTemplate? _editingTemplate;
  EmbeddingTemplate? _deletingTemplate;
  EmbeddingTemplate? _previewingTemplate;

  void _showCreate() {
    setState(() {
      _editingTemplate = null;
      _showCreateDialog = true;
    });
  }

  void _showEdit(EmbeddingTemplate template) {
    setState(() {
      _editingTemplate = template;
      _showEditDialog = true;
    });
  }

  void _showDelete(EmbeddingTemplate template) {
    setState(() {
      _deletingTemplate = template;
      _showDeleteDialog = true;
    });
  }

  void _showPreview(EmbeddingTemplate template) {
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
  }

  @override
  Component build(BuildContext context) {
    final templates = configManager.embeddingTemplates.all;
    final dataSources = configManager.dataSourceConfigs.all;

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
      if (_showCreateDialog || _showEditDialog)
        CreateEditTemplateDialog(
          template: _editingTemplate,
          onClose: _hideDialogs,
        ),
      if (_showDeleteDialog)
        DeleteTemplateDialog(
          template: _deletingTemplate,
          onClose: _hideDialogs,
        ),
      if (_showPreviewDialog)
        PreviewTemplateDialog(
          template: _previewingTemplate!,
          onClose: _hideDialogs,
        ),
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

  Component _buildTemplatesList(List<EmbeddingTemplate> templates) {
    return div(classes: 'space-y-4', [
      for (final template in templates) _buildTemplateCard(template),
    ]);
  }

  Component _buildTemplateCard(EmbeddingTemplate template) {
    final dataSource = configManager.dataSourceConfigs.getById(
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

            // Templates preview (truncated)
            div(classes: 'mb-3 space-y-2', [
              // ID Template preview
              div([
                p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                  text('ID Template:'),
                ]),
                div(
                  classes:
                      'bg-muted p-2 rounded text-xs font-mono max-h-8 overflow-hidden',
                  [
                    text(
                      template.idTemplate.length > 50
                          ? '${template.idTemplate.substring(0, 50)}...'
                          : template.idTemplate,
                    ),
                  ],
                ),
              ]),

              // Body Template preview
              div([
                p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                  text('Body Template:'),
                ]),
                div(
                  classes:
                      'bg-muted p-2 rounded text-xs font-mono max-h-12 overflow-hidden',
                  [
                    text(
                      template.template.length > 80
                          ? '${template.template.substring(0, 80)}...'
                          : template.template,
                    ),
                  ],
                ),
              ]),
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
