import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../configurations/model/vector_search_result.dart';
import '../../embeddings/service/embedding_query_service.dart';
import '../model/embedding_job.dart';

class JobResultsPage extends StatefulComponent {
  const JobResultsPage({super.key, required this.jobId});

  final String jobId;

  @override
  State<JobResultsPage> createState() => _JobResultsPageState();
}

class _JobResultsPageState extends State<JobResultsPage>
    with ConfigurationManagerListener {
  static final Logger _logger = Logger('JobResultsPage');

  EmbeddingJob? _job;
  bool _isLoading = true;
  String? _errorMessage;
  String _queryText = '';
  bool _isQuerying = false;
  JobQueryResult? _queryResult;
  String? _queryError;

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final job = configManager.embeddingJobs.getById(component.jobId);
      if (job == null) {
        setState(() {
          _errorMessage = 'Job not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _job = job;
        _isLoading = false;
      });
    } catch (e) {
      _logger.severe('Failed to load job: ${component.jobId}', e);
      setState(() {
        _errorMessage = 'Failed to load job: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Component build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    if (_job == null) {
      return _buildErrorState('Job not found');
    }

    return div(classes: 'flex flex-col h-full', [
      // Page header
      _buildHeader(),

      // Main content
      div(classes: 'flex-1 p-6 overflow-y-auto', [
        div(classes: 'max-w-6xl mx-auto space-y-6', [
          // Job overview card
          _buildJobOverviewCard(),

          // Statistics card
          _buildStatisticsCard(),

          // Error information (if failed)
          if (_job!.status == JobStatus.failed) _buildErrorCard(),

          // Embedding query section
          _buildEmbeddingQuerySection(),
        ]),
      ]),
    ]);
  }

  Component _buildLoadingState() {
    return div(classes: 'flex flex-col h-full', [
      div(classes: 'bg-white border-b px-6 py-4', [
        h1(classes: 'text-2xl font-bold text-neutral-900', [
          text('Loading Job Results...'),
        ]),
      ]),
      div(classes: 'flex-1 flex items-center justify-center', [
        div(classes: 'text-center', [
          div(
            classes:
                'animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4',
            [],
          ),
          div(classes: 'text-muted-foreground', [
            text('Loading job details...'),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildErrorState(String error) {
    return div(classes: 'flex flex-col h-full', [
      div(classes: 'bg-white border-b px-6 py-4', [
        h1(classes: 'text-2xl font-bold text-neutral-900', [
          text('Job Results'),
        ]),
      ]),
      div(classes: 'flex-1 flex items-center justify-center', [
        div(classes: 'text-center', [
          div(classes: 'text-destructive text-6xl mb-4', [text('⚠️')]),
          div(classes: 'text-xl font-semibold text-foreground mb-2', [
            text('Error Loading Job'),
          ]),
          div(classes: 'text-muted-foreground mb-6', [text(error)]),
          Button(
            variant: ButtonVariant.outline,
            onPressed: () => _loadJob(),
            children: [text('Retry')],
          ),
        ]),
      ]),
    ]);
  }

  Component _buildHeader() {
    return div(classes: 'bg-white border-b px-6 py-4', [
      div(classes: 'flex items-center space-x-4', [
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.sm,
          onPressed: () {
            Router.of(context).push('/jobs');
          },
          children: [
            div(classes: 'flex items-center space-x-2', [
              FaIcon(FaIcons.solid.arrowLeft),
              text('Back to Jobs'),
            ]),
          ],
        ),
        div(classes: 'flex-1', [
          h1(classes: 'text-2xl font-bold text-neutral-900', [
            text('Job Results: ${_job!.name}'),
          ]),
          div(classes: 'flex items-center space-x-2 mt-1', [
            _buildStatusBadge(_job!.status),
            div(classes: 'text-sm text-muted-foreground', [
              text('Created ${_formatDate(_job!.createdAt)}'),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildJobOverviewCard() {
    return Card(
      children: [
        div(classes: 'flex items-start justify-between mb-4', [
          div(classes: 'flex-1', [
            h2(classes: 'text-lg font-semibold text-foreground mb-2', [
              text('Job Overview'),
            ]),
            if (_job!.description.isNotEmpty)
              p(classes: 'text-muted-foreground text-sm mb-4', [
                text(_job!.description),
              ]),
          ]),
          div(classes: 'flex space-x-2', [
            if (_job!.status == JobStatus.failed ||
                _job!.status == JobStatus.cancelled)
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () => _restartJob(),
                children: [
                  div(classes: 'flex items-center space-x-2', [
                    FaIcon(FaIcons.solid.refresh),
                    span([text('Restart Job')]),
                  ]),
                ],
              ),
          ]),
        ]),

        div(classes: 'grid grid-cols-2 md:grid-cols-4 gap-4', [
          _buildDetailItem(
            'Data Source',
            _getDataSourceName(_job!.dataSourceId),
          ),
          _buildDetailItem(
            'Template',
            _getTemplateName(_job!.embeddingTemplateId),
          ),
          _buildDetailItem('Models', '${_job!.modelIds.length} model(s)'),
          _buildDetailItem(
            'Duration',
            _job!.duration != null ? _formatDuration(_job!.duration!) : 'N/A',
          ),
        ]),
      ],
    );
  }

  Component _buildStatisticsCard() {
    final job = _job!;
    final totalRecords = job.totalRecords ?? 0;
    final processedRecords = job.processedRecords ?? 0;
    final successRate = totalRecords > 0
        ? (processedRecords / totalRecords * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      children: [
        h2(classes: 'text-lg font-semibold text-foreground mb-4', [
          text('Processing Statistics'),
        ]),

        div(classes: 'grid grid-cols-2 md:grid-cols-4 gap-6', [
          _buildStatItem(
            'Total Records',
            '$totalRecords',
            FaIcons.solid.database,
            'text-blue-600',
          ),
          _buildStatItem(
            'Processed',
            '$processedRecords',
            FaIcons.solid.check,
            'text-green-600',
          ),
          _buildStatItem(
            'Failed',
            '${totalRecords - processedRecords}',
            FaIcons.solid.warning,
            'text-red-600',
          ),
          _buildStatItem(
            'Success Rate',
            '$successRate%',
            FaIcons.solid.chartBar,
            'text-purple-600',
          ),
        ]),

        // Progress bar
        if (totalRecords > 0) ...[
          div(classes: 'mt-6', [
            div(
              classes:
                  'flex justify-between text-sm text-muted-foreground mb-2',
              [
                span([text('Processing Progress')]),
                span([
                  text('${job.processedRecords}/${job.totalRecords} records'),
                ]),
              ],
            ),
            div(classes: 'w-full bg-neutral-200 rounded-full h-2', [
              div(
                classes:
                    'h-2 rounded-full transition-all duration-300 ${job.status == JobStatus.completed
                        ? 'bg-green-600'
                        : job.status == JobStatus.failed
                        ? 'bg-red-600'
                        : 'bg-primary-600'}',
                attributes: {'style': 'width: ${job.progress}%'},
                [],
              ),
            ]),
          ]),
        ],
      ],
    );
  }

  Component _buildErrorCard() {
    return Card(
      className: 'border-red-200 bg-red-50',
      children: [
        div(classes: 'flex items-start space-x-3', [
          div(classes: 'text-red-500 mt-1', [FaIcon(FaIcons.solid.warning)]),
          div(classes: 'flex-1', [
            h3(classes: 'text-lg font-medium text-red-900 mb-2', [
              text('Job Failed'),
            ]),
            if (_job!.errorMessage?.isNotEmpty == true) ...[
              p(classes: 'text-red-800 text-sm mb-4', [
                text('The job encountered an error during processing:'),
              ]),
              div(classes: 'bg-white rounded border border-red-200 p-3', [
                code(classes: 'text-sm text-red-900 font-mono', [
                  text(_job!.errorMessage!),
                ]),
              ]),
            ] else ...[
              p(classes: 'text-red-800 text-sm', [
                text(
                  'The job failed but no specific error message was recorded.',
                ),
              ]),
            ],
          ]),
        ]),
      ],
    );
  }

  Component _buildEmbeddingQuerySection() {
    final canQuery = _job?.status == JobStatus.completed;

    return Card(
      children: [
        div(classes: 'flex items-center justify-between mb-4', [
          h2(classes: 'text-lg font-semibold text-foreground', [
            text('Query Embeddings'),
          ]),
          if (!canQuery)
            Badge(
              variant: BadgeVariant.secondary,
              children: [text('Available for completed jobs')],
            ),
        ]),

        p(classes: 'text-muted-foreground text-sm mb-6', [
          text(
            'Search through the generated embeddings to find similar records based on semantic similarity.',
          ),
        ]),

        div(classes: 'space-y-4', [
          // Query input
          div(classes: 'flex space-x-3', [
            div(classes: 'flex-1', [
              input(
                classes:
                    'w-full px-3 py-2 border border-neutral-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent disabled:bg-neutral-100 disabled:cursor-not-allowed',
                attributes: {
                  'type': 'text',
                  'placeholder': canQuery
                      ? 'Enter your search query...'
                      : 'Complete the job to enable search',
                  'value': _queryText,
                  if (!canQuery) 'disabled': 'true',
                },
                events: {
                  if (canQuery)
                    'input': (event) {
                      final target = event.target as web.HTMLInputElement?;
                      if (target != null) {
                        setState(() {
                          _queryText = target.value;
                        });
                      }
                    },
                },
              ),
            ]),
            Button(
              variant: ButtonVariant.primary,
              disabled: !canQuery || _isQuerying || _queryText.trim().isEmpty,
              onPressed: _isQuerying ? null : () => _executeQuery(),
              children: [
                if (_isQuerying) ...[
                  div(
                    classes:
                        'animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2',
                    [],
                  ),
                  text('Searching...'),
                ] else ...[
                  FaIcon(FaIcons.solid.search),
                  text('Search'),
                ],
              ],
            ),
          ]),

          // Query error
          if (_queryError != null)
            div(classes: 'p-3 bg-red-50 border border-red-200 rounded-md', [
              div(classes: 'flex items-start space-x-2', [
                div(classes: 'text-red-500 mt-0.5', [
                  FaIcon(FaIcons.solid.warning),
                ]),
                div(classes: 'flex-1', [
                  div(classes: 'text-sm font-medium text-red-900 mb-1', [
                    text('Search Failed'),
                  ]),
                  div(classes: 'text-sm text-red-800', [text(_queryError!)]),
                ]),
              ]),
            ]),

          // Query results
          if (_queryResult != null)
            _buildQueryResults()
          else
            _buildQueryPlaceholder(),
        ]),
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

  Component _buildDetailItem(String label, String value) {
    return div([
      div(
        classes: 'text-muted-foreground text-xs uppercase tracking-wide mb-1',
        [text(label)],
      ),
      div(classes: 'text-foreground font-medium', [text(value)]),
    ]);
  }

  Component _buildStatItem(
    String label,
    String value,
    FaIconData icon,
    String colorClass,
  ) {
    return div(classes: 'text-center', [
      div(classes: 'flex items-center justify-center mb-2', [
        div(classes: '$colorClass text-2xl', [FaIcon(icon)]),
      ]),
      div(classes: 'text-2xl font-bold text-foreground mb-1', [text(value)]),
      div(classes: 'text-xs text-muted-foreground uppercase tracking-wide', [
        text(label),
      ]),
    ]);
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

    if (diff.inMinutes < 1) return 'just now';
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

  void _restartJob() async {
    try {
      await configManager.jobOrchestrator.retryJob(_job!.id);
      // TODO: Navigate back to jobs page or show success message
      _logger.info('Job restart initiated for: ${_job!.id}');
    } catch (e) {
      _logger.severe('Failed to restart job: ${_job!.id}', e);
      // TODO: Show error message to user
    }
  }

  Component _buildQueryPlaceholder() {
    return div(
      classes:
          'border-2 border-dashed border-neutral-200 rounded-lg p-8 text-center',
      [
        div(classes: 'text-muted-foreground text-4xl mb-3', [text('🔍')]),
        div(classes: 'text-lg font-medium text-muted-foreground mb-2', [
          text('Semantic Search Results'),
        ]),
        div(classes: 'text-sm text-muted-foreground', [
          text('Enter a search query to find similar records.'),
        ]),
      ],
    );
  }

  Component _buildQueryResults() {
    final result = _queryResult!;

    return div(classes: 'space-y-4', [
      // Query summary
      div(
        classes:
            'flex items-center justify-between p-3 bg-blue-50 border border-blue-200 rounded-md',
        [
          div(classes: 'flex items-center space-x-2', [
            div(classes: 'text-blue-500', [FaIcon(FaIcons.solid.search)]),
            div([
              div(classes: 'text-sm font-medium text-blue-900', [
                text('Query: "${result.query}"'),
              ]),
              div(classes: 'text-xs text-blue-700', [
                text(
                  '${result.successfulResults.length}/${result.modelResults.length} models searched in ${result.totalTime.inMilliseconds}ms',
                ),
              ]),
            ]),
          ]),
          Button(
            variant: ButtonVariant.ghost,
            size: ButtonSize.sm,
            onPressed: () => setState(() {
              _queryResult = null;
              _queryError = null;
            }),
            children: [FaIcon(FaIcons.solid.times), text('Clear')],
          ),
        ],
      ),

      // Results by model
      for (final modelResult in result.successfulResults.where(
        (r) => r.hasResults,
      ))
        _buildModelResults(modelResult),

      // Failed models
      if (result.failedResults.isNotEmpty)
        _buildFailedModels(result.failedResults),
    ]);
  }

  Component _buildModelResults(QueryResult modelResult) {
    return Card(
      className: 'border-l-4 border-l-primary-500',
      children: [
        div(classes: 'flex items-center justify-between mb-3', [
          div([
            div(classes: 'font-medium text-foreground', [
              text(
                '${_getProviderName(modelResult.providerId)} / ${modelResult.modelId}',
              ),
            ]),
            div(classes: 'text-xs text-muted-foreground', [
              text(
                '${modelResult.results.length} results in ${modelResult.queryTime.inMilliseconds}ms',
              ),
            ]),
          ]),
        ]),

        div(classes: 'space-y-2', [
          for (final (index, searchResult) in modelResult.results.indexed)
            _buildSearchResult(searchResult, index + 1),
        ]),
      ],
    );
  }

  Component _buildSearchResult(VectorSearchResult searchResult, int rank) {
    final similarity = ((1 - searchResult.distance) * 100).clamp(0, 100);

    return div(
      classes:
          'p-3 border border-neutral-200 rounded-md hover:bg-neutral-50 transition-colors',
      [
        div(classes: 'flex items-start justify-between mb-2', [
          div(classes: 'flex items-center space-x-2', [
            Badge(variant: BadgeVariant.outline, children: [text('#$rank')]),
            div(classes: 'text-xs text-muted-foreground', [
              text('ID: ${searchResult.id}'),
            ]),
          ]),
          div(classes: 'flex items-center space-x-2', [
            div(
              classes:
                  'text-xs font-medium ${_getSimilarityColor(similarity.toDouble())}',
              [text('${similarity.toStringAsFixed(1)}% similar')],
            ),
          ]),
        ]),

        div(classes: 'text-sm text-foreground', [
          text(searchResult.sourceData['content']?.toString() ?? 'No content'),
        ]),

        div(classes: 'text-xs text-muted-foreground mt-2', [
          text('Created: ${_formatDate(searchResult.createdAt)}'),
        ]),
      ],
    );
  }

  Component _buildFailedModels(List<QueryResult> failedResults) {
    return Card(
      className: 'border-l-4 border-l-red-500',
      children: [
        div(classes: 'flex items-center space-x-2 mb-3', [
          div(classes: 'text-red-500', [FaIcon(FaIcons.solid.warning)]),
          div(classes: 'font-medium text-red-900', [
            text('Failed Models (${failedResults.length})'),
          ]),
        ]),

        div(classes: 'space-y-2', [
          for (final failed in failedResults)
            div(classes: 'p-2 bg-red-50 border border-red-200 rounded', [
              div(classes: 'text-sm font-medium text-red-900', [
                text(
                  '${_getProviderName(failed.providerId)} / ${failed.modelId}',
                ),
              ]),
              div(classes: 'text-xs text-red-700', [
                text(failed.error ?? 'Unknown error'),
              ]),
            ]),
        ]),
      ],
    );
  }

  String _getSimilarityColor(double similarity) {
    if (similarity >= 80) return 'text-green-600';
    if (similarity >= 60) return 'text-yellow-600';
    return 'text-red-600';
  }

  String _getProviderName(String providerId) {
    final provider = configManager.embeddingProviderConfigs.getById(providerId);
    return provider?.name ?? 'Unknown Provider';
  }

  void _executeQuery() async {
    if (_queryText.trim().isEmpty) return;

    setState(() {
      _isQuerying = true;
      _queryError = null;
    });

    try {
      final queryService = EmbeddingQueryService(
        configService: configManager.configService,
        providerRegistry: configManager.embeddingProviders,
      );

      final result = await queryService.queryJob(
        job: _job!,
        queryText: _queryText.trim(),
        limit: 10,
      );

      setState(() {
        _queryResult = result;
      });

      _logger.info(
        'Query completed: ${result.successfulResults.length} successful models',
      );
    } catch (e) {
      _logger.severe('Failed to execute query: $_queryText', e);
      setState(() {
        _queryError = e.toString();
      });
    } finally {
      setState(() {
        _isQuerying = false;
      });
    }
  }
}
