import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../credentials/model/credential.dart';
import '../component/embedding_provider_config_dialog.dart';
import '../component/embedding_provider_view.dart';
import '../model/custom_provider_template.dart';
import '../model/embedding_provider.dart';
import '../model/embedding_provider_config.dart';

class EmbeddingProvidersPage extends StatefulComponent {
  const EmbeddingProvidersPage({super.key});

  @override
  State<EmbeddingProvidersPage> createState() => _EmbeddingProvidersPageState();
}

class _EmbeddingProvidersPageState extends State<EmbeddingProvidersPage>
    with ConfigurationManagerListener {
  bool _showDeleteDialog = false;
  bool _showCustomProviderDialog = false;
  EmbeddingProvider? _configuringProvider;
  EmbeddingProviderConfig? _deletingProvider;
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

  void _showConfigureProvider(EmbeddingProvider provider) {
    _resetForm();
    _configuringProvider = provider;

    // Pre-fill form with provider defaults
    _name = provider.displayName;
    _settings = Map.of(provider.defaultSettings);

    setState(() {
      // _configuringProvider is already set above
    });
  }

  void _showEditConfigDialog(ConfiguredEmbeddingProvider provider) {
    setState(() {
      _configuringProvider = provider;
      _name = provider.config.name;
      _credential = provider.config.credential;
      _settings = Map<String, dynamic>.of(provider.config.settings);
      _persistCredentials = provider.config.persistCredentials;
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
      configManager.embeddingProviderConfigs.remove(_deletingProvider!.id);
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
              for (final provider in configManager.embeddingProviders.all)
                EmbeddingProviderView(
                  provider: provider,
                  onConfigure: () => _showConfigureProvider(provider),
                  onEdit: () => _showEditConfigDialog(
                    provider as ConfiguredEmbeddingProvider,
                  ),
                ),
            ]),
          ]),

          // Custom provider templates section
          _buildCustomProviderTemplatesSection(),
        ]),
      ]),

      // Dialogs
      if (_configuringProvider case final provider?)
        div(
          classes:
              'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
          [
            EmbeddingProviderConfigDialog(
              provider: provider,
              onClose: _hideDialogs,
            ),
          ],
        ),
      if (_showDeleteDialog) _buildDeleteDialog(),
      // if (_showCustomProviderDialog) CustomProviderDialog(),
    ]);
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
              div(classes: 'text-5xl mb-6', [FaIcon(FaIcons.solid.hammer)]),
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
    final config = configManager.embeddingProviderConfigs.getByCustomTemplate(
      template.id,
    );
    final isConfigured = config != null;

    return Card(
      className: 'border border-gray-200',
      children: [
        div(classes: 'p-4', [
          div(classes: 'flex items-center justify-between mb-3', [
            div(classes: 'flex items-center space-x-3 min-w-0 flex-1', [
              div(classes: 'text-2xl', [FaIcon(FaIcons.solid.hammer)]),
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
                [FaIcon(FaIcons.solid.settings)],
              ),
              button(
                classes:
                    'p-2 rounded-md bg-gray-100 hover:bg-gray-200 text-gray-600 transition-colors',
                events: {'click': (_) => _showEditCustomProvider(template)},
                [FaIcon(FaIcons.solid.edit)],
              ),
              button(
                classes:
                    'p-2 rounded-md bg-red-100 hover:bg-red-200 text-red-600 transition-colors',
                events: {'click': (_) => _showDeleteCustomProvider(template)},
                [FaIcon(FaIcons.solid.delete)],
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
                      events: {
                        'click': (_) {
                          print('TODO');
                          // _showEditConfigDialog(config);
                        },
                      },
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

  void _showDeleteProviderConfig(EmbeddingProviderConfig config) {
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
}
