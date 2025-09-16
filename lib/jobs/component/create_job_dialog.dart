import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../model/embedding_job.dart';

final class CreateJobDialog extends StatefulComponent {
  CreateJobDialog({required this.onClose});

  final VoidCallback onClose;

  @override
  State<StatefulComponent> createState() => _CreateJobDialogState();
}

final class _CreateJobDialogState extends State<CreateJobDialog>
    with ConfigurationManagerListener {
  // Form state for job creation
  String? _selectedDataSourceId;
  String? _selectedTemplateId;
  final Set<String> _selectedProviderIds = {};
  String _jobName = '';
  String _jobDescription = '';

  void _createJob() {
    if (_selectedDataSourceId == null ||
        _selectedTemplateId == null ||
        _selectedProviderIds.isEmpty ||
        _jobName.isEmpty) {
      // Show error - all fields required
      return;
    }

    // Create the job
    final job = EmbeddingJob.create(
      id: configManager.embeddingJobs.generateId(),
      name: _jobName,
      description: _jobDescription,
      dataSourceId: _selectedDataSourceId!,
      embeddingTemplateId: _selectedTemplateId!,
      providerIds: _selectedProviderIds.toList(),
    );

    configManager.embeddingJobs.upsert(job);
    component.onClose();
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

  void _toggleProvider(String providerId) {
    setState(() {
      if (_selectedProviderIds.contains(providerId)) {
        _selectedProviderIds.remove(providerId);
      } else {
        _selectedProviderIds.add(providerId);
      }
    });
  }

  void _onJobDescriptionChanged(String value) {
    setState(() {
      _jobDescription = value;
    });
  }

  String _getDataSourceName(String id) {
    final source = configManager.dataSourceConfigs.getById(id);
    return source?.name ?? 'Unknown';
  }

  String _getTemplateName(String id) {
    final template = configManager.embeddingTemplates.getById(id);
    return template?.name ?? 'Unknown';
  }

  @override
  Component build(BuildContext context) {
    final dataSources = configManager.dataSourceConfigs.all;
    final templates = configManager.embeddingTemplates.all;
    final providers = configManager.embeddingProviderConfigs.all;

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

            // Configuration Selection
            div(classes: 'grid grid-cols-1 md:grid-cols-3 gap-4', [
              // Data Source Selection
              div(classes: 'space-y-2', [
                Label(children: [text('Data Source *')]),
                if (dataSources.isEmpty)
                  div(
                    classes: 'text-sm text-muted-foreground p-2 border rounded',
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

              // Template Selection
              div(classes: 'space-y-2', [
                Label(children: [text('Embedding Template *')]),
                if (templates.isEmpty)
                  div(
                    classes: 'text-sm text-muted-foreground p-2 border rounded',
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

              // Provider Selection
              div(classes: 'space-y-2', [
                Label(children: [text('Providers *')]),
                if (providers.isEmpty)
                  div(
                    classes: 'text-sm text-muted-foreground p-2 border rounded',
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
                  div(classes: 'space-y-2', [
                    for (final provider in providers)
                      div(classes: 'flex items-center space-x-2', [
                        input(
                          attributes: {
                            'type': 'checkbox',
                            'id': 'provider-${provider.id}',
                            'value': provider.id,
                            if (_selectedProviderIds.contains(provider.id))
                              'checked': 'true',
                          },
                          classes: 'rounded',
                          events: {
                            'change': (event) => _toggleProvider(provider.id),
                          },
                        ),
                        Label(
                          htmlFor: 'provider-${provider.id}',
                          children: [text(provider.name)],
                          className: 'text-sm',
                        ),
                      ]),
                  ]),
              ]),
            ]),

            // Summary
            if (_selectedDataSourceId != null ||
                _selectedTemplateId != null ||
                _selectedProviderIds.isNotEmpty)
              div(classes: 'bg-muted p-4 rounded border', [
                div(classes: 'text-sm font-medium mb-2', [
                  text('Job Summary:'),
                ]),
                div(classes: 'text-sm text-muted-foreground space-y-1', [
                  if (_selectedDataSourceId != null)
                    p([
                      text(
                        '• Data: ${_getDataSourceName(_selectedDataSourceId!)}',
                      ),
                    ]),
                  if (_selectedTemplateId != null)
                    p([
                      text(
                        '• Template: ${_getTemplateName(_selectedTemplateId!)}',
                      ),
                    ]),
                  if (_selectedProviderIds.isNotEmpty)
                    p([
                      text(
                        '• Providers: ${_selectedProviderIds.length} selected',
                      ),
                    ]),
                ]),
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
                          _selectedProviderIds.isEmpty ||
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
