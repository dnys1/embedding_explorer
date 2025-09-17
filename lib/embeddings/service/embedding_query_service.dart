import 'dart:async';

import 'package:logging/logging.dart';

import '../../configurations/model/embedding_tables.dart';
import '../../configurations/model/vector_search_result.dart';
import '../../configurations/service/configuration_service.dart';
import '../../jobs/model/embedding_job.dart';
import '../../providers/service/embedding_provider_registry.dart';
import '../../util/cancellation_token.dart';

/// Result of a query across multiple embedding models
class QueryResult {
  final String modelId;
  final String providerId;
  final List<VectorSearchResult> results;
  final Duration queryTime;
  final String? error;

  const QueryResult({
    required this.modelId,
    required this.providerId,
    required this.results,
    required this.queryTime,
    this.error,
  });

  bool get isSuccess => error == null;
  bool get hasResults => results.isNotEmpty;
}

/// Aggregate result of querying all models for a job
class JobQueryResult {
  final String jobId;
  final String query;
  final List<QueryResult> modelResults;
  final Duration totalTime;

  const JobQueryResult({
    required this.jobId,
    required this.query,
    required this.modelResults,
    required this.totalTime,
  });

  List<QueryResult> get successfulResults =>
      modelResults.where((r) => r.isSuccess).toList();

  List<QueryResult> get failedResults =>
      modelResults.where((r) => !r.isSuccess).toList();

  bool get hasAnyResults => modelResults.any((r) => r.hasResults);
}

/// Service for querying embeddings across multiple models and providers
class EmbeddingQueryService {
  static final Logger _logger = Logger('EmbeddingQueryService');

  final ConfigurationService _configService;
  final EmbeddingProviderRegistry _providerRegistry;

  EmbeddingQueryService({
    required ConfigurationService configService,
    required EmbeddingProviderRegistry providerRegistry,
  }) : _configService = configService,
       _providerRegistry = providerRegistry;

  /// Query embeddings for a completed job across all its models
  Future<JobQueryResult> queryJob({
    required EmbeddingJob job,
    required String queryText,
    int limit = 10,
    CancellationToken? cancellationToken,
  }) async {
    if (queryText.trim().isEmpty) {
      throw ArgumentError('Query text cannot be empty');
    }

    _logger.info(
      'Querying embeddings for job: ${job.id} with query: "$queryText"',
    );

    final stopwatch = Stopwatch()..start();

    try {
      // Get the embedding table for this job
      final tables = await _configService.getEmbeddingTables(jobId: job.id);
      if (tables.isEmpty) {
        throw StateError('No embedding table found for job: ${job.id}');
      }

      final table = tables.first;
      final tableId = table.id;

      // Get all embedding columns for this table
      final columns = await _configService.getEmbeddingColumns(tableId);
      if (columns.isEmpty) {
        throw StateError('No embedding columns found for table: $tableId');
      }

      _logger.info('Found ${columns.length} embedding columns to query');

      // Query each model in parallel
      final queryTasks = <Future<QueryResult>>[];

      for (final column in columns) {
        queryTasks.add(
          _queryColumn(
            tableId: tableId,
            column: column,
            queryText: queryText,
            limit: limit,
            cancellationToken: cancellationToken,
          ),
        );
      }

      final results = await Future.wait(queryTasks, eagerError: false);
      stopwatch.stop();

      final jobResult = JobQueryResult(
        jobId: job.id,
        query: queryText,
        modelResults: results,
        totalTime: stopwatch.elapsed,
      );

      _logger.info(
        'Query completed for job ${job.id}: ${jobResult.successfulResults.length}/${results.length} successful, '
        'total results: ${jobResult.successfulResults.fold<int>(0, (sum, r) => sum + r.results.length)}, '
        'time: ${jobResult.totalTime.inMilliseconds}ms',
      );

      return jobResult;
    } catch (e) {
      stopwatch.stop();
      _logger.severe('Failed to query job ${job.id}: $e', e);
      rethrow;
    }
  }

  /// Query a specific embedding column
  Future<QueryResult> _queryColumn({
    required String tableId,
    required EmbeddingColumn column,
    required String queryText,
    required int limit,
    CancellationToken? cancellationToken,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Check for cancellation
      cancellationToken?.throwIfCancelled();

      // Get the provider and generate embedding for query
      final provider = _providerRegistry.expect(column.modelProviderId);
      if (provider.config == null) {
        throw StateError(
          'Provider ${column.modelProviderId} is not configured',
        );
      }

      _logger.fine(
        'Generating query embedding with ${provider.displayName}/${column.modelName}',
      );

      // Generate embedding for the query text
      final embeddings = await provider.operations.generateEmbeddings(
        modelId: column.modelName,
        texts: {'query': queryText},
        cancellationToken: cancellationToken,
      );

      if (embeddings.isEmpty) {
        throw StateError('No embedding generated for query text');
      }

      final queryEmbedding = embeddings.first;

      // Search for similar vectors in the database
      final searchResults = await _configService.searchSimilarVectors(
        tableId: tableId,
        columnName: column.columnName,
        queryVector: queryEmbedding,
        vectorType: column.vectorType,
        limit: limit,
      );

      stopwatch.stop();

      _logger.fine(
        'Query for ${column.modelName} completed: ${searchResults.length} results in ${stopwatch.elapsedMilliseconds}ms',
      );

      return QueryResult(
        modelId: column.modelName,
        providerId: column.modelProviderId,
        results: searchResults,
        queryTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _logger.warning('Query failed for ${column.modelName}: $e');

      return QueryResult(
        modelId: column.modelName,
        providerId: column.modelProviderId,
        results: [],
        queryTime: stopwatch.elapsed,
        error: e.toString(),
      );
    }
  }
}
