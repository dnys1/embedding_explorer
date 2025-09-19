import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../component/create_job_dialog.dart';
import '../model/embedding_job.dart';
import '../service/job_resume_service.dart';

class JobsPage extends StatefulComponent {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> with ConfigurationManagerListener {
  static final Logger _logger = Logger('JobsPage');

  bool _showCreateJobDialog = false;
  StreamSubscription<EmbeddingJob>? _jobUpdatesSubscription;
  List<ResumableJob> _resumableJobs = [];
  bool _showResumableJobsSection = false;

  @override
  void initState() {
    super.initState();
    _subscribeToJobUpdates();
    _checkForResumableJobs();
    _setupPageUnloadHandler();
  }

  @override
  void dispose() {
    _jobUpdatesSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToJobUpdates() {
    // Subscribe to job updates from the orchestrator for real-time progress
    _jobUpdatesSubscription = configManager.jobOrchestrator.jobUpdates.listen(
      (job) => setState(() {}),
    );
  }

  void _checkForResumableJobs() async {
    try {
      final resumableJobs = await configManager.jobOrchestrator
          .findResumableJobs();
      if (resumableJobs.isNotEmpty) {
        setState(() {
          _resumableJobs = resumableJobs;
          _showResumableJobsSection = true;
        });
      }
    } catch (e) {
      _logger.warning('Error checking for resumable jobs: $e');
    }
  }

  void _setupPageUnloadHandler() {
    // TODO: https://www.igvita.com/2015/11/20/dont-lose-user-and-app-state-use-page-visibility/
    // TODO: https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
    web.EventStreamProviders.beforeUnloadEvent
        .forTarget(web.window)
        .first
        .then((_) => configManager.handlePageUnload());
  }

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

        // Resumable jobs section
        if (_showResumableJobsSection) _buildResumableJobsSection(),

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

  Component _buildResumableJobsSection() {
    final interruptedJobs = _resumableJobs
        .where((it) => it.job.status == JobStatus.paused)
        .toList(growable: false);
    if (interruptedJobs.isEmpty) {
      return fragment([]);
    }

    return Card(
      className: 'mb-6 border-orange-200 bg-orange-50',
      children: [
        div(classes: 'flex items-start space-x-3', [
          div(classes: 'text-orange-500 mt-1', [FaIcon(FaIcons.solid.warning)]),
          div(classes: 'flex-1', [
            h3(classes: 'text-lg font-medium text-orange-900 mb-2', [
              text('Interrupted Jobs Detected'),
            ]),
            p(classes: 'text-orange-800 text-sm mb-4', [
              text(
                'The following jobs were interrupted (likely due to a page reload). You can restart them to continue processing.',
              ),
            ]),
            div(classes: 'space-y-2', [
              for (final resumableJob in interruptedJobs)
                _buildResumableJobItem(resumableJob),
            ]),
            div(classes: 'mt-4 flex space-x-3', [
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: _resumeAllJobs,
                children: [text('Resume All')],
              ),
              Button(
                variant: ButtonVariant.ghost,
                size: ButtonSize.sm,
                onPressed: _dismissResumableJobs,
                children: [text('Dismiss')],
              ),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildResumableJobItem(ResumableJob resumableJob) {
    final progressPercentage = (resumableJob.progressAtInterruption * 100)
        .toStringAsFixed(1);

    return div(
      classes: 'flex items-center justify-between p-3 bg-white rounded border',
      [
        div(classes: 'flex-1', [
          div(classes: 'font-medium text-sm', [text(resumableJob.job.name)]),
          div(classes: 'text-xs text-muted-foreground', [
            text(
              '$progressPercentage% progress saved • ${resumableJob.recommendedStrategy.name} checkpoint',
            ),
          ]),
        ]),
        Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          onPressed: () => _resumeJob(resumableJob.job.id),
          children: [text('Resume')],
        ),
      ],
    );
  }

  Component _buildEmptyState() {
    return div(classes: 'text-center py-12', [
      div(classes: 'text-muted-foreground mb-4', [
        FaIcon(FaIcons.solid.bolt, size: 64),
      ]),
      div(classes: 'text-xl font-semibold text-foreground mb-2', [
        text('No embedding jobs yet'),
      ]),
      div(classes: 'text-muted-foreground mb-6', [
        text('Create your first job to start generating embeddings.'),
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
            if (_resumableJobs.map((it) => it.job.id).contains(job.id))
              _buildResumeButton(job),
            if (job.canCancel) _buildCancelButton(job),
            if (job.isCompleted) _buildViewButton(job),
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
          _buildJobDetail('Models', '${job.modelIds.length} model(s)'),
          _buildJobDetail('Created', _formatDate(job.createdAt)),
        ]),

        // Additional info for completed/failed jobs
        if (job.status == JobStatus.completed) ...[
          div(classes: 'mt-4 pt-4 border-t', [
            div(classes: 'text-sm text-muted-foreground', [
              if (job.duration case final duration?)
                text('Completed in ${_formatDuration(duration)} • '),
              text('${job.processedRecords}/${job.totalRecords} records'),
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
      JobStatus.paused => BadgeVariant.outline,
      JobStatus.failed => BadgeVariant.destructive,
      JobStatus.cancelled => BadgeVariant.warning,
    };

    return Badge(variant: variant, children: [text(status.displayName)]);
  }

  Component _buildProgressBar(EmbeddingJob job) {
    final progress = job.progress;

    return div(classes: 'mb-4', [
      div(classes: 'flex justify-between text-sm text-neutral-600 mb-1', [
        span([text('Processing embeddings...')]),
        span([text('${progress.toStringAsFixed(1)}%')]),
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

  Component _buildResumeButton(EmbeddingJob job) {
    final label = switch (job.status) {
      JobStatus.failed => 'Retry',
      JobStatus.cancelled => 'Restart',
      JobStatus.paused => 'Resume',
      JobStatus.running || JobStatus.completed => null,
    };
    if (label == null) {
      return fragment([]);
    }
    return Button(
      variant: ButtonVariant.outline,
      size: ButtonSize.sm,
      onPressed: () => _resumeJob(job.id),
      children: [text(label)],
    );
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

  Component _buildViewButton(EmbeddingJob job) {
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      onPressed: () => _viewJobResults(job),
      children: [text('View Results')],
    );
  }

  Component _buildJobMenuButton(EmbeddingJob job) {
    return Dropdown(
      trigger: div(
        classes:
            'p-3 rounded-md hover:bg-muted transition-colors cursor-pointer flex items-center justify-center',
        [FaIcon(FaIcons.solid.ellipsisVertical)],
      ),
      alignment: DropdownAlignment.end,
      children: [
        // View Results - available for completed and failed jobs
        DropdownItem(
          onPressed: () => _viewJobResults(job),
          disabled: !job.isCompleted,
          children: [
            div(classes: 'flex items-center space-x-2', [
              FaIcon(FaIcons.solid.eye),
              // By default, text is a bare string, so wrap it in a span for styling
              span([text('View Results')]),
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
                span([text('Restart Job')]),
              ]),
            ],
          ),

        // Cancel Job - available for running jobs
        if (configManager.jobOrchestrator.canCancelJob(job.id))
          DropdownItem(
            onPressed: () => _cancelJob(job.id),
            destructive: true,
            children: [
              div(classes: 'flex items-center space-x-2', [
                FaIcon(FaIcons.solid.stop),
                span([text('Cancel Job')]),
              ]),
            ],
          ),

        // Delete Job - available for completed, failed, and cancelled jobs
        if (job.isCompleted) ...[
          const DropdownSeparator(margin: ''),
          DropdownItem(
            onPressed: () => _deleteJob(job),
            destructive: true,
            children: [
              div(classes: 'flex items-center space-x-2', [
                FaIcon(FaIcons.solid.delete),
                span([text('Delete Job')]),
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

  void _cancelJob(String jobId) async {
    try {
      await configManager.jobOrchestrator.cancelJob(jobId);
    } catch (e) {
      _logger.severe('Failed to cancel job: $jobId', e);
      // TODO: Show error message to user
    }
  }

  String _getDataSourceName(String id) {
    final source = configManager.dataSourceConfigs.getById(id);
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
    // Navigate to job results page
    Router.of(context).push('/jobs/${job.id}');
  }

  void _restartJob(EmbeddingJob job) async {
    try {
      if (_resumableJobs.map((it) => it.job.id).contains(job.id)) {
        await configManager.jobOrchestrator.resumeJob(job.id);
      } else {
        await configManager.jobOrchestrator.retryJob(job.id);
      }
    } catch (e) {
      _logger.severe('Failed to restart job: ${job.id}', e);
      // TODO: Show error message to user
    }
  }

  void _resumeJob(String jobId) async {
    try {
      await configManager.jobOrchestrator.resumeJob(jobId);

      // Remove from resumable jobs list and update UI
      setState(() {
        _resumableJobs.removeWhere((r) => r.job.id == jobId);
        if (_resumableJobs.isEmpty) {
          _showResumableJobsSection = false;
        }
      });
    } catch (e) {
      _logger.severe('Failed to resume job: $jobId', e);
      // TODO: Show error message to user
    }
  }

  void _resumeAllJobs() async {
    for (final resumableJob in _resumableJobs) {
      try {
        await configManager.jobOrchestrator.resumeJob(resumableJob.job.id);
      } catch (e) {
        _logger.severe('Failed to resume job: ${resumableJob.job.id}', e);
      }
    }

    setState(() {
      _resumableJobs.clear();
      _showResumableJobsSection = false;
    });
  }

  void _dismissResumableJobs() {
    setState(() {
      _resumableJobs.clear();
      _showResumableJobsSection = false;
    });
  }

  void _deleteJob(EmbeddingJob job) async {
    try {
      await configManager.jobOrchestrator.deleteJob(job.id);
    } catch (e) {
      _logger.severe('Failed to delete job: ${job.id}', e);
      // TODO: Show error message to user
    }
  }
}
