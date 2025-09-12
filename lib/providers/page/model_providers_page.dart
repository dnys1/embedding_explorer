import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' hide Credential;

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../credentials/model/credential.dart';
import '../component/available_providers_view.dart';
import '../model/available_providers.dart';
import '../model/custom_provider_template.dart';
import '../model/model_provider_config.dart';

class ModelProvidersPage extends StatefulComponent {
  const ModelProvidersPage({super.key});

  @override
  State<ModelProvidersPage> createState() => _ModelProvidersPageState();
}

class _ModelProvidersPageState extends State<ModelProvidersPage>
    with ConfigurationManagerListener {
  bool _showDeleteDialog = false;
  bool _showCustomProviderDialog = false;
  AvailableProvider? _configuringProvider;
  ModelProviderConfig? _deletingProvider;
  CustomProviderTemplate? _deletingCustomProvider;
  String? _editingProviderId;
  String? _editingCustomProviderId;

  // Form state
  String _name = '';
  Credential? _credential;
  Map<String, dynamic> _settings = {};
  bool _persistCredentials = false;
  bool _credentialsVisible = false;

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
      _credential = provider.credential;
      _settings = Map<String, dynamic>.from(provider.settings);
      _persistCredentials = provider.persistCredentials;
      _editingProviderId = provider.id;
    });
  }

  void _hideDialogs() {
    setState(() {
      _showDeleteDialog = false;
      _showCustomProviderDialog = false;
      _deletingProvider = null;
      _configuringProvider = null;
      _deletingCustomProvider = null;
      _editingProviderId = null;
      _editingCustomProviderId = null;
      _credentialsVisible = false;
    });
  }

  void _resetForm() {
    _name = '';
    _credential = null;
    _settings = {};
    _persistCredentials = false;
    _credentialsVisible = false;
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
              for (final provider in AvailableProviders.all)
                AvailableProviderView(
                  provider: provider,
                  onConfigure: () => _showConfigureProvider(provider),
                  onEdit: () => _showEditExisting(provider.type),
                ),
            ]),
          ]),

          // Custom provider templates section
          _buildCustomProviderTemplatesSection(),
        ]),
      ]),

      // Dialogs
      if (_configuringProvider != null) _buildConfigDialog(),
      if (_showDeleteDialog) _buildDeleteDialog(),
      if (_showCustomProviderDialog) _buildCustomProviderDialog(),
    ]);
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
              div(classes: 'text-5xl mb-6', [FaIcons.solid.hammer]),
              h3(classes: 'text-base font-medium text-foreground mb-2', [
                text('No Custom Providers'),
              ]),
              div([
                Tooltip(
                  content:
                      'Create custom provider templates to connect to your own embedding endpoints.',
                  child: p(
                    classes: 'text-xs text-muted-foreground mb-4 block',
                    [
                      text(
                        'Create templates for your own embedding endpoints.',
                      ),
                    ],
                  ),
                ),
              ]),
              div([
                Button(
                  variant: ButtonVariant.primary,
                  size: ButtonSize.sm,
                  onPressed: () => _showCreateCustomProvider(),
                  children: [text('Create First Custom Provider')],
                ),
              ]),
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
              div(classes: 'text-2xl', [FaIcons.solid.hammer]),
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
                [FaIcons.solid.settings],
              ),
              button(
                classes:
                    'p-2 rounded-md bg-gray-100 hover:bg-gray-200 text-gray-600 transition-colors',
                events: {'click': (_) => _showEditCustomProvider(template)},
                [FaIcons.solid.edit],
              ),
              button(
                classes:
                    'p-2 rounded-md bg-red-100 hover:bg-red-200 text-red-600 transition-colors',
                events: {'click': (_) => _showDeleteCustomProvider(template)},
                [FaIcons.solid.delete],
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
      _editingCustomProviderId = null;
    });
  }

  void _showEditCustomProvider(CustomProviderTemplate template) {
    _loadCustomProviderForm(template);
    setState(() {
      _showCustomProviderDialog = true;
      _editingCustomProviderId = template.id;
    });
  }

  void _showConfigureCustomProvider(CustomProviderTemplate template) {
    // Reset the form and set up for custom provider configuration
    _resetForm();

    setState(() {
      _name = '${template.name} Configuration';
      _credential = null;
      _settings = {};
      _persistCredentials = false;
      _editingProviderId = null;
      _configuringProvider = null; // This will be null for custom providers

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
        final success = await configManager.customProviderTemplates
            .updateTemplate(
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

        if (!mounted) return;
        if (success) {
          _hideDialogs();
        }
      } else {
        // Create new template
        configManager.customProviderTemplates
            .addTemplate(
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
            )
            .ignore();

        _hideDialogs();
      }
    } catch (e) {
      print('Error saving custom provider: $e');
      // TODO: Show error message to user
    }
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
              'type': _credentialsVisible ? 'text' : 'password',
              'placeholder': 'sk-...',
              'value': switch (_credential) {
                ApiKeyCredential(:final apiKey) => apiKey,
                _ => '',
              },
            },
            events: {
              'input': (event) {
                setState(() {
                  _credential = ApiKeyCredential(
                    apiKey: (event.target as HTMLInputElement).value,
                  );
                });
              },
            },
          ),
          button(
            classes:
                'absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground transition-colors',
            attributes: {
              'type': 'button',
              'title': _credentialsVisible ? 'Hide API key' : 'Show API key',
            },
            events: {
              'click': (_) {
                setState(() {
                  _credentialsVisible = !_credentialsVisible;
                });
              },
            },
            [_credentialsVisible ? FaIcons.solid.eyeSlash : FaIcons.solid.eye],
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
              'type': _credentialsVisible ? 'text' : 'password',
              'placeholder': 'AIza...',
              'value': switch (_credential) {
                ApiKeyCredential(:final apiKey) => apiKey,
                _ => '',
              },
            },
            events: {
              'input': (event) {
                setState(() {
                  _credential = ApiKeyCredential(
                    apiKey: (event.target as HTMLInputElement).value,
                  );
                });
              },
            },
          ),
          button(
            classes:
                'absolute inset-y-0 right-0 flex items-center px-3 text-muted-foreground hover:text-foreground transition-colors',
            attributes: {
              'type': 'button',
              'title': _credentialsVisible ? 'Hide API key' : 'Show API key',
            },
            events: {
              'click': (_) {
                setState(() {
                  _credentialsVisible = !_credentialsVisible;
                });
              },
            },
            [_credentialsVisible ? FaIcons.solid.eyeSlash : FaIcons.solid.eye],
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
            div(classes: 'flex items-center space-x-1', [
              FaIcons.solid.warning,
              text(
                'Warning: Credentials will be stored locally in your browser. Only enable this if you trust this device.',
              ),
            ]),
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

  void _saveConfiguration() {
    if (_configuringProvider == null || _name.trim().isEmpty) return;

    final provider = _configuringProvider!;

    try {
      if (_editingProviderId case final id?) {
        // Update existing configuration
        final existingConfig = configManager.modelProviders.getById(id);
        if (existingConfig != null) {
          configManager.modelProviders
              .updateConfig(
                id,
                name: _name.trim(),
                credential: _credential,
                settings: _settings,
                persistCredentials: _persistCredentials,
                enabledModels: existingConfig.enabledModels,
              )
              .ignore();
        }
      } else {
        // Add new configuration
        configManager.modelProviders
            .addConfig(
              name: _name.trim(),
              type: provider.type,
              description: provider.description,
              credential: _credential,
              settings: _settings,
              persistCredentials: _persistCredentials,
              isActive: true,
            )
            .ignore();
      }

      _hideDialogs();

      print('Provider configuration saved successfully');
    } catch (e) {
      print('Failed to save provider configuration: $e');
    }
  }
}
