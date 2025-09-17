import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../providers/model/embedding_provider.dart';
import '../model/embedding_job.dart';

final class CreateJobDialog extends StatefulComponent {
  CreateJobDialog({required this.onClose});

  final VoidCallback onClose;

  @override
  State<StatefulComponent> createState() => _CreateJobDialogState();
}

final class _CreateJobDialogState extends State<CreateJobDialog>
    with ConfigurationManagerListener {
  static final Logger _logger = Logger('CreateJobDialog');

  // Form state for job creation
  String? _selectedDataSourceId;
  String? _selectedTemplateId;
  final Map<String, EmbeddingModel> _selectedModels = {};
  String _jobName = '';
  String _jobDescription = '';

  @override
  void initState() {
    super.initState();
    _loadConfiguredModels().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> _loadConfiguredModels() async {
    final configuredModels = {
      for (final provider in configManager.embeddingProviders.all)
        if (provider.isConnected &&
            (provider.config?.enabledModels.isNotEmpty ?? false))
          provider.config!.id: provider.config!.enabledModels,
    };
    print('Configured models: $configuredModels');
    final availableModels = await Future.wait([
      for (final providerId in configuredModels.keys)
        configManager.embeddingProviders.getAvailableModels(providerId),
    ]);
    print('Available models: $availableModels');
    for (final model in availableModels.expand((m) => m.entries)) {
      if (configuredModels[model.value.providerId]!.contains(model.key)) {
        _selectedModels[model.key] = model.value;
      }
    }
  }

  Future<void> _createJob() async {
    if (_selectedDataSourceId == null ||
        _selectedTemplateId == null ||
        _selectedModels.isEmpty ||
        _jobName.isEmpty) {
      // Show error - all fields required
      return;
    }

    try {
      // Create the job
      final job = EmbeddingJob.create(
        id: configManager.embeddingJobs.generateId(),
        name: _jobName,
        description: _jobDescription,
        dataSourceId: _selectedDataSourceId!,
        embeddingTemplateId: _selectedTemplateId!,
        providerIds: _selectedModels.values
            .map((model) => model.providerId)
            .toSet()
            .toList(),
        modelIds: _selectedModels.keys.toList(),
      );

      // Use job orchestrator to create and queue the job
      await configManager.jobOrchestrator.createJob(job);
      component.onClose();
    } catch (e) {
      // TODO: Show error message to user
      _logger.severe('Failed to create job', e);
    }
  }

  void _onDataSourceChanged(String value) {
    setState(() {
      _selectedDataSourceId = value;
    });
  }

  void _onTemplateChanged(String value) {
    setState(() {
      _selectedTemplateId = value;
    });
  }

  void _toggleModel(EmbeddingModel model) {
    setState(() {
      if (_selectedModels.keys.contains(model.id)) {
        _selectedModels.remove(model.id);
      } else {
        _selectedModels[model.id] = model;
      }
    });
  }

  void _onJobDescriptionChanged(String value) {
    setState(() {
      _jobDescription = value;
    });
  }

  Component _buildModelSelection(Iterable<EmbeddingProvider> providers) {
    // Filter to only connected providers with enabled models
    final connectedProviders = providers.where((provider) {
      return provider.isConnected &&
          (provider.config?.enabledModels.isNotEmpty ?? false);
    }).toList();

    if (connectedProviders.isEmpty) {
      return div(classes: 'text-sm text-muted-foreground p-4 border rounded', [
        text(
          'No connected providers with enabled models. Configure providers first.',
        ),
      ]);
    }

    return div(classes: 'space-y-4', [
      for (final providerConfig in connectedProviders) ...[
        div(classes: 'border rounded-lg p-4', [
          div(classes: 'flex items-center space-x-2 mb-3', [
            if (providerConfig.iconData case final iconData?)
              FaIcon(iconData, className: 'text-primary w-4 h-4')
            else if (providerConfig.iconUri case final iconUri?)
              img(
                src: iconUri.toString(),
                alt: providerConfig.displayName,
                classes: 'h-4 w-4',
              ),
            h4(classes: 'font-medium text-sm', [
              text(providerConfig.displayName),
            ]),
          ]),
          _buildProviderModels(providerConfig),
        ]),
      ],
    ]);
  }

  Component _buildProviderModels(EmbeddingProvider provider) {
    final enabledModelIds = provider.config?.enabledModels ?? {};
    if (enabledModelIds.isEmpty) {
      return div(classes: 'text-sm text-muted-foreground', [
        text('No models enabled for this provider'),
      ]);
    }

    return FutureBuilder(
      future: configManager.embeddingProviders.getAvailableModels(
        provider.config!.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return div(
            classes:
                'text-sm text-muted-foreground flex items-center space-x-2',
            [
              div(
                classes:
                    'animate-spin rounded-full h-4 w-4 border-b-2 border-primary',
                [],
              ),
              text('Loading models...'),
            ],
          );
        }

        if (snapshot.hasError) {
          return div(classes: 'text-sm text-destructive', [
            text('Error loading models: ${snapshot.error}'),
          ]);
        }

        final allModels = snapshot.data!;
        // Filter to only enabled models
        final enabledModels = allModels.entries.where(
          (entry) => enabledModelIds.contains(entry.key),
        );

        if (enabledModels.isEmpty) {
          return div(classes: 'text-sm text-muted-foreground', [
            text('No enabled models available'),
          ]);
        }

        return div(classes: 'grid grid-cols-1 lg:grid-cols-2 gap-3', [
          for (final entry in enabledModels) ...[
            _buildModelOption(entry.key, entry.value),
          ],
        ]);
      },
    );
  }

  Component _buildModelOption(String modelId, EmbeddingModel model) {
    final isSelected = _selectedModels.containsKey(modelId);

    return Card(
      className: isSelected
          ? 'border border-green-300 bg-green-50 hover:bg-green-100 cursor-pointer transition-colors'
          : 'border border-gray-300 bg-gray-50 hover:bg-gray-100 cursor-pointer transition-colors',
      padding: 'p-3',
      children: [
        div(
          classes: 'space-y-3',
          events: {'click': (_) => _toggleModel(model)},
          [
            // Model Header
            div(classes: 'flex items-start space-x-3', [
              div(classes: 'flex-1 min-w-0', [
                Label(
                  className: 'font-medium text-sm cursor-pointer',
                  children: [text(model.id)],
                ),
              ]),
            ]),
          ],
        ),
      ],
    );
  }

  @override
  Component build(BuildContext context) {
    final dataSources = configManager.dataSourceConfigs.all;
    final templates = configManager.embeddingTemplates.all;
    final providers = configManager.embeddingProviders.all;

    return Dialog(
      onClose: component.onClose,
      maxWidth: 'max-w-2xl',
      builder: (_) => DialogContent(
        children: [
          DialogHeader(
            children: [
              div(classes: 'flex justify-between items-center', [
                DialogTitle(children: [text('Create New Embedding Job')]),
                IconButton(
                  onPressed: component.onClose,
                  icon: FaIcon(FaIcons.solid.close),
                ),
              ]),
              DialogDescription(
                children: [
                  text(
                    'Configure a new embedding job by selecting data source, template, and providers.',
                  ),
                ],
              ),
            ],
          ),

          div(classes: 'space-y-6', [
            // Job Name and Description
            div(classes: 'space-y-4', [
              div(classes: 'space-y-2', [
                Label(children: [text('Job Name *')], htmlFor: 'job-name'),
                Input(
                  id: 'job-name',
                  placeholder: 'Enter a descriptive name for this job',
                  value: _jobName,
                  onChange: (_, target) =>
                      setState(() => _jobName = target.value),
                ),
              ]),
              div(classes: 'space-y-2', [
                Label(children: [text('Description')], htmlFor: 'job-desc'),
                Textarea(
                  id: 'job-desc',
                  placeholder:
                      'Optional description of what this job will accomplish',
                  value: _jobDescription,
                  rows: 3,
                  onChange: _onJobDescriptionChanged,
                ),
              ]),
            ]),

            // Data Source Selection Section
            div([
              h3(classes: 'text-lg font-medium text-foreground mb-2', [
                text('Data Source *'),
              ]),
              p(classes: 'text-sm text-muted-foreground mb-4', [
                text(
                  'Choose the data source that contains the content you want to embed.',
                ),
              ]),
              if (dataSources.isEmpty)
                div(
                  classes: 'text-sm text-muted-foreground p-4 border rounded',
                  [
                    text('No data sources configured. '),
                    Button(
                      variant: ButtonVariant.link,
                      className: 'p-0 h-auto text-sm',
                      children: [text('Create one →')],
                    ),
                  ],
                )
              else
                Select(
                  value: _selectedDataSourceId,
                  placeholder: 'Select data source',
                  children: [
                    for (final source in dataSources)
                      Option(
                        value: source.id,
                        children: [text(source.name)],
                        selected: source.id == _selectedDataSourceId,
                      ),
                  ],
                  onChange: _onDataSourceChanged,
                ),
            ]),

            // Template Selection Section
            div([
              h3(classes: 'text-lg font-medium text-foreground mb-2', [
                text('Embedding Template *'),
              ]),
              p(classes: 'text-sm text-muted-foreground mb-4', [
                text(
                  'Select the template that defines how your data will be processed and embedded.',
                ),
              ]),
              if (templates.isEmpty)
                div(
                  classes: 'text-sm text-muted-foreground p-4 border rounded',
                  [
                    text('No templates configured. '),
                    Button(
                      variant: ButtonVariant.link,
                      className: 'p-0 h-auto text-sm',
                      children: [text('Create one →')],
                    ),
                  ],
                )
              else
                Select(
                  value: _selectedTemplateId,
                  placeholder: 'Select template',
                  children: [
                    for (final template in templates)
                      Option(
                        value: template.id,
                        children: [text(template.name)],
                        selected: template.id == _selectedTemplateId,
                      ),
                  ],
                  onChange: _onTemplateChanged,
                ),
            ]),

            // Model Selection Section
            div([
              h3(classes: 'text-lg font-medium text-foreground mb-2', [
                text('Models *'),
              ]),
              p(classes: 'text-sm text-muted-foreground mb-4', [
                text(
                  'Select the embedding models you want to use for this job. Each model can have custom dimensions.',
                ),
              ]),
              if (providers.isEmpty)
                div(
                  classes: 'text-sm text-muted-foreground p-4 border rounded',
                  [
                    text('No providers configured. '),
                    Button(
                      variant: ButtonVariant.link,
                      className: 'p-0 h-auto text-sm',
                      children: [text('Create one →')],
                    ),
                  ],
                )
              else
                _buildModelSelection(providers),
            ]),
          ]),

          DialogFooter(
            children: [
              div(classes: 'flex justify-end space-x-3 w-full', [
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: component.onClose,
                  children: [text('Cancel')],
                ),
                Button(
                  onPressed:
                      _selectedDataSourceId == null ||
                          _selectedTemplateId == null ||
                          _selectedModels.isEmpty ||
                          _jobName.isEmpty
                      ? null
                      : _createJob,
                  children: [text('Create Job')],
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
