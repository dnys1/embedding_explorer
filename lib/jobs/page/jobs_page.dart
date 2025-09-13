import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../component/create_job_dialog.dart';
import '../model/embedding_job.dart';

class JobsPage extends StatefulComponent {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> with ConfigurationManagerListener {
  bool _showCreateJobDialog = false;

  void _showCreateJob() {
    setState(() {
      _showCreateJobDialog = true;
    });
  }

  void _hideCreateJob() {
    setState(() {
      _showCreateJobDialog = false;
    });
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
      if (_showCreateJobDialog) CreateJobDialog(onClose: _hideCreateJob),
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
    final variant = switch (status) {
      JobStatus.completed => BadgeVariant.primary,
      JobStatus.running => BadgeVariant.secondary,
      JobStatus.pending => BadgeVariant.outline,
      JobStatus.failed => BadgeVariant.destructive,
      JobStatus.cancelled => BadgeVariant.warning,
    };

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
    return Dropdown(
      trigger: div(
        classes:
            'p-2 rounded-md hover:bg-muted transition-colors cursor-pointer',
        [FaIcon(FaIcons.solid.ellipsisVertical)],
      ),
      alignment: DropdownAlignment.end,
      children: [
        // View Results - available for completed and failed jobs
        if (job.status == JobStatus.completed || job.status == JobStatus.failed)
          DropdownItem(
            onPressed: () => _viewJobResults(job),
            children: [
              div(classes: 'flex items-center space-x-2', [
                FaIcon(FaIcons.solid.eye),
                text('View Results'),
              ]),
            ],
          ),

        // Restart Job - available for failed and cancelled jobs
        if (job.status == JobStatus.failed || job.status == JobStatus.cancelled)
          DropdownItem(
            onPressed: () => _restartJob(job),
            children: [
              div(classes: 'flex items-center space-x-2', [
                FaIcon(FaIcons.solid.refresh),
                text('Restart Job'),
              ]),
            ],
          ),

        // Cancel Job - available for running jobs
        if (job.status == JobStatus.running)
          DropdownItem(
            onPressed: () => _cancelJob(job.id),
            destructive: true,
            children: [
              div(classes: 'flex items-center space-x-2', [
                FaIcon(FaIcons.solid.stop),
                text('Cancel Job'),
              ]),
            ],
          ),

        // Duplicate Job - available for all jobs
        const DropdownSeparator(),
        DropdownItem(
          onPressed: () => _duplicateJob(job),
          children: [
            div(classes: 'flex items-center space-x-2', [
              FaIcon(FaIcons.solid.duplicate),
              text('Duplicate Job'),
            ]),
          ],
        ),

        // Delete Job - available for completed, failed, and cancelled jobs
        if (job.status == JobStatus.completed ||
            job.status == JobStatus.failed ||
            job.status == JobStatus.cancelled) ...[
          const DropdownSeparator(),
          DropdownItem(
            onPressed: () => _deleteJob(job),
            destructive: true,
            children: [
              div(classes: 'flex items-center space-x-2', [
                FaIcon(FaIcons.solid.delete),
                text('Delete Job'),
              ]),
            ],
          ),
        ],
      ],
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

  void _viewJobResults(EmbeddingJob job) {
    // TODO: Navigate to job results page or show results modal
    print('Viewing results for job: ${job.name}');
  }

  void _restartJob(EmbeddingJob job) {
    // TODO: Restart the job by creating a new job with same configuration
    print('Restarting job: ${job.name}');
  }

  void _duplicateJob(EmbeddingJob job) {
    // TODO: Create a new job with same configuration but new ID
    print('Duplicating job: ${job.name}');
  }

  void _deleteJob(EmbeddingJob job) {
    configManager.embeddingJobs.remove(job.id);
  }
}
