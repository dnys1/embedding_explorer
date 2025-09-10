import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../components/ui/ui.dart';
import '../models/configuration_manager.dart';
import '../models/model_provider_config.dart';

class ModelProvidersPage extends StatefulComponent {
  const ModelProvidersPage({super.key});

  @override
  State<ModelProvidersPage> createState() => _ModelProvidersPageState();
}

class _ModelProvidersPageState extends State<ModelProvidersPage> {
  final ConfigurationManager _configManager = ConfigurationManager();
  bool _showCreateDialog = false;
  bool _showEditDialog = false;
  bool _showDeleteDialog = false;
  bool _showCredentialsDialog = false;
  ModelProviderConfig? _editingProvider;
  ModelProviderConfig? _deletingProvider;
  ModelProviderConfig? _viewingCredentials;

  // Form state
  String _name = '';
  String _description = '';
  ProviderType _type = ProviderType.openai;
  bool _isActive = true;
  Map<String, String> _credentials = {};
  Map<String, dynamic> _settings = {};

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
    _resetForm();
    setState(() {
      _showCreateDialog = true;
    });
  }

  void _showEdit(ModelProviderConfig provider) {
    _loadFormFromProvider(provider);
    setState(() {
      _editingProvider = provider;
      _showEditDialog = true;
    });
  }

  void _showDelete(ModelProviderConfig provider) {
    setState(() {
      _deletingProvider = provider;
      _showDeleteDialog = true;
    });
  }

  void _showCredentials(ModelProviderConfig provider) {
    setState(() {
      _viewingCredentials = provider;
      _showCredentialsDialog = true;
    });
  }

  void _hideDialogs() {
    setState(() {
      _showCreateDialog = false;
      _showEditDialog = false;
      _showDeleteDialog = false;
      _showCredentialsDialog = false;
      _editingProvider = null;
      _deletingProvider = null;
      _viewingCredentials = null;
    });
  }

  void _resetForm() {
    _name = '';
    _description = '';
    _type = ProviderType.openai;
    _isActive = true;
    _credentials = {};
    _settings = {};
  }

  void _loadFormFromProvider(ModelProviderConfig provider) {
    _name = provider.name;
    _description = provider.description;
    _type = provider.type;
    _isActive = provider.isActive;
    _credentials = Map.of(provider.credentials);
    _settings = Map.of(provider.settings);
  }

  void _saveProvider() {
    if (_name.isEmpty) return;

    final provider = ModelProviderConfig(
      id: _editingProvider?.id ?? _configManager.modelProviders.generateId(),
      name: _name,
      description: _description,
      type: _type,
      credentials: Map.of(_credentials),
      settings: Map.of(_settings),
      isActive: _isActive,
      createdAt: _editingProvider?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _configManager.modelProviders.set(provider.id, provider);
    _hideDialogs();
  }

  void _deleteProvider() {
    if (_deletingProvider != null) {
      _configManager.modelProviders.remove(_deletingProvider!.id);
      _hideDialogs();
    }
  }

  void _toggleProviderActive(ModelProviderConfig provider) {
    _configManager.modelProviders.toggleActive(provider.id);
  }

  @override
  Component build(BuildContext context) {
    final providers = _configManager.modelProviders.all;

    return div(classes: 'flex flex-col h-full', [
      // Page header
      div(classes: 'bg-white border-b px-6 py-4', [
        div(classes: 'flex justify-between items-center', [
          div([
            h1(classes: 'text-2xl font-bold text-foreground', [
              text('Model Providers'),
            ]),
            p(classes: 'mt-1 text-sm text-muted-foreground', [
              text(
                'Manage embedding model providers and their API configurations',
              ),
            ]),
          ]),
          Button(onPressed: _showCreate, children: [text('+ Add Provider')]),
        ]),
      ]),

      // Main content
      div(classes: 'flex-1 p-6', [
        if (providers.isEmpty)
          _buildEmptyState()
        else
          _buildProvidersList(providers),
      ]),

      // Dialogs
      if (_showCreateDialog || _showEditDialog) _buildCreateEditDialog(),
      if (_showDeleteDialog) _buildDeleteDialog(),
      if (_showCredentialsDialog) _buildCredentialsDialog(),
    ]);
  }

  Component _buildEmptyState() {
    return div(classes: 'text-center py-12', [
      div(classes: 'text-muted-foreground text-6xl mb-4', [text('🔗')]),
      div(classes: 'text-xl font-semibold text-foreground mb-2', [
        text('No model providers configured'),
      ]),
      div(classes: 'text-muted-foreground mb-6', [
        text('Add your first model provider to start generating embeddings'),
      ]),
      Button(
        variant: ButtonVariant.primary,
        size: ButtonSize.lg,
        onPressed: _showCreate,
        children: [text('Add Your First Provider')],
      ),
    ]);
  }

  Component _buildProvidersList(List<ModelProviderConfig> providers) {
    return div(classes: 'space-y-4', [
      for (final provider in providers) _buildProviderCard(provider),
    ]);
  }

  Component _buildProviderCard(ModelProviderConfig provider) {
    return Card(
      className: 'hover:shadow-md transition-shadow',
      children: [
        div(classes: 'flex justify-between items-start', [
          div(classes: 'flex-1', [
            div(classes: 'flex items-center space-x-3 mb-2', [
              h3(classes: 'text-lg font-semibold text-foreground', [
                text(provider.name),
              ]),
              Badge(
                variant: _getProviderTypeBadgeVariant(provider.type),
                children: [text(provider.type.name.toUpperCase())],
              ),
              Badge(
                variant: provider.isActive
                    ? BadgeVariant.secondary
                    : BadgeVariant.outline,
                children: [text(provider.isActive ? 'Active' : 'Inactive')],
              ),
              Badge(
                variant: provider.isValid
                    ? BadgeVariant.secondary
                    : BadgeVariant.destructive,
                children: [text(provider.isValid ? 'Valid' : 'Invalid')],
              ),
            ]),
            if (provider.description.isNotEmpty)
              p(classes: 'text-sm text-muted-foreground mb-3', [
                text(provider.description),
              ]),

            // Provider-specific info
            div(classes: 'text-xs text-muted-foreground space-y-1', [
              _buildProviderSpecificInfo(provider),
              div([
                text('Created ${_formatDate(provider.createdAt)}'),
                if (provider.updatedAt != provider.createdAt)
                  text(' • Updated ${_formatDate(provider.updatedAt)}'),
              ]),
            ]),
          ]),
          div(classes: 'flex flex-col space-y-2', [
            div(classes: 'flex space-x-2', [
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () => _showCredentials(provider),
                children: [text('Credentials')],
              ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () => _showEdit(provider),
                children: [text('Edit')],
              ),
            ]),
            div(classes: 'flex space-x-2', [
              Button(
                variant: provider.isActive
                    ? ButtonVariant.outline
                    : ButtonVariant.secondary,
                size: ButtonSize.sm,
                onPressed: () => _toggleProviderActive(provider),
                children: [text(provider.isActive ? 'Deactivate' : 'Activate')],
              ),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () => _showDelete(provider),
                className:
                    'text-destructive border-destructive hover:bg-destructive hover:text-destructive-foreground',
                children: [text('Delete')],
              ),
            ]),
          ]),
        ]),
      ],
    );
  }

  BadgeVariant _getProviderTypeBadgeVariant(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return BadgeVariant.secondary;
      case ProviderType.gemini:
        return BadgeVariant.outline;
      case ProviderType.custom:
        return BadgeVariant.secondary;
    }
  }

  Component _buildProviderSpecificInfo(ModelProviderConfig provider) {
    switch (provider.type) {
      case ProviderType.openai:
        return div([
          text(
            'API: OpenAI • Model: ${provider.settings['model'] ?? 'text-embedding-ada-002'}',
          ),
        ]);
      case ProviderType.gemini:
        return div([
          text(
            'API: Google Gemini • Model: ${provider.settings['model'] ?? 'embedding-001'}',
          ),
        ]);
      case ProviderType.custom:
        return div([
          text(
            'Custom API • Endpoint: ${provider.credentials['endpoint'] ?? 'Not configured'}',
          ),
        ]);
    }
  }

  Component _buildCreateEditDialog() {
    final isEditing = _editingProvider != null;

    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto',
          children: [
            CardHeader(
              children: [
                div(classes: 'flex justify-between items-center', [
                  CardTitle(
                    children: [
                      text(isEditing ? 'Edit Provider' : 'Create Provider'),
                    ],
                  ),
                  button(
                    classes:
                        'text-muted-foreground hover:text-foreground transition-colors',
                    events: {'click': (event) => _hideDialogs()},
                    [text('×')],
                  ),
                ]),
                CardDescription(
                  children: [
                    text(
                      isEditing
                          ? 'Update your model provider configuration'
                          : 'Add a new embedding model provider',
                    ),
                  ],
                ),
              ],
            ),

            CardContent(
              children: [
                div(classes: 'space-y-6', [
                  // Basic Info
                  div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
                    div(classes: 'space-y-2', [
                      label(
                        classes: 'text-sm font-medium text-foreground',
                        attributes: {'for': 'provider-name'},
                        [text('Name *')],
                      ),
                      input(
                        id: 'provider-name',
                        classes:
                            'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
                        attributes: {
                          'placeholder': 'Enter provider name',
                          'value': _name,
                        },
                        events: {
                          'input': (event) {
                            setState(() {
                              _name = (event.target as HTMLInputElement).value;
                            });
                          },
                        },
                      ),
                    ]),
                    div(classes: 'space-y-2', [
                      label(classes: 'text-sm font-medium text-foreground', [
                        text('Type *'),
                      ]),
                      select(
                        classes:
                            'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
                        attributes: {'value': _type.name},
                        events: {
                          'change': (event) {
                            setState(() {
                              _type = ProviderType.values.firstWhere(
                                (t) =>
                                    t.name == (event.target as dynamic).value,
                                orElse: () => ProviderType.openai,
                              );
                              // Reset credentials when type changes
                              _credentials.clear();
                              _settings.clear();
                            });
                          },
                        },
                        [
                          option(
                            attributes: {'value': 'openai'},
                            [text('OpenAI')],
                          ),
                          option(
                            attributes: {'value': 'gemini'},
                            [text('Google Gemini')],
                          ),
                          option(
                            attributes: {'value': 'custom'},
                            [text('Custom API')],
                          ),
                        ],
                      ),
                    ]),
                  ]),

                  div(classes: 'space-y-2', [
                    label(
                      classes: 'text-sm font-medium text-foreground',
                      attributes: {'for': 'provider-desc'},
                      [text('Description')],
                    ),
                    textarea(
                      id: 'provider-desc',
                      classes:
                          'flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
                      attributes: {
                        'placeholder': 'Optional description of this provider',
                        'rows': '2',
                      },
                      events: {
                        'input': (event) {
                          setState(() {
                            _description =
                                (event.target as HTMLInputElement).value;
                          });
                        },
                      },
                      [text(_description)],
                    ),
                  ]),

                  // Provider-specific configuration
                  _buildProviderSpecificConfig(),

                  // Active toggle
                  div(classes: 'flex items-center space-x-2', [
                    input(
                      classes:
                          'h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded',
                      attributes: {
                        'type': 'checkbox',
                        'id': 'is-active',
                        'checked': _isActive.toString(),
                      },
                      events: {
                        'change': (event) {
                          setState(() {
                            _isActive =
                                (event.target as HTMLInputElement).checked;
                          });
                        },
                      },
                    ),
                    label(
                      classes: 'text-sm font-medium text-foreground',
                      attributes: {'for': 'is-active'},
                      [text('Active')],
                    ),
                  ]),
                ]),
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
                    onPressed: _name.isEmpty ? null : _saveProvider,
                    children: [text(isEditing ? 'Update' : 'Create')],
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _buildProviderSpecificConfig() {
    switch (_type) {
      case ProviderType.openai:
        return _buildOpenAIConfig();
      case ProviderType.gemini:
        return _buildGeminiConfig();
      case ProviderType.custom:
        return _buildCustomConfig();
    }
  }

  Component _buildOpenAIConfig() {
    return div(classes: 'space-y-4', [
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [
          text('API Key *'),
        ]),
        input(
          classes:
              'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          attributes: {
            'type': 'password',
            'placeholder': 'sk-...',
            'value': _credentials['apiKey'] ?? '',
          },
          events: {
            'input': (event) {
              setState(() {
                _credentials['apiKey'] =
                    (event.target as HTMLInputElement).value;
              });
            },
          },
        ),
      ]),
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [text('Model')]),
        select(
          classes:
              'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
          attributes: {
            'value': _settings['model'] as String? ?? 'text-embedding-ada-002',
          },
          events: {
            'change': (event) {
              setState(() {
                _settings['model'] = (event.target as HTMLInputElement).value;
              });
            },
          },
          [
            option(
              attributes: {'value': 'text-embedding-ada-002'},
              [text('text-embedding-ada-002')],
            ),
            option(
              attributes: {'value': 'text-embedding-3-small'},
              [text('text-embedding-3-small')],
            ),
            option(
              attributes: {'value': 'text-embedding-3-large'},
              [text('text-embedding-3-large')],
            ),
          ],
        ),
      ]),
    ]);
  }

  Component _buildGeminiConfig() {
    return div(classes: 'space-y-4', [
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [
          text('API Key *'),
        ]),
        input(
          classes:
              'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          attributes: {
            'type': 'password',
            'placeholder': 'AIza...',
            'value': _credentials['apiKey'] ?? '',
          },
          events: {
            'input': (event) {
              setState(() {
                _credentials['apiKey'] =
                    (event.target as HTMLInputElement).value;
              });
            },
          },
        ),
      ]),
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [text('Model')]),
        select(
          classes:
              'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
          attributes: {
            'value': _settings['model'] as String? ?? 'embedding-001',
          },
          events: {
            'change': (event) {
              setState(() {
                _settings['model'] = (event.target as HTMLInputElement).value;
              });
            },
          },
          [
            option(
              attributes: {'value': 'embedding-001'},
              [text('embedding-001')],
            ),
            option(
              attributes: {'value': 'text-embedding-004'},
              [text('text-embedding-004')],
            ),
          ],
        ),
      ]),
    ]);
  }

  Component _buildCustomConfig() {
    return div(classes: 'space-y-4', [
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [
          text('API Endpoint *'),
        ]),
        input(
          classes:
              'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          attributes: {
            'placeholder': 'https://api.example.com/v1/embeddings',
            'value': _credentials['endpoint'] ?? '',
          },
          events: {
            'input': (event) {
              setState(() {
                _credentials['endpoint'] =
                    (event.target as HTMLInputElement).value;
              });
            },
          },
        ),
      ]),
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [
          text('API Key'),
        ]),
        input(
          classes:
              'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          attributes: {
            'type': 'password',
            'placeholder': 'Optional API key',
            'value': _credentials['apiKey'] ?? '',
          },
          events: {
            'input': (event) {
              setState(() {
                _credentials['apiKey'] =
                    (event.target as HTMLInputElement).value;
              });
            },
          },
        ),
      ]),
    ]);
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
                CardTitle(children: [text('Delete Provider')]),
                CardDescription(
                  children: [
                    text(
                      'Are you sure you want to delete "${_deletingProvider?.name}"? This action cannot be undone.',
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
                    onPressed: _deleteProvider,
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

  Component _buildCredentialsDialog() {
    if (_viewingCredentials == null) return div([]);

    final provider = _viewingCredentials!;

    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-md w-full mx-4',
          children: [
            CardHeader(
              children: [
                div(classes: 'flex justify-between items-center', [
                  CardTitle(children: [text('Provider Credentials')]),
                  button(
                    classes:
                        'text-muted-foreground hover:text-foreground transition-colors',
                    events: {'click': (event) => _hideDialogs()},
                    [text('×')],
                  ),
                ]),
                CardDescription(
                  children: [text('Credentials for "${provider.name}"')],
                ),
              ],
            ),

            CardContent(
              children: [
                div(classes: 'space-y-4', [
                  div([
                    h4(classes: 'font-medium text-foreground mb-2', [
                      text('Configuration Status'),
                    ]),
                    Badge(
                      variant: provider.isValid
                          ? BadgeVariant.secondary
                          : BadgeVariant.destructive,
                      children: [
                        text(
                          provider.isValid
                              ? 'Valid Configuration'
                              : 'Invalid Configuration',
                        ),
                      ],
                    ),
                  ]),

                  div([
                    h4(classes: 'font-medium text-foreground mb-2', [
                      text('Credentials'),
                    ]),
                    div(classes: 'space-y-2 text-sm', [
                      for (final MapEntry(key: key, value: value)
                          in provider.credentials.entries)
                        div(
                          classes:
                              'flex justify-between items-center p-2 bg-muted rounded',
                          [
                            span(classes: 'font-medium', [text('$key:')]),
                            span(classes: 'font-mono text-xs', [
                              text(
                                key.toLowerCase().contains('key')
                                    ? '••••••••'
                                    : value,
                              ),
                            ]),
                          ],
                        ),
                    ]),
                  ]),

                  if (provider.settings.isNotEmpty)
                    div([
                      h4(classes: 'font-medium text-foreground mb-2', [
                        text('Settings'),
                      ]),
                      div(classes: 'space-y-2 text-sm', [
                        for (final MapEntry(key: key, value: value)
                            in provider.settings.entries)
                          div(
                            classes:
                                'flex justify-between items-center p-2 bg-muted rounded',
                            [
                              span(classes: 'font-medium', [text('$key:')]),
                              span([text(value.toString())]),
                            ],
                          ),
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
