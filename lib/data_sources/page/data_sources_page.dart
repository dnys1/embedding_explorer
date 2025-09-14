import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../util/async_snapshot.dart';
import '../component/data_source_selector.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart';
import '../service/data_source_repository.dart';

class DataSourcesPage extends StatefulComponent {
  const DataSourcesPage({super.key});

  @override
  State<DataSourcesPage> createState() => _DataSourcePageState();
}

class _DataSourcePageState extends State<DataSourcesPage>
    with ConfigurationManagerListener {
  DataSourceRepository get _repository => configManager.dataSources;

  bool _showCreateDialog = false;
  bool _isEditing = false;
  DataSource? _selectedDataSource;
  String? _errorMessage;

  void _showCreate() {
    setState(() {
      _isEditing = false;
      _selectedDataSource = null;
      _errorMessage = null;
      _showCreateDialog = true;
    });
  }

  void _showEdit(DataSource dataSource) {
    setState(() {
      _isEditing = true;
      _selectedDataSource = dataSource;
      _errorMessage = null;
      _showCreateDialog = true;
    });
  }

  void _hideDialog() {
    setState(() {
      _showCreateDialog = false;
      _isEditing = false;
      _selectedDataSource = null;
      _errorMessage = null;
    });
  }

  void _saveDataSource(DataSource dataSource) async {
    // DataSource now contains its own config, so we can use it directly
    var configToSave = dataSource.config;

    // If this is a new data source (no existing ID), generate one
    if (_selectedDataSource == null) {
      configToSave = configToSave.copyWith(
        id: configManager.dataSourceConfigs.generateId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      // Update existing data source
      configToSave = configToSave.copyWith(updatedAt: DateTime.now());
    }

    await configManager.dataSourceConfigs.upsert(configToSave);
    _hideDialog();
  }

  void _deleteDataSource(DataSource dataSource) {
    configManager.dataSources.delete(dataSource.id);
  }

  @override
  Component build(BuildContext context) {
    final dataSources = _repository.all;

    return div(classes: 'flex flex-col h-full', [
      // Page header
      div(classes: 'bg-white border-b px-6 py-4', [
        div(classes: 'flex justify-between items-center', [
          div([
            h1(classes: 'text-2xl font-bold text-foreground', [
              text('Data Sources'),
            ]),
            p(classes: 'mt-1 text-sm text-muted-foreground', [
              text('Manage your data sources for embedding generation'),
            ]),
          ]),
          Button(onPressed: _showCreate, children: [text('+ Add Data Source')]),
        ]),
      ]),

      // Main content
      div(classes: 'flex-1 p-6', [
        if (dataSources.isEmpty)
          _buildEmptyState()
        else
          _buildDataSourcesList(dataSources),
      ]),

      // Create/Edit Dialog
      Dialog(
        isOpen: _showCreateDialog,
        onClose: _hideDialog,
        maxWidth: 'max-w-4xl',
        builder: (_) => _buildDataSourceDialogContent(),
      ),
    ]);
  }

  Component _buildEmptyState() {
    return div(classes: 'text-center py-12', [
      div(classes: 'text-muted-foreground text-6xl mb-4', [text('🗃️')]),
      div(classes: 'text-xl font-semibold text-foreground mb-2', [
        text('No data sources configured'),
      ]),
      div(classes: 'text-muted-foreground mb-6', [
        text('Add your first data source to start generating embeddings'),
      ]),
      Button(
        variant: ButtonVariant.primary,
        size: ButtonSize.lg,
        onPressed: _showCreate,
        children: [text('Add Your First Data Source')],
      ),
    ]);
  }

  Component _buildDataSourcesList(List<DataSource> dataSources) {
    return div(classes: 'space-y-4', [
      for (final dataSource in dataSources) _buildDataSourceCard(dataSource),
    ]);
  }

  Component _buildDataSourceCard(DataSource dataSource) {
    return Card(
      className: 'hover:shadow-md transition-shadow',
      children: [
        div(classes: 'flex justify-between items-start', [
          div(classes: 'flex-1', [
            div(classes: 'flex items-center space-x-3 mb-2', [
              h3(classes: 'text-lg font-semibold text-foreground', [
                text(dataSource.name),
              ]),
              Badge(
                variant: dataSource.type == DataSourceType.csv
                    ? BadgeVariant.secondary
                    : BadgeVariant.outline,
                children: [text(dataSource.type.name.toUpperCase())],
              ),
            ]),
            if (dataSource.description.isNotEmpty)
              p(classes: 'text-sm text-muted-foreground mb-3', [
                text(dataSource.description),
              ]),

            // Available fields from schema
            _buildAvailableFieldsSection(dataSource),

            div(classes: 'text-xs text-muted-foreground', [
              text('Created ${_formatDate(dataSource.createdAt)}'),
              if (dataSource.updatedAt != dataSource.createdAt)
                text(' • Updated ${_formatDate(dataSource.updatedAt)}'),
            ]),
          ]),
          div(classes: 'flex space-x-2', [
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => _showEdit(dataSource),
              children: [text('Edit')],
            ),
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => _deleteDataSource(dataSource),
              className:
                  'text-destructive border-destructive hover:bg-destructive hover:text-destructive-foreground',
              children: [text('Delete')],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildAvailableFieldsSection(DataSource dataSource) {
    return FutureBuilder<Map<String, DataSourceFieldType>>(
      future: dataSource.getSchema(),
      builder: (context, snapshot) {
        switch (snapshot.result) {
          case AsyncError():
            return div(classes: 'mb-3', [
              p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                text('Available Fields:'),
              ]),
              p(classes: 'text-xs text-destructive', [
                text('Error loading fields'),
              ]),
            ]);
          case AsyncLoading():
            return div(classes: 'mb-3', [
              p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                text('Available Fields:'),
              ]),
              p(classes: 'text-xs text-muted-foreground', [text('Loading...')]),
            ]);
          case AsyncData(data: final schema):
            if (schema.isEmpty) {
              return div(classes: 'mb-3', [
                p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                  text('Available Fields:'),
                ]),
                p(classes: 'text-xs text-muted-foreground', [
                  text('No fields detected'),
                ]),
              ]);
            }

            return div(classes: 'mb-3', [
              p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
                text('Available Fields (${schema.length}):'),
              ]),
              div(classes: 'flex flex-wrap gap-1', [
                for (final field in schema.keys)
                  Badge(
                    variant: BadgeVariant.secondary,
                    children: [
                      Tooltip(child: text(field), content: schema[field]!.name),
                    ],
                  ),
              ]),
            ]);
        }
      },
    );
  }

  Component _buildDataSourceDialogContent() {
    return DialogContent(
      children: [
        DialogHeader(
          children: [
            div(classes: 'flex justify-between items-center', [
              DialogTitle(
                children: [
                  text(_isEditing ? 'Edit Data Source' : 'Create Data Source'),
                ],
              ),
              IconButton(
                onPressed: _hideDialog,
                icon: FaIcon(FaIcons.solid.close),
              ),
            ]),
            DialogDescription(
              children: [
                text(
                  _isEditing
                      ? 'Update your data source configuration'
                      : 'Configure a new data source for embedding generation',
                ),
              ],
            ),
          ],
        ),

        // Error message, if any
        if (_errorMessage case final errorMessage?)
          div(classes: 'bg-red-50 border border-red-200 rounded-md p-3', [
            div(classes: 'flex items-start', [
              div(classes: 'flex-shrink-0', [
                span(classes: 'text-red-500 text-lg', [text('⚠️')]),
              ]),
              div(classes: 'ml-2 flex-1 min-w-0', [
                p(classes: 'text-sm font-medium text-red-800', [
                  text('Configuration Error'),
                ]),
                p(classes: 'text-sm text-red-700 mt-1 break-words', [
                  text(errorMessage),
                ]),
              ]),
            ]),
          ]),

        // Success message if data source is selected
        if (_selectedDataSource case final selectedDataSource?)
          div(classes: 'bg-green-50 border border-green-200 rounded-md p-3', [
            div(classes: 'flex items-start', [
              div(classes: 'flex-shrink-0', [
                span(classes: 'text-green-500 text-lg', [text('✅')]),
              ]),
              div(classes: 'ml-2 flex-1 min-w-0', [
                p(classes: 'text-sm font-medium text-green-800', [
                  text('Data Source Ready'),
                ]),
                p(classes: 'text-sm text-green-700 mt-1 break-words', [
                  text(
                    'Data source "${selectedDataSource.name}" is configured and ready to save.',
                  ),
                ]),
              ]),
            ]),
          ]),

        // DataSourceSelector component
        div(classes: 'min-w-0 overflow-hidden', [
          DataSourceSelector(
            onDataSourceSelected: (dataSource) {
              setState(() {
                _selectedDataSource = dataSource;
                _errorMessage = null;
              });
            },
            onError: (message) {
              setState(() {
                _errorMessage = message;
              });
            },
            initialDataSource: _selectedDataSource,
          ),
        ]),

        DialogFooter(
          children: [
            div(classes: 'flex justify-end space-x-3 w-full', [
              Button(
                variant: ButtonVariant.outline,
                onPressed: _hideDialog,
                children: [text('Cancel')],
              ),
              Button(
                onPressed: _selectedDataSource != null
                    ? () => _saveDataSource(_selectedDataSource!)
                    : null,
                children: [text(_isEditing ? 'Update' : 'Create')],
              ),
            ]),
          ],
        ),
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
