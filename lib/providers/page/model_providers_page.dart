import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../model/available_providers.dart';
import '../model/custom_provider_template.dart';
import '../model/model_provider_config.dart';

/// Configuration state for providers
enum ConfigurationState {
  /// No configuration exists
  notConfigured,

  /// Configuration exists but credentials not persisted
  partiallyConfigured,

  /// Configuration exists with persisted credentials
  fullyConfigured,
}

class ModelProvidersPage extends StatefulComponent {
  const ModelProvidersPage({super.key});

  @override
  State<ModelProvidersPage> createState() => _ModelProvidersPageState();
}

class _ModelProvidersPageState extends State<ModelProvidersPage>
    with ConfigurationManagerListener {
  bool _showDeleteDialog = false;
  bool _showCredentialsDialog = false;
  bool _showCustomProviderDialog = false;
  AvailableProvider? _configuringProvider;
  ModelProviderConfig? _deletingProvider;
  ModelProviderConfig? _viewingCredentials;
  CustomProviderTemplate? _configuringCustomProvider;
  CustomProviderTemplate? _deletingCustomProvider;
  String? _editingProviderId;
  String? _editingCustomProviderId;

  // Form state
  String _name = '';
  Map<String, String> _credentials = {};
  Map<String, dynamic> _settings = {};
  bool _persistCredentials = false;
  Set<String> _visibleCredentials =
      {}; // Track which credential fields are visible

  // Custom provider form state
  String _customProviderName = '';
  String _baseUri = '';
  List<String> _requiredCredentials = [];
  List<String> _availableModels = [];
  String _httpMethod = 'POST';
  String _httpPath = '/embeddings';
  Map<String, String> _httpHeaders = {};
  String _httpBodyTemplate = '';

  void _showConfigureProvider(AvailableProvider provider) {
    _resetForm();
    _configuringProvider = provider;

    // Pre-fill form with provider defaults
    _name = provider.name;
    _settings = Map.of(provider.defaultSettings);

    // Initialize credentials map with required keys
    _credentials = Map.fromEntries(
      provider.requiredCredentials.map((key) => MapEntry(key, '')),
    );

    setState(() {
      // _configuringProvider is already set above
    });
  }

  void _showEditConfigDialog(ModelProviderConfig provider) {
    final availableProvider = AvailableProviders.all.firstWhere(
      (p) => p.type == provider.type,
      orElse: () =>
          throw StateError('Provider type ${provider.type} not found'),
    );

    setState(() {
      _configuringProvider = availableProvider;
      _name = provider.name;

      // If credentials weren't persisted, start with empty credentials
      // but remember the user's preference for persistence
      if (provider.persistCredentials) {
        _credentials = Map.of(provider.credentials);
      } else {
        // Initialize with empty credentials but preserve structure
        _credentials = Map.fromEntries(
          availableProvider.requiredCredentials.map((key) => MapEntry(key, '')),
        );
      }

      _settings = Map<String, dynamic>.from(provider.settings);
      _persistCredentials = provider.persistCredentials;
      _editingProviderId = provider.id;
    });
  }

  void _hideDialogs() {
    setState(() {
      _showDeleteDialog = false;
      _showCredentialsDialog = false;
      _showCustomProviderDialog = false;
      _deletingProvider = null;
      _viewingCredentials = null;
      _configuringProvider = null;
      _configuringCustomProvider = null;
      _deletingCustomProvider = null;
      _editingProviderId = null;
      _editingCustomProviderId = null;
      _visibleCredentials =
          {}; // Clear visible credentials when closing dialogs
    });
  }

  void _resetForm() {
    _name = '';
    _credentials = {};
    _settings = {};
    _persistCredentials = false;
    _visibleCredentials = {};
  }

  void _performDelete() {
    if (_deletingProvider != null) {
      configManager.modelProviders.remove(_deletingProvider!.id);
      _hideDialogs();
    } else if (_deletingCustomProvider != null) {
      configManager.customProviderTemplates.remove(_deletingCustomProvider!.id);
      _hideDialogs();
    }
  }

  /// Determine the configuration state for a provider type
  ConfigurationState _getConfigurationState(ProviderType providerType) {
    final config = configManager.modelProviders.getByType(providerType);
    if (config == null) {
      return ConfigurationState.notConfigured;
    }

    // Check if credentials are required and whether they're persisted
    final availableProvider = AvailableProviders.all.firstWhere(
      (p) => p.type == providerType,
      orElse: () => throw StateError('Provider type $providerType not found'),
    );

    if (availableProvider.requiredCredentials.isNotEmpty) {
      // If credentials are required but not persisted, it's partially configured
      if (!config.persistCredentials || config.credentials.isEmpty) {
        return ConfigurationState.partiallyConfigured;
      }

      // Check if all required credentials are present
      for (final requiredCred in availableProvider.requiredCredentials) {
        if (!config.credentials.containsKey(requiredCred) ||
            config.credentials[requiredCred]?.isEmpty == true) {
          return ConfigurationState.partiallyConfigured;
        }
      }
    }

    return ConfigurationState.fullyConfigured;
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col h-full', [
      // Page header
      div(classes: 'bg-white border-b px-4 py-3', [
        div(classes: 'flex justify-between items-center', [
          div([
            h1(classes: 'text-xl font-bold text-foreground', [
              text('Model Providers'),
            ]),
            p(classes: 'text-xs text-muted-foreground', [
              text(
                'Configure embedding model providers and manage their available models',
              ),
            ]),
          ]),
        ]),
      ]),

      // Main content - Provider rows
      div(classes: 'flex-1 p-6 overflow-y-auto', [
        div(classes: 'space-y-6', [
          // Built-in providers section
          div([
            h2(classes: 'text-xl font-semibold text-foreground mb-4', [
              text('Built-in Providers'),
            ]),
            div(classes: 'space-y-4', [
              for (final availableProvider in AvailableProviders.all)
                _buildProviderRow(
                  availableProvider,
                  _getConfigurationState(availableProvider.type),
                ),
            ]),
          ]),

          // Custom provider templates section
          _buildCustomProviderTemplatesSection(),
        ]),
      ]),

      // Dialogs
      if (_configuringProvider != null) _buildConfigDialog(),
      if (_configuringCustomProvider != null)
        _buildCustomProviderConfigDialog(),
      if (_showDeleteDialog) _buildDeleteDialog(),
      if (_showCredentialsDialog) _buildCredentialsDialog(),
      if (_showCustomProviderDialog) _buildCustomProviderDialog(),
    ]);
  }

  Component _buildProviderRow(
    AvailableProvider provider,
    ConfigurationState configState,
  ) {
    final bool isConfigured = configState != ConfigurationState.notConfigured;
    final bool isPartiallyConfigured =
        configState == ConfigurationState.partiallyConfigured;
    final bool isFullyConfigured =
        configState == ConfigurationState.fullyConfigured;

    return Card(
      className: 'border border-gray-200',
      children: [
        div(classes: 'p-5', [
          // Provider header with name and gear switch
          div(classes: 'flex items-center justify-between mb-4', [
            div(classes: 'flex items-center space-x-4', [
              div(classes: 'text-3xl', [text(provider.icon)]),
              div([
                h2(classes: 'text-xl font-semibold text-foreground', [
                  text(provider.name),
                ]),
                p(classes: 'text-sm text-muted-foreground', [
                  text(provider.description),
                ]),
              ]),
            ]),
            div(classes: 'flex items-center space-x-3', [
              // Configuration status badge
              if (isFullyConfigured)
                span(
                  classes:
                      'text-xs px-2 py-1 bg-green-100 text-green-800 rounded-full',
                  [text('Configured')],
                )
              else if (isPartiallyConfigured)
                span(
                  classes:
                      'text-xs px-2 py-1 bg-amber-100 text-amber-800 rounded-full',
                  [text('⚠️ Needs Credentials')],
                )
              else
                span(
                  classes:
                      'text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full',
                  [text('Not configured')],
                ),
              // Gear switch for provider configuration
              button(
                classes: isConfigured
                    ? (isPartiallyConfigured
                          ? 'p-2 rounded-md bg-amber-100 hover:bg-amber-200 text-amber-600 transition-colors'
                          : 'p-2 rounded-md bg-blue-100 hover:bg-blue-200 text-blue-600 transition-colors')
                    : 'p-2 rounded-md bg-gray-100 hover:bg-gray-200 text-gray-600 transition-colors',
                events: {
                  'click': (_) => isConfigured
                      ? _showEditExisting(provider.type)
                      : _showConfigureProvider(provider),
                },
                [
                  div(classes: 'text-lg', [text('⚙️')]),
                ],
              ),
            ]),
          ]),

          // Warning message for partially configured providers
          if (isPartiallyConfigured)
            div(
              classes:
                  'mb-3 p-2 bg-amber-50 border border-amber-200 rounded-md',
              [
                div(classes: 'flex items-center space-x-2', [
                  div(classes: 'text-amber-600 text-sm', [text('⚠️')]),
                  p(classes: 'text-xs text-amber-800', [
                    text(
                      'Missing credentials. Click the gear button to configure.',
                    ),
                  ]),
                ]),
              ],
            ),

          // Model grid
          div(
            classes:
                'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4',
            [
              for (final model in provider.availableModels)
                _buildModelTile(model, provider, isConfigured),
            ],
          ),
        ]),
      ],
    );
  }

  Component _buildModelTile(
    AvailableModel model,
    AvailableProvider provider,
    bool isProviderConfigured,
  ) {
    // Get the detailed configuration state
    final configState = _getConfigurationState(provider.type);
    final isFullyConfigured = configState == ConfigurationState.fullyConfigured;
    final isPartiallyConfigured =
        configState == ConfigurationState.partiallyConfigured;

    // Check if this specific model is enabled for this provider type
    bool isModelEnabled = false;
    String? providerConfigId;

    if (isProviderConfigured) {
      final config = configManager.modelProviders.getByType(provider.type);
      if (config != null) {
        providerConfigId = config.id;
        isModelEnabled = config.enabledModels.contains(model.id);
      }
    }

    // Determine card styling based on configuration state
    String cardClassName;
    Map<String, void Function(Event)> events = {};

    if (isFullyConfigured) {
      cardClassName = isModelEnabled
          ? 'border border-green-300 bg-green-50 hover:bg-green-100 cursor-pointer transition-colors'
          : 'border border-gray-300 bg-gray-50 hover:bg-gray-100 cursor-pointer transition-colors';
      if (providerConfigId != null) {
        events = {'click': (_) => _toggleModel(model, providerConfigId!)};
      }
    } else if (isPartiallyConfigured) {
      cardClassName =
          'border border-amber-300 bg-amber-50 cursor-not-allowed opacity-75';
    } else {
      cardClassName =
          'border border-gray-200 bg-gray-100 cursor-not-allowed opacity-60';
    }

    return Card(
      className: cardClassName,
      children: [
        div(classes: 'p-4', events: events, [
          div(classes: 'flex items-center justify-between mb-2', [
            div(classes: 'flex items-center space-x-2', [
              h3(classes: 'text-sm font-medium text-foreground', [
                text(model.name),
              ]),
              if (model.isRecommended)
                span(
                  classes:
                      'text-xs px-1 py-0.5 bg-blue-100 text-blue-800 rounded',
                  [text('★')],
                ),
            ]),
            // Status indicator based on configuration state
            if (isFullyConfigured)
              div(
                classes: isModelEnabled ? 'text-green-500' : 'text-gray-400',
                [text(isModelEnabled ? '●' : '○')],
              )
            else if (isPartiallyConfigured)
              div(classes: 'text-amber-500', [text('⚠')])
            else
              div(classes: 'text-gray-300', [text('○')]),
          ]),

          p(classes: 'text-xs text-muted-foreground mb-2', [
            text(model.description),
          ]),

          // Show warning for partially configured providers
          if (isPartiallyConfigured)
            p(classes: 'text-xs text-amber-600 mb-2 font-medium', [
              text('⚠️ Add credentials to enable'),
            ])
          else if (!isProviderConfigured)
            p(classes: 'text-xs text-gray-500 mb-2', [
              text('Configure provider first'),
            ]),

          div(classes: 'text-xs text-gray-500', [text('ID: ${model.id}')]),
        ]),
      ],
    );
  }

  void _toggleModel(AvailableModel model, String providerConfigId) {
    final success = configManager.modelProviders.toggleModel(
      providerConfigId,
      model.id,
    );
    if (success) {
      setState(() {}); // Refresh the UI
      print('Toggled model ${model.id} for provider config $providerConfigId');
    } else {
      print('Failed to toggle model ${model.id}');
    }
  }

  void _showEditExisting(ProviderType type) {
    final existingProvider = configManager.modelProviders.getByType(type);
    if (existingProvider != null) {
      // For now, just edit the first one. In the future, we could show a list
      _showEditConfigDialog(existingProvider);
    }
  }

  Component _buildCustomProviderTemplatesSection() {
    final customTemplates = configManager.customProviderTemplates.all;

    return section(id: 'custom', [
      div(classes: 'flex justify-between items-center mb-3', [
        h2(classes: 'text-lg font-semibold text-foreground', [
          text('Custom Providers'),
        ]),
        Button(
          variant: ButtonVariant.primary,
          size: ButtonSize.sm,
          onPressed: () => _showCreateCustomProvider(),
          children: [text('+ Add Custom Provider')],
        ),
      ]),

      if (customTemplates.isEmpty)
        Card(
          className: 'border border-gray-200',
          children: [
            div(classes: 'p-6 text-center', [
              div(classes: 'text-3xl mb-2', [text('🔧')]),
              h3(classes: 'text-base font-medium text-foreground mb-2', [
                text('No Custom Providers'),
              ]),
              Tooltip(
                content:
                    'Create custom provider templates to connect to your own embedding endpoints.',
                child: p(classes: 'text-xs text-muted-foreground mb-3', [
                  text('Create templates for your own embedding endpoints.'),
                ]),
              ),
              Button(
                variant: ButtonVariant.primary,
                size: ButtonSize.sm,
                onPressed: () => _showCreateCustomProvider(),
                children: [text('Create First Custom Provider')],
              ),
            ]),
          ],
        )
      else
        div(classes: 'space-y-3', [
          for (final template in customTemplates)
            _buildCustomProviderTemplateRow(template),
        ]),
    ]);
  }

  Component _buildCustomProviderTemplateRow(CustomProviderTemplate template) {
    // Check if this template has any configurations
    final config = configManager.modelProviders.getByCustomTemplate(
      template.id,
    );
    final isConfigured = config != null;

    return Card(
      className: 'border border-gray-200',
      children: [
        div(classes: 'p-4', [
          div(classes: 'flex items-center justify-between mb-3', [
            div(classes: 'flex items-center space-x-3 min-w-0 flex-1', [
              div(classes: 'text-2xl', [text('🔧')]),
              div(classes: 'min-w-0 flex-1', [
                h3(classes: 'text-base font-semibold text-foreground', [
                  text(template.name),
                ]),
                Tooltip(
                  content:
                      '${template.baseUri} • ${template.availableModels.length} models available',
                  child: p(classes: 'text-xs text-muted-foreground truncate', [
                    text(
                      '${template.baseUri} • ${template.availableModels.length} models',
                    ),
                  ]),
                ),
              ]),
            ]),
            div(classes: 'flex items-center space-x-3', [
              if (isConfigured)
                span(
                  classes:
                      'text-xs px-2 py-1 bg-green-100 text-green-800 rounded-full',
                  [text(config.name)],
                )
              else
                span(
                  classes:
                      'text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full',
                  [text('Not configured')],
                ),
              button(
                classes:
                    'p-2 rounded-md bg-blue-100 hover:bg-blue-200 text-blue-600 transition-colors',
                events: {
                  'click': (_) => _showConfigureCustomProvider(template),
                },
                [text('⚙️')],
              ),
              button(
                classes:
                    'p-2 rounded-md bg-gray-100 hover:bg-gray-200 text-gray-600 transition-colors',
                events: {'click': (_) => _showEditCustomProvider(template)},
                [text('✏️')],
              ),
              button(
                classes:
                    'p-2 rounded-md bg-red-100 hover:bg-red-200 text-red-600 transition-colors',
                events: {'click': (_) => _showDeleteCustomProvider(template)},
                [text('🗑️')],
              ),
            ]),
          ]),

          // Show available models
          if (template.availableModels.isNotEmpty)
            div(classes: 'mt-3', [
              p(classes: 'text-xs font-medium text-foreground mb-1', [
                text('Models:'),
              ]),
              div(classes: 'flex flex-wrap gap-1', [
                for (final model in template.availableModels.take(3))
                  span(
                    classes:
                        'text-xs px-1.5 py-0.5 bg-blue-100 text-blue-800 rounded',
                    [text(model)],
                  ),
                if (template.availableModels.length > 3)
                  Tooltip(
                    content: template.availableModels.skip(3).join(', '),
                    child: span(
                      classes:
                          'text-xs px-1.5 py-0.5 bg-gray-100 text-gray-600 rounded',
                      [text('+${template.availableModels.length - 3} more')],
                    ),
                  ),
              ]),
            ]),

          // Show configured instances
          if (config != null)
            div(classes: 'mt-3', [
              div(
                classes:
                    'flex items-center justify-between p-2 bg-gray-50 rounded text-xs',
                [
                  span(classes: 'font-medium text-foreground', [
                    text('Config: ${config.name}'),
                  ]),
                  div(classes: 'flex space-x-1', [
                    button(
                      classes:
                          'text-xs px-2 py-1 bg-blue-600 text-white rounded hover:bg-blue-700',
                      events: {'click': (_) => _showEditConfigDialog(config)},
                      [text('Edit')],
                    ),
                    button(
                      classes:
                          'text-xs px-2 py-1 bg-red-600 text-white rounded hover:bg-red-700',
                      events: {
                        'click': (_) => _showDeleteProviderConfig(config),
                      },
                      [text('Delete')],
                    ),
                  ]),
                ],
              ),
            ]),
        ]),
      ],
    );
  }

  void _showCreateCustomProvider() {
    _resetCustomProviderForm();
    setState(() {
      _showCustomProviderDialog = true;
      _configuringCustomProvider = null;
      _editingCustomProviderId = null;
    });
  }

  void _showEditCustomProvider(CustomProviderTemplate template) {
    _loadCustomProviderForm(template);
    setState(() {
      _showCustomProviderDialog = true;
      _configuringCustomProvider = template;
      _editingCustomProviderId = template.id;
    });
  }

  void _showConfigureCustomProvider(CustomProviderTemplate template) {
    // Reset the form and set up for custom provider configuration
    _resetForm();

    setState(() {
      _name = '${template.name} Configuration';
      _credentials = Map.fromEntries(
        template.requiredCredentials.map((key) => MapEntry(key, '')),
      );
      _settings = {};
      _persistCredentials = false;
      _editingProviderId = null;
      _configuringProvider = null; // This will be null for custom providers
      _configuringCustomProvider =
          template; // Store the template being configured

      // Show the configuration dialog (we'll create a special one for custom providers)
    });
  }

  void _showDeleteCustomProvider(CustomProviderTemplate template) {
    setState(() {
      _deletingCustomProvider = template;
      _showDeleteDialog = true;
    });
  }

  void _showDeleteProviderConfig(ModelProviderConfig config) {
    setState(() {
      _deletingProvider = config;
      _showDeleteDialog = true;
    });
  }

  void _resetCustomProviderForm() {
    _customProviderName = '';
    _baseUri = '';
    _requiredCredentials = [];
    _availableModels = [];
    _httpMethod = 'POST';
    _httpPath = '/embeddings';
    _httpHeaders = {};
    _httpBodyTemplate = '{"input": "{{input}}", "model": "{{model}}"}';
  }

  void _loadCustomProviderForm(CustomProviderTemplate template) {
    _customProviderName = template.name;
    _baseUri = template.baseUri;
    _requiredCredentials = List.from(template.requiredCredentials);
    _availableModels = List.from(template.availableModels);
    _httpMethod = template.embeddingRequestTemplate.method.name;
    _httpPath = template.embeddingRequestTemplate.path;
    _httpHeaders = Map.from(template.embeddingRequestTemplate.headers);
    _httpBodyTemplate = template.embeddingRequestTemplate.bodyTemplate ?? '';
  }

  Component _buildCustomProviderDialog() {
    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-2xl w-full max-h-[90vh] mx-4 overflow-y-auto',
          children: [
            CardHeader(
              children: [
                CardTitle(
                  children: [
                    text(
                      _editingCustomProviderId != null
                          ? 'Edit Custom Provider'
                          : 'Create Custom Provider',
                    ),
                  ],
                ),
                CardDescription(
                  children: [
                    text(
                      'Configure a custom embedding provider with API endpoint and request template.',
                    ),
                  ],
                ),
              ],
            ),
            CardContent(
              children: [
                div(classes: 'space-y-6', [
                  // Basic Information
                  div(classes: 'space-y-4', [
                    h3(classes: 'text-lg font-semibold text-foreground', [
                      text('Basic Information'),
                    ]),

                    // Provider Name
                    div(classes: 'space-y-2', [
                      label(classes: 'text-sm font-medium text-foreground', [
                        text('Provider Name *'),
                      ]),
                      input(
                        classes:
                            'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                        attributes: {
                          'placeholder': 'My Custom Provider',
                          'value': _customProviderName,
                        },
                        events: {
                          'input': (event) {
                            setState(() {
                              _customProviderName =
                                  (event.target as HTMLInputElement).value;
                            });
                          },
                        },
                      ),
                    ]),

                    // Base URI
                    div(classes: 'space-y-2', [
                      label(classes: 'text-sm font-medium text-foreground', [
                        text('Base URI *'),
                      ]),
                      input(
                        classes:
                            'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                        attributes: {
                          'placeholder': 'https://api.example.com',
                          'value': _baseUri,
                        },
                        events: {
                          'input': (event) {
                            setState(() {
                              _baseUri =
                                  (event.target as HTMLInputElement).value;
                            });
                          },
                        },
                      ),
                    ]),
                  ]),

                  // HTTP Request Configuration
                  div(classes: 'space-y-4', [
                    h3(classes: 'text-lg font-semibold text-foreground', [
                      text('API Configuration'),
                    ]),

                    // HTTP Method and Path
                    div(classes: 'grid grid-cols-2 gap-4', [
                      div(classes: 'space-y-2', [
                        label(classes: 'text-sm font-medium text-foreground', [
                          text('HTTP Method'),
                        ]),
                        select(
                          classes:
                              'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                          events: {
                            'change': (event) {
                              setState(() {
                                _httpMethod =
                                    (event.target as HTMLSelectElement).value;
                              });
                            },
                          },
                          [
                            option(
                              attributes: {
                                'value': 'GET',
                                if (_httpMethod == 'GET') 'selected': '',
                              },
                              [text('GET')],
                            ),
                            option(
                              attributes: {
                                'value': 'POST',
                                if (_httpMethod == 'POST') 'selected': '',
                              },
                              [text('POST')],
                            ),
                            option(
                              attributes: {
                                'value': 'PUT',
                                if (_httpMethod == 'PUT') 'selected': '',
                              },
                              [text('PUT')],
                            ),
                          ],
                        ),
                      ]),

                      div(classes: 'space-y-2', [
                        label(classes: 'text-sm font-medium text-foreground', [
                          text('API Path *'),
                        ]),
                        input(
                          classes:
                              'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                          attributes: {
                            'placeholder': '/embeddings',
                            'value': _httpPath,
                          },
                          events: {
                            'input': (event) {
                              setState(() {
                                _httpPath =
                                    (event.target as HTMLInputElement).value;
                              });
                            },
                          },
                        ),
                      ]),
                    ]),

                    // Request Body Template
                    div(classes: 'space-y-2', [
                      label(classes: 'text-sm font-medium text-foreground', [
                        text('Request Body Template'),
                      ]),
                      textarea(
                        classes:
                            'flex min-h-[120px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                        attributes: {
                          'placeholder':
                              '{"input": "{{text}}", "model": "{{model}}"}',
                          'value': _httpBodyTemplate,
                        },
                        events: {
                          'input': (event) {
                            setState(() {
                              _httpBodyTemplate =
                                  (event.target as HTMLTextAreaElement).value;
                            });
                          },
                        },
                        [],
                      ),
                      p(classes: 'text-xs text-muted-foreground', [
                        text(
                          'Use {{text}} for input text and {{model}} for model name. Other credentials can be referenced with {{credential_name}}.',
                        ),
                      ]),
                    ]),
                  ]),

                  // Models and Credentials
                  div(classes: 'space-y-4', [
                    h3(classes: 'text-lg font-semibold text-foreground', [
                      text('Models & Authentication'),
                    ]),

                    // Available Models
                    div(classes: 'space-y-2', [
                      label(classes: 'text-sm font-medium text-foreground', [
                        text('Available Models'),
                      ]),
                      div(classes: 'space-y-2', [
                        for (int i = 0; i < _availableModels.length; i++)
                          div(classes: 'flex gap-2', [
                            input(
                              classes:
                                  'flex h-10 flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                              attributes: {
                                'placeholder': 'model-name',
                                'value': _availableModels[i],
                              },
                              events: {
                                'input': (event) {
                                  setState(() {
                                    _availableModels[i] =
                                        (event.target as HTMLInputElement)
                                            .value;
                                  });
                                },
                              },
                            ),
                            button(
                              classes:
                                  'px-3 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors',
                              events: {
                                'click': (_) {
                                  setState(() {
                                    _availableModels.removeAt(i);
                                  });
                                },
                              },
                              [text('Remove')],
                            ),
                          ]),
                        button(
                          classes:
                              'px-3 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors',
                          events: {
                            'click': (_) {
                              setState(() {
                                _availableModels.add('');
                              });
                            },
                          },
                          [text('+ Add Model')],
                        ),
                      ]),
                    ]),

                    // Required Credentials
                    div(classes: 'space-y-2', [
                      label(classes: 'text-sm font-medium text-foreground', [
                        text('Required Credentials'),
                      ]),
                      div(classes: 'space-y-2', [
                        for (int i = 0; i < _requiredCredentials.length; i++)
                          div(classes: 'flex gap-2', [
                            input(
                              classes:
                                  'flex h-10 flex-1 rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                              attributes: {
                                'placeholder': 'api_key',
                                'value': _requiredCredentials[i],
                              },
                              events: {
                                'input': (event) {
                                  setState(() {
                                    _requiredCredentials[i] =
                                        (event.target as HTMLInputElement)
                                            .value;
                                  });
                                },
                              },
                            ),
                            button(
                              classes:
                                  'px-3 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors',
                              events: {
                                'click': (_) {
                                  setState(() {
                                    _requiredCredentials.removeAt(i);
                                  });
                                },
                              },
                              [text('Remove')],
                            ),
                          ]),
                        button(
                          classes:
                              'px-3 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors',
                          events: {
                            'click': (_) {
                              setState(() {
                                _requiredCredentials.add('');
                              });
                            },
                          },
                          [text('+ Add Credential')],
                        ),
                      ]),
                    ]),
                  ]),
                ]),
              ],
            ),
            CardFooter(
              children: [
                div(classes: 'flex space-x-2 w-full', [
                  button(
                    classes:
                        'flex-1 px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors',
                    events: {'click': (_) => _hideDialogs()},
                    [text('Cancel')],
                  ),
                  button(
                    classes:
                        'flex-1 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed',
                    attributes: {
                      if (_customProviderName.trim().isEmpty ||
                          _baseUri.trim().isEmpty)
                        'disabled': '',
                    },
                    events: {'click': (_) => _saveCustomProvider()},
                    [
                      text(
                        _editingCustomProviderId != null
                            ? 'Update Provider'
                            : 'Create Provider',
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveCustomProvider() async {
    if (_customProviderName.trim().isEmpty || _baseUri.trim().isEmpty) return;

    try {
      // Filter out empty values
      final filteredModels = _availableModels
          .where((model) => model.trim().isNotEmpty)
          .toList();
      final filteredCredentials = _requiredCredentials
          .where((cred) => cred.trim().isNotEmpty)
          .toList();

      if (_editingCustomProviderId != null) {
        // Update existing template
        final success = configManager.customProviderTemplates.updateTemplate(
          _editingCustomProviderId!,
          name: _customProviderName.trim(),
          baseUri: _baseUri.trim(),
          requiredCredentials: filteredCredentials,
          availableModels: filteredModels,
          embeddingRequestTemplate: HttpRequestTemplate(
            method: HttpMethod.values.firstWhere(
              (m) => m.name.toLowerCase() == _httpMethod.toLowerCase(),
              orElse: () => HttpMethod.post,
            ),
            path: _httpPath.trim(),
            headers: Map.from(_httpHeaders),
            bodyTemplate: _httpBodyTemplate.trim().isNotEmpty
                ? _httpBodyTemplate.trim()
                : null,
          ),
        );

        if (success) {
          _hideDialogs();
        }
      } else {
        // Create new template
        configManager.customProviderTemplates.addTemplate(
          name: _customProviderName.trim(),
          baseUri: _baseUri.trim(),
          requiredCredentials: filteredCredentials,
          availableModels: filteredModels,
          embeddingRequestTemplate: HttpRequestTemplate(
            method: HttpMethod.values.firstWhere(
              (m) => m.name.toLowerCase() == _httpMethod.toLowerCase(),
              orElse: () => HttpMethod.post,
            ),
            path: _httpPath.trim(),
            headers: Map.from(_httpHeaders),
            bodyTemplate: _httpBodyTemplate.trim().isNotEmpty
                ? _httpBodyTemplate.trim()
                : null,
          ),
        );

        _hideDialogs();
      }
    } catch (e) {
      print('Error saving custom provider: $e');
      // TODO: Show error message to user
    }
  }

  Component _buildCustomProviderConfigDialog() {
    if (_configuringCustomProvider == null) return div([]);

    final template = _configuringCustomProvider!;

    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-lg w-full mx-4',
          children: [
            CardHeader(
              children: [
                CardTitle(
                  children: [
                    text(
                      _editingProviderId != null
                          ? 'Edit Configuration'
                          : 'Configure ${template.name}',
                    ),
                  ],
                ),
                CardDescription(
                  children: [
                    text(
                      'Set up credentials and configuration for this custom provider.',
                    ),
                  ],
                ),
              ],
            ),
            CardContent(
              children: [
                div(classes: 'space-y-6', [
                  // Configuration Name
                  div(classes: 'space-y-2', [
                    label(classes: 'text-sm font-medium text-foreground', [
                      text('Configuration Name *'),
                    ]),
                    input(
                      classes:
                          'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                      attributes: {
                        'placeholder': 'My ${template.name} Config',
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

                  // Credentials
                  if (template.requiredCredentials.isNotEmpty) ...[
                    div(classes: 'space-y-4', [
                      h3(classes: 'text-lg font-semibold text-foreground', [
                        text('Credentials'),
                      ]),
                      for (final credentialKey in template.requiredCredentials)
                        div(classes: 'space-y-2', [
                          label(classes: 'text-sm font-medium text-foreground', [
                            text(
                              '${credentialKey.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')} *',
                            ),
                          ]),
                          div(classes: 'relative', [
                            input(
                              classes:
                                  'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 pr-10 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                              attributes: {
                                'type':
                                    _visibleCredentials.contains(credentialKey)
                                    ? 'text'
                                    : 'password',
                                'placeholder':
                                    'Enter your ${credentialKey.replaceAll('_', ' ')}',
                                'value': _credentials[credentialKey] ?? '',
                              },
                              events: {
                                'input': (event) {
                                  setState(() {
                                    _credentials[credentialKey] =
                                        (event.target as HTMLInputElement)
                                            .value;
                                  });
                                },
                              },
                            ),
                            button(
                              classes:
                                  'absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground transition-colors',
                              attributes: {
                                'type': 'button',
                                'title':
                                    _visibleCredentials.contains(credentialKey)
                                    ? 'Hide credential'
                                    : 'Show credential',
                              },
                              events: {
                                'click': (_) {
                                  setState(() {
                                    if (_visibleCredentials.contains(
                                      credentialKey,
                                    )) {
                                      _visibleCredentials.remove(credentialKey);
                                    } else {
                                      _visibleCredentials.add(credentialKey);
                                    }
                                  });
                                },
                              },
                              [
                                text(
                                  _visibleCredentials.contains(credentialKey)
                                      ? '🙈'
                                      : '👁️',
                                ),
                              ],
                            ),
                          ]),
                        ]),
                    ]),

                    // Credential persistence option
                    _buildCredentialsPersistenceSection(),
                  ],

                  // Available Models
                  if (template.availableModels.isNotEmpty)
                    div(classes: 'space-y-4', [
                      h3(classes: 'text-lg font-semibold text-foreground', [
                        text('Available Models'),
                      ]),
                      div(classes: 'grid grid-cols-2 gap-2', [
                        for (final model in template.availableModels)
                          div(
                            classes:
                                'flex items-center space-x-2 p-2 border rounded cursor-pointer hover:bg-gray-50',
                            [
                              input(
                                attributes: {
                                  'type': 'checkbox',
                                  'id': 'model_$model',
                                  'checked':
                                      '', // For now, enable all models by default
                                },
                                classes: 'rounded',
                              ),
                              label(
                                attributes: {'for': 'model_$model'},
                                classes: 'text-sm cursor-pointer',
                                [text(model)],
                              ),
                            ],
                          ),
                      ]),
                    ]),
                ]),
              ],
            ),
            CardFooter(
              children: [
                div(classes: 'flex space-x-2 w-full', [
                  button(
                    classes:
                        'flex-1 px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors',
                    events: {'click': (_) => _hideDialogs()},
                    [text('Cancel')],
                  ),
                  button(
                    classes:
                        'flex-1 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed',
                    attributes: {
                      if (_name.trim().isEmpty ||
                          !_areRequiredCredentialsFilled(template))
                        'disabled': '',
                    },
                    events: {
                      'click': (_) => _saveCustomProviderConfiguration(),
                    },
                    [
                      text(
                        _editingProviderId != null
                            ? 'Update Configuration'
                            : 'Create Configuration',
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  bool _areRequiredCredentialsFilled(CustomProviderTemplate template) {
    for (final credential in template.requiredCredentials) {
      if (_credentials[credential]?.trim().isEmpty ?? true) {
        return false;
      }
    }
    return true;
  }

  void _saveCustomProviderConfiguration() async {
    if (_configuringCustomProvider == null || _name.trim().isEmpty) return;

    final template = _configuringCustomProvider!;

    try {
      if (_editingProviderId != null) {
        // Update existing configuration
        final success = configManager.modelProviders.updateConfig(
          _editingProviderId!,
          name: _name.trim(),
          credentials: _persistCredentials
              ? Map<String, String>.from(_credentials)
              : {},
          settings: Map<String, dynamic>.from(_settings),
          persistCredentials: _persistCredentials,
          enabledModels: Set<String>.from(
            template.availableModels,
          ), // Enable all models by default for now
        );

        if (success) {
          _hideDialogs();
        }
      } else {
        // Create new configuration using custom template
        configManager.modelProviders.addCustomConfig(
          name: _name.trim(),
          customTemplateId: template.id,
          credentials: _persistCredentials
              ? Map<String, String>.from(_credentials)
              : {},
          settings: Map<String, dynamic>.from(_settings),
          persistCredentials: _persistCredentials,
          enabledModels: Set<String>.from(
            template.availableModels,
          ), // Enable all models by default for now
        );

        _hideDialogs();
      }
    } catch (e) {
      print('Error saving custom provider configuration: $e');
      // TODO: Show error message to user
    }
  }

  Component _buildCredentialsPersistenceSection() {
    return div(classes: 'space-y-3', [
      div(classes: 'flex items-start space-x-3', [
        input(
          attributes: {
            'type': 'checkbox',
            'id': 'persistCredentials',
            if (_persistCredentials) 'checked': '',
          },
          classes: 'mt-1',
          events: {
            'change': (event) {
              setState(() {
                _persistCredentials =
                    (event.target as HTMLInputElement).checked;
              });
            },
          },
        ),
        div(classes: 'flex-1', [
          label(
            attributes: {'for': 'persistCredentials'},
            classes: 'text-sm font-medium text-foreground cursor-pointer',
            [text('Store credentials locally')],
          ),
          p(classes: 'text-xs text-muted-foreground mt-1', [
            text(
              'If checked, credentials will be saved in browser storage. If unchecked, you\'ll need to re-enter them each session.',
            ),
          ]),
        ]),
      ]),

      if (!_persistCredentials)
        div(
          classes:
              'flex items-center space-x-2 p-3 bg-amber-50 border border-amber-200 rounded-md',
          [
            span(classes: 'text-amber-600', [text('⚠️')]),
            p(classes: 'text-sm text-amber-800', [
              text(
                'Credentials will not be saved. You\'ll need to re-enter them each time you reload the page.',
              ),
            ]),
          ],
        ),
    ]);
  }

  Component _buildOpenAIConfig() {
    return div(classes: 'space-y-4', [
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [
          text('API Key *'),
        ]),
        div(classes: 'relative', [
          input(
            classes:
                'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 pr-10 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
            attributes: {
              'type': _visibleCredentials.contains('apiKey')
                  ? 'text'
                  : 'password',
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
          button(
            classes:
                'absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground transition-colors',
            attributes: {
              'type': 'button',
              'title': _visibleCredentials.contains('apiKey')
                  ? 'Hide API key'
                  : 'Show API key',
            },
            events: {
              'click': (_) {
                setState(() {
                  if (_visibleCredentials.contains('apiKey')) {
                    _visibleCredentials.remove('apiKey');
                  } else {
                    _visibleCredentials.add('apiKey');
                  }
                });
              },
            },
            [text(_visibleCredentials.contains('apiKey') ? '🙈' : '👁️')],
          ),
        ]),
      ]),
    ]);
  }

  Component _buildGeminiConfig() {
    return div(classes: 'space-y-4', [
      div(classes: 'space-y-2', [
        label(classes: 'text-sm font-medium text-foreground', [
          text('API Key *'),
        ]),
        div(classes: 'relative', [
          input(
            classes:
                'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 pr-10 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
            attributes: {
              'type': _visibleCredentials.contains('apiKey')
                  ? 'text'
                  : 'password',
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
          button(
            classes:
                'absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground transition-colors',
            attributes: {
              'type': 'button',
              'title': _visibleCredentials.contains('apiKey')
                  ? 'Hide API key'
                  : 'Show API key',
            },
            events: {
              'click': (_) {
                setState(() {
                  if (_visibleCredentials.contains('apiKey')) {
                    _visibleCredentials.remove('apiKey');
                  } else {
                    _visibleCredentials.add('apiKey');
                  }
                });
              },
            },
            [text(_visibleCredentials.contains('apiKey') ? '🙈' : '👁️')],
          ),
        ]),
      ]),
    ]);
  }

  Component _buildDeleteDialog() {
    String itemName = '';
    String itemType = '';

    if (_deletingProvider != null) {
      itemName = _deletingProvider!.name;
      itemType = 'configuration';
    } else if (_deletingCustomProvider != null) {
      itemName = _deletingCustomProvider!.name;
      itemType = 'custom provider template';
    }

    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-md w-full mx-4',
          children: [
            CardHeader(
              children: [
                CardTitle(
                  children: [
                    text(
                      'Delete ${itemType.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}',
                    ),
                  ],
                ),
                CardDescription(
                  children: [
                    text(
                      'Are you sure you want to delete "$itemName"? This action cannot be undone.',
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
                    onPressed: _performDelete,
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

  Component _buildConfigDialog() {
    if (_configuringProvider == null) return div([]);

    final provider = _configuringProvider!;

    return div(
      classes:
          'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
      [
        Card(
          className: 'max-w-2xl w-full mx-4',
          children: [
            CardHeader(
              children: [
                div(classes: 'flex justify-between items-center', [
                  CardTitle(children: [text('Configure ${provider.name}')]),
                  button(
                    classes:
                        'text-muted-foreground hover:text-foreground transition-colors',
                    events: {'click': (event) => _hideDialogs()},
                    [text('×')],
                  ),
                ]),
                if (provider.description.isNotEmpty)
                  CardDescription(children: [text(provider.description)]),
              ],
            ),

            CardContent(
              children: [
                div(classes: 'space-y-6', [_buildCredentialsSection()]),
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
                    onPressed: _configuringProvider != null
                        ? _saveConfiguration
                        : null,
                    children: [text('Save Configuration')],
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _buildCredentialsSection() {
    if (_configuringProvider == null) return div([]);

    final provider = _configuringProvider!;

    return div(classes: 'space-y-4', [
      h3(classes: 'text-lg font-semibold text-foreground', [
        text('Credentials'),
      ]),
      _buildProviderCredentialsForm(provider),

      // Credential persistence checkbox
      div(classes: 'flex items-center space-x-2 pt-3 border-t border-gray-200', [
        input(
          classes:
              'w-4 h-4 text-blue-600 rounded border-gray-300 focus:ring-blue-500',
          attributes: {
            'type': 'checkbox',
            'id': 'persist-credentials',
            if (_persistCredentials) 'checked': 'checked',
          },
          events: {
            'change': (event) {
              setState(() {
                _persistCredentials =
                    (event.target as HTMLInputElement).checked;
              });
            },
          },
        ),
        label(
          classes: 'text-sm text-gray-700 cursor-pointer',
          attributes: {'for': 'persist-credentials'},
          [text('Remember credentials for future sessions')],
        ),
      ]),

      if (_persistCredentials)
        div(
          classes:
              'text-xs text-amber-600 bg-amber-50 p-2 rounded border border-amber-200',
          [
            text(
              '⚠️ Warning: Credentials will be stored locally in your browser. Only enable this if you trust this device.',
            ),
          ],
        )
      else
        div(
          classes:
              'text-xs text-gray-500 bg-gray-50 p-2 rounded border border-gray-200',
          [
            text(
              '💡 Credentials will only be kept for this session and not saved to storage.',
            ),
          ],
        ),
    ]);
  }

  Component _buildProviderCredentialsForm(AvailableProvider provider) {
    switch (provider.type) {
      case ProviderType.openai:
        return _buildOpenAIConfig();
      case ProviderType.gemini:
        return _buildGeminiConfig();
      case ProviderType.custom:
        return div([]); // Handled in custom provider dialog
    }
  }

  void _saveConfiguration() async {
    if (_configuringProvider == null || _name.trim().isEmpty) return;

    final provider = _configuringProvider!;

    try {
      if (_editingProviderId != null) {
        // Update existing configuration
        final existingConfig = configManager.modelProviders.getById(
          _editingProviderId!,
        );
        if (existingConfig != null) {
          final updatedConfig = existingConfig.copyWith(
            name: _name.trim(),
            description: provider.description,
            credentials: Map<String, String>.from(_credentials),
            settings: Map<String, dynamic>.from(_settings),
            persistCredentials: _persistCredentials,
            updatedAt: DateTime.now(),
          );
          configManager.modelProviders.set(_editingProviderId!, updatedConfig);
        }
      } else {
        // Add new configuration
        ConfigurationManager.instance.modelProviders.addConfig(
          name: _name.trim(),
          type: provider.type,
          description: provider.description,
          credentials: Map<String, String>.from(_credentials),
          settings: Map<String, dynamic>.from(_settings),
          persistCredentials: _persistCredentials,
          isActive: true,
        );
      }

      setState(() {
        _loadProviders();
        _hideDialogs();
      });

      print('Provider configuration saved successfully');
    } catch (e) {
      print('Failed to save provider configuration: $e');
    }
  }

  void _loadProviders() {
    // Refresh the provider list from ConfigurationManager
    setState(() {
      // The configured providers will be automatically updated through the ConfigurationManager
    });
  }
}
