import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../component/data_source_selector.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart' as config;

class DataSourcesPage extends StatefulComponent {
  const DataSourcesPage({super.key});

  @override
  State<DataSourcesPage> createState() => _DataSourcePageState();
}

class _DataSourcePageState extends State<DataSourcesPage>
    with ConfigurationManagerListener {
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

  void _showEdit(config.DataSourceConfig dataSource) {
    setState(() {
      _isEditing = true;
      _selectedDataSource = DataSource.fromConfig(dataSource);
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

  void _saveDataSource(DataSource dataSource) {
    // DataSource now contains its own config, so we can use it directly
    var configToSave = dataSource.config;

    // If this is a new data source (no existing ID), generate one
    if (_selectedDataSource == null) {
      configToSave = configToSave.copyWith(
        id: configManager.dataSources.generateId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      // Update existing data source
      configToSave = configToSave.copyWith(updatedAt: DateTime.now());
    }

    configManager.dataSources.set(configToSave.id, configToSave);
    _hideDialog();
  }

  void _deleteDataSource(config.DataSourceConfig dataSource) {
    configManager.dataSources.remove(dataSource.id);
  }

  @override
  Component build(BuildContext context) {
    final dataSources = configManager.dataSources.all;

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
      if (_showCreateDialog) _buildDataSourceDialog(),
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

  Component _buildDataSourcesList(List<config.DataSourceConfig> dataSources) {
    return div(classes: 'space-y-4', [
      for (final dataSource in dataSources) _buildDataSourceCard(dataSource),
    ]);
  }

  Component _buildDataSourceCard(config.DataSourceConfig dataSource) {
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
                variant: dataSource.type == config.DataSourceType.csv
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

  Component _buildAvailableFieldsSection(
    config.DataSourceConfig dataSourceConfig,
  ) {
    return FutureBuilder<Map<String, String>>(
      future: _getDataSourceSchema(dataSourceConfig),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return div(classes: 'mb-3', [
            p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
              text('Available Fields:'),
            ]),
            p(classes: 'text-xs text-destructive', [
              text('Error loading fields'),
            ]),
          ]);
        }

        if (!snapshot.hasData) {
          return div(classes: 'mb-3', [
            p(classes: 'text-xs font-medium text-muted-foreground mb-1', [
              text('Available Fields:'),
            ]),
            p(classes: 'text-xs text-muted-foreground', [text('Loading...')]),
          ]);
        }

        final schema = snapshot.data!;
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
                  Tooltip(child: text(field), content: schema[field]!),
                ],
              ),
          ]),
        ]);
      },
    );
  }

  Future<Map<String, String>> _getDataSourceSchema(
    config.DataSourceConfig dataSourceConfig,
  ) async {
    try {
      final dataSource = DataSource.fromConfig(dataSourceConfig);
      final connected = await dataSource.connect();
      if (!connected) {
        return {};
      }
      final schema = await dataSource.getSchema();
      await dataSource.disconnect();
      return schema;
    } catch (e) {
      print(
        'Error getting schema for data source ${dataSourceConfig.name}: $e',
      );
      return {};
    }
  }

  Component _buildDataSourceDialog() {
    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto',
          children: [
            CardHeader(
              children: [
                div(classes: 'flex justify-between items-center', [
                  CardTitle(
                    as: Heading.h2,
                    children: [
                      text(
                        _isEditing ? 'Edit Data Source' : 'Create Data Source',
                      ),
                    ],
                  ),
                  button(
                    classes:
                        'text-muted-foreground hover:text-foreground transition-colors text-2xl',
                    events: {'click': (event) => _hideDialog()},
                    [text('×')],
                  ),
                ]),
                CardDescription(
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

            CardContent(
              children: [
                // Error message if any
                if (_errorMessage != null)
                  div(
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
                            text('Configuration Error'),
                          ]),
                          div(classes: 'mt-2 text-sm text-red-700', [
                            p([text(_errorMessage!)]),
                          ]),
                        ]),
                      ]),
                    ],
                  ),

                // Success message if data source is selected
                if (_selectedDataSource != null)
                  div(
                    classes:
                        'mb-6 bg-green-50 border border-green-200 rounded-md p-4',
                    [
                      div(classes: 'flex', [
                        div(classes: 'flex-shrink-0', [
                          svg(
                            classes: 'h-5 w-5 text-green-400',
                            attributes: {
                              'fill': 'currentColor',
                              'viewBox': '0 0 20 20',
                            },
                            [
                              path(
                                attributes: {
                                  'fill-rule': 'evenodd',
                                  'd':
                                      'M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z',
                                  'clip-rule': 'evenodd',
                                },
                                [],
                              ),
                            ],
                          ),
                        ]),
                        div(classes: 'ml-3', [
                          h3(classes: 'text-sm font-medium text-green-800', [
                            text('Data Source Ready'),
                          ]),
                          div(classes: 'mt-2 text-sm text-green-700', [
                            p([
                              text(
                                'Data source "${_selectedDataSource!.name}" is configured and ready to save.',
                              ),
                            ]),
                          ]),
                        ]),
                      ]),
                    ],
                  ),

                // DataSourceSelector component
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
              ],
            ),

            CardFooter(
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
