import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../model/embedding_job.dart';

class JobsPage extends StatefulComponent {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> with ConfigurationManagerListener {
  bool _showCreateJobDialog = false;

  // Form state for job creation
  String _selectedDataSourceId = '';
  String _selectedTemplateId = '';
  List<String> _selectedProviderIds = [];
  String _jobName = '';
  String _jobDescription = '';

  void _showCreateJob() {
    // Reset form state
    _selectedDataSourceId = '';
    _selectedTemplateId = '';
    _selectedProviderIds = [];
    _jobName = '';
    _jobDescription = '';

    setState(() {
      _showCreateJobDialog = true;
    });
  }

  void _hideCreateJob() {
    setState(() {
      _showCreateJobDialog = false;
    });
  }

  void _createJob() {
    if (_selectedDataSourceId.isEmpty ||
        _selectedTemplateId.isEmpty ||
        _selectedProviderIds.isEmpty ||
        _jobName.isEmpty) {
      // Show error - all fields required
      return;
    }

    // Create the job
    final job = EmbeddingJob(
      id: configManager.embeddingJobs.generateId(),
      name: _jobName,
      description: _jobDescription,
      dataSourceId: _selectedDataSourceId,
      embeddingTemplateId: _selectedTemplateId,
      modelProviderIds: _selectedProviderIds,
      createdAt: DateTime.now(),
    );

    configManager.embeddingJobs.set(job.id, job);
    _hideCreateJob();
  }

  @override
  Component build(BuildContext context) {
    final jobs = configManager.embeddingJobs.all;
    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return div(classes: 'flex flex-col h-full', [
      // Page header
      div(classes: 'bg-white border-b px-6 py-4', [
        h1(classes: 'text-2xl font-bold text-neutral-900', [
          text('Embedding Jobs'),
        ]),
      ]),

      // Main content
      div(classes: 'flex-1 p-6', [
        // Action bar
        div(classes: 'flex justify-between items-center mb-6', [
          div(classes: 'flex space-x-4', [_buildJobStatsCard()]),
          _buildCreateJobButton(),
        ]),

        // Jobs list
        if (jobs.isEmpty) _buildEmptyState() else _buildJobsList(jobs),
      ]),

      // Create job dialog
      if (_showCreateJobDialog) _buildCreateJobDialog(),
    ]);
  }

  Component _buildJobStatsCard() {
    final stats = configManager.embeddingJobs;

    return Card(
      className: 'w-auto',
      children: [
        div(classes: 'grid grid-cols-4 gap-4 text-center', [
          div([
            div(classes: 'text-2xl font-bold text-primary-600', [
              text('${stats.length}'),
            ]),
            div(classes: 'text-sm text-muted-foreground', [text('Total Jobs')]),
          ]),
          div([
            div(classes: 'text-2xl font-bold text-green-600', [
              text('${stats.completedJobs.length}'),
            ]),
            div(classes: 'text-sm text-muted-foreground', [text('Completed')]),
          ]),
          div([
            div(classes: 'text-2xl font-bold text-yellow-600', [
              text('${stats.runningJobs.length}'),
            ]),
            div(classes: 'text-sm text-muted-foreground', [text('Running')]),
          ]),
          div([
            div(classes: 'text-2xl font-bold text-red-600', [
              text('${stats.failedJobs.length}'),
            ]),
            div(classes: 'text-sm text-muted-foreground', [text('Failed')]),
          ]),
        ]),
      ],
    );
  }

  Component _buildCreateJobButton() {
    return Button(onPressed: _showCreateJob, children: [text('+ Create Job')]);
  }

  Component _buildEmptyState() {
    return div(classes: 'text-center py-12', [
      div(classes: 'text-muted-foreground text-6xl mb-4', [text('⚡')]),
      div(classes: 'text-xl font-semibold text-foreground mb-2', [
        text('No embedding jobs yet'),
      ]),
      div(classes: 'text-muted-foreground mb-6', [
        text('Create your first job to start generating embeddings'),
      ]),
      Button(
        variant: ButtonVariant.primary,
        size: ButtonSize.lg,
        onPressed: _showCreateJob,
        children: [text('Create Your First Job')],
      ),
    ]);
  }

  Component _buildJobsList(List<EmbeddingJob> jobs) {
    return div(classes: 'space-y-4', [
      for (final job in jobs) _buildJobCard(job),
    ]);
  }

  Component _buildJobCard(EmbeddingJob job) {
    return Card(
      className: 'hover:shadow-md transition-shadow',
      children: [
        // Header
        div(classes: 'flex justify-between items-start mb-4', [
          div(classes: 'flex-1', [
            div(classes: 'flex items-center space-x-3 mb-2', [
              h3(classes: 'text-lg font-semibold text-foreground', [
                text(job.name),
              ]),
              _buildStatusBadge(job.status),
            ]),
            if (job.description.isNotEmpty)
              p(classes: 'text-muted-foreground text-sm', [
                text(job.description),
              ]),
          ]),
          div(classes: 'flex space-x-2', [
            if (job.canCancel) _buildCancelButton(job),
            _buildJobMenuButton(job),
          ]),
        ]),

        // Progress bar (for running jobs)
        if (job.status == JobStatus.running) _buildProgressBar(job),

        // Job details
        div(classes: 'grid grid-cols-2 md:grid-cols-4 gap-4 text-sm', [
          _buildJobDetail('Data Source', _getDataSourceName(job.dataSourceId)),
          _buildJobDetail(
            'Template',
            _getTemplateName(job.embeddingTemplateId),
          ),
          _buildJobDetail(
            'Providers',
            '${job.modelProviderIds.length} provider(s)',
          ),
          _buildJobDetail('Created', _formatDate(job.createdAt)),
        ]),

        // Additional info for completed/failed jobs
        if (job.status == JobStatus.completed) ...[
          div(classes: 'mt-4 pt-4 border-t', [
            div(classes: 'flex justify-between items-center', [
              div(classes: 'text-sm text-muted-foreground', [
                text(
                  'Completed in ${_formatDuration(job.duration!)} • ${job.processedRecords}/${job.totalRecords} records',
                ),
              ]),
              Button(
                variant: ButtonVariant.link,
                children: [text('View Results →')],
              ),
            ]),
          ]),
        ] else if (job.status == JobStatus.failed) ...[
          div(classes: 'mt-4 pt-4 border-t', [
            div(classes: 'text-sm text-destructive', [
              text('Error: ${job.errorMessage ?? "Unknown error"}'),
            ]),
          ]),
        ],
      ],
    );
  }

  Component _buildStatusBadge(JobStatus status) {
    BadgeVariant variant;
    switch (status) {
      case JobStatus.completed:
        variant = BadgeVariant.primary;
      case JobStatus.running:
        variant = BadgeVariant.secondary;
      case JobStatus.failed:
        variant = BadgeVariant.destructive;
      default:
        variant = BadgeVariant.outline;
    }

    return Badge(variant: variant, children: [text(status.displayName)]);
  }

  Component _buildProgressBar(EmbeddingJob job) {
    final progress = job.progress;

    return div(classes: 'mb-4', [
      div(classes: 'flex justify-between text-sm text-neutral-600 mb-1', [
        text('Processing embeddings...'),
        text('${progress.toStringAsFixed(1)}%'),
      ]),
      div(classes: 'w-full bg-neutral-200 rounded-full h-2', [
        div(
          classes:
              'bg-primary-600 h-2 rounded-full transition-all duration-300',
          attributes: {'style': 'width: $progress%'},
          [],
        ),
      ]),
    ]);
  }

  Component _buildCancelButton(EmbeddingJob job) {
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      onPressed: () => _cancelJob(job.id),
      children: [text('Cancel')],
      className: 'text-destructive hover:text-destructive',
    );
  }

  Component _buildJobMenuButton(EmbeddingJob job) {
    return IconButton(
      icon: FaIcons.solid.menu,
      variant: ButtonVariant.ghost,
      className: 'text-muted-foreground',
    );
  }

  Component _buildJobDetail(String label, String value) {
    return div([
      div(classes: 'text-muted-foreground text-xs uppercase tracking-wide', [
        text(label),
      ]),
      div(classes: 'text-foreground font-medium', [text(value)]),
    ]);
  }

  Component _buildCreateJobDialog() {
    final dataSources = configManager.dataSources.all;
    final templates = configManager.embeddingTemplates.all;
    final providers = configManager.modelProviders.all;

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
                  CardTitle(children: [text('Create New Embedding Job')]),
                  IconButton(
                    icon: FaIcons.solid.close,
                    onPressed: _hideCreateJob,
                    className: 'text-muted-foreground',
                  ),
                ]),
                CardDescription(
                  children: [
                    text(
                      'Configure a new embedding job by selecting data source, template, and model providers.',
                    ),
                  ],
                ),
              ],
            ),

            CardContent(
              children: [
                div(classes: 'space-y-6', [
                  // Job Name and Description
                  div(classes: 'space-y-4', [
                    div(classes: 'space-y-2', [
                      Label(
                        children: [text('Job Name *')],
                        htmlFor: 'job-name',
                      ),
                      Input(
                        id: 'job-name',
                        placeholder: 'Enter a descriptive name for this job',
                        value: _jobName,
                      ),
                    ]),
                    div(classes: 'space-y-2', [
                      Label(
                        children: [text('Description')],
                        htmlFor: 'job-desc',
                      ),
                      Textarea(
                        id: 'job-desc',
                        placeholder:
                            'Optional description of what this job will accomplish',
                        value: _jobDescription,
                        rows: 3,
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
                          classes:
                              'text-sm text-muted-foreground p-2 border rounded',
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
                              ),
                          ],
                        ),
                    ]),

                    // Template Selection
                    div(classes: 'space-y-2', [
                      Label(children: [text('Embedding Template *')]),
                      if (templates.isEmpty)
                        div(
                          classes:
                              'text-sm text-muted-foreground p-2 border rounded',
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
                              ),
                          ],
                        ),
                    ]),

                    // Provider Selection
                    div(classes: 'space-y-2', [
                      Label(children: [text('Model Providers *')]),
                      if (providers.isEmpty)
                        div(
                          classes:
                              'text-sm text-muted-foreground p-2 border rounded',
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
                                  if (_selectedProviderIds.contains(
                                    provider.id,
                                  ))
                                    'checked': 'true',
                                },
                                classes: 'rounded',
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
                  if (_selectedDataSourceId.isNotEmpty ||
                      _selectedTemplateId.isNotEmpty ||
                      _selectedProviderIds.isNotEmpty)
                    div(classes: 'bg-muted p-4 rounded border', [
                      div(classes: 'text-sm font-medium mb-2', [
                        text('Job Summary:'),
                      ]),
                      div(classes: 'text-sm text-muted-foreground space-y-1', [
                        if (_selectedDataSourceId.isNotEmpty)
                          text(
                            '• Data: ${_getDataSourceName(_selectedDataSourceId)}',
                          ),
                        if (_selectedTemplateId.isNotEmpty)
                          text(
                            '• Template: ${_getTemplateName(_selectedTemplateId)}',
                          ),
                        if (_selectedProviderIds.isNotEmpty)
                          text(
                            '• Providers: ${_selectedProviderIds.length} selected',
                          ),
                      ]),
                    ]),
                ]),
              ],
            ),

            CardFooter(
              children: [
                div(classes: 'flex justify-end space-x-3 w-full', [
                  Button(
                    variant: ButtonVariant.outline,
                    onPressed: _hideCreateJob,
                    children: [text('Cancel')],
                  ),
                  Button(
                    onPressed: _createJob,
                    disabled:
                        _selectedDataSourceId.isEmpty ||
                        _selectedTemplateId.isEmpty ||
                        _selectedProviderIds.isEmpty ||
                        _jobName.isEmpty,
                    children: [text('Create Job')],
                  ),
                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _cancelJob(String jobId) {
    configManager.embeddingJobs.cancelJob(jobId);
  }

  String _getDataSourceName(String id) {
    final source = configManager.dataSources.getById(id);
    return source?.name ?? 'Unknown';
  }

  String _getTemplateName(String id) {
    final template = configManager.embeddingTemplates.getById(id);
    return template?.name ?? 'Unknown';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) return '${duration.inSeconds}s';
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }
}
