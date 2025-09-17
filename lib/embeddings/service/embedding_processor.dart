import 'dart:async';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import '../../configurations/model/embedding_tables.dart' show VectorType;
import '../../configurations/service/configuration_service.dart';
import '../../data_sources/model/data_source.dart';
import '../../jobs/model/embedding_job.dart';
import '../../jobs/service/error_recovery_service.dart';
import '../../providers/model/embedding_provider.dart';
import '../../providers/model/embedding_provider_config.dart';
import '../../providers/service/embedding_provider_registry.dart';
import '../../util/cancellation_token.dart';

/// Configuration for batch processing
class BatchConfig {
  final int batchSize;
  final Duration rateLimitDelay;

  const BatchConfig({
    this.batchSize = 50,
    this.rateLimitDelay = const Duration(milliseconds: 100),
  });
}

/// Result of processing a single batch
class BatchProcessingResult {
  final String providerId;
  final List<List<double>> embeddings;
  final Map<String, String> processedTexts;
  final List<String> errors;
  final Duration processingTime;

  const BatchProcessingResult({
    required this.providerId,
    required this.embeddings,
    required this.processedTexts,
    required this.errors,
    required this.processingTime,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get successCount => embeddings.length;
  int get errorCount => errors.length;
}

typedef EmbeddingModelId = (String providerId, String modelId);

/// Result of processing an entire job
class JobProcessingResult {
  final String jobId;
  final int totalRecords;
  final int processedRecords;
  final Duration totalTime;

  const JobProcessingResult({
    required this.jobId,
    required this.totalRecords,
    required this.processedRecords,
    required this.totalTime,
  });
}

class BatchProgress {
  final String jobId;
  final String providerId;
  final String modelId;
  final int completedBatch;
  final int processedRecords;

  BatchProgress({
    required this.jobId,
    required this.providerId,
    required this.modelId,
    required this.completedBatch,
    required this.processedRecords,
  });
}

/// Core service for processing data through embedding models
class EmbeddingProcessor {
  static final Logger _logger = Logger('EmbeddingProcessor');

  final EmbeddingProviderRegistry _providerRegistry;
  final ConfigurationService _configService;
  final ErrorRecoveryService _errorRecoveryService;
  final BatchConfig _batchConfig;

  EmbeddingProcessor({
    required EmbeddingProviderRegistry providerRegistry,
    required ConfigurationService configService,
    required ErrorRecoveryService errorRecoveryService,
    BatchConfig? batchConfig,
  }) : _providerRegistry = providerRegistry,
       _configService = configService,
       _errorRecoveryService = errorRecoveryService,
       _batchConfig = batchConfig ?? const BatchConfig();

  /// Process a complete embedding job
  Future<JobProcessingResult> processJob({
    required EmbeddingJob job,
    required DataSource dataSource,
    required Map<String, String> renderedTexts,
    required Map<(String, String), int> startFromBatch,
    CancellationToken? cancellationToken,
    FutureOr<void> Function(BatchProgress)? onProgress,
  }) async {
    _logger.info('Starting job processing: ${job.id}');

    final stopwatch = Stopwatch()..start();

    try {
      // Create embedding table if needed
      final tableId = await _createEmbeddingTable(job, dataSource);

      // Process each provider
      final providerTasks = <Future<JobProcessingResult>>[];
      for (final providerId in job.providerIds) {
        _logger.info('Processing with provider: $providerId');

        final provider = _providerRegistry.expect(providerId);
        if (provider.config == null) {
          throw StateError('Provider $providerId is not configured');
        }

        // Fetch available models for the provider
        final models = await provider.operations.listAvailableModels();

        for (final model in models.values) {
          if (!job.modelIds.contains(model.id)) {
            continue;
          }

          // Check for cancellation before processing each model
          cancellationToken?.throwIfCancelled();

          providerTasks.add(
            _processWithProvider(
              job: job,
              provider: provider,
              model: model,
              texts: renderedTexts,
              tableId: tableId,
              startFromBatch: startFromBatch,
              cancellationToken: cancellationToken,
              onProgress: onProgress,
            ),
          );
        }
      }

      final allResults = await Future.wait(providerTasks, eagerError: true);
      stopwatch.stop();

      // Calculate total embedding records (texts × number of models being processed)
      final totalProcessed = allResults
          .map((result) => result.processedRecords)
          .fold<int>(0, (sum, count) => sum + count);
      final modelsToProcess = job.modelIds.length;
      final totalEmbeddingRecords = renderedTexts.length * modelsToProcess;

      final result = JobProcessingResult(
        jobId: job.id,
        totalRecords: totalEmbeddingRecords,
        processedRecords: totalProcessed,
        totalTime: stopwatch.elapsed,
      );

      _logger.info(
        'Job processing completed: ${job.id} - ${result.processedRecords}/${result.totalRecords} records',
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      cancellationToken?.cancel();
      _logger.severe('Job processing failed: ${job.id}', e);
      rethrow;
    }
  }

  /// Process embeddings with a specific provider
  Future<JobProcessingResult> _processWithProvider({
    required EmbeddingJob job,
    required EmbeddingProvider provider,
    required EmbeddingModel model,
    required Map<String, String> texts,
    required String tableId,
    Map<(String, String), int>? startFromBatch,
    CancellationToken? cancellationToken,
    FutureOr<void> Function(BatchProgress progress)? onProgress,
  }) async {
    final config = provider.config!;

    int processedCount = 0;

    // Determine model and get embedding dimension
    _logger.info(
      'Processing ${texts.length} texts with model'
      '${startFromBatch != null ? ' (from batch $startFromBatch)' : ''}: '
      '(${provider.displayName}, ${model.id})',
    );

    // Add vector column to embedding table
    await _addVectorColumn(
      tableId: tableId,
      providerId: config.id,
      modelId: model.id,
      dimensions: model.dimensions, // TODO: custom dims
      vectorType: model.vectorType,
    );

    // Process in batches
    final batches = texts.entries
        .slices(_batchConfig.batchSize)
        .toList(growable: false);
    final modelStartFromBatch = startFromBatch != null
        ? startFromBatch[(provider.config!.id, model.id)]
        : null;

    for (final (batchIndex, batch) in batches.indexed) {
      // Check for cancellation before processing each batch
      cancellationToken?.throwIfCancelled();

      final batchNumber = batchIndex + 1;

      // Skip batches that are before the start batch
      if (modelStartFromBatch != null && batchNumber < modelStartFromBatch) {
        _logger.fine('Skipping batch $batchNumber (< $modelStartFromBatch)');

        // Still need to account for the skipped records in progress tracking
        final skippedCount = batch.length;
        processedCount += skippedCount;

        continue;
      }

      final batchResult = await _processBatch(
        provider: provider,
        config: config,
        modelId: model.id,
        texts: Map.fromEntries(batch),
        batchNumber: batchNumber,
        cancellationToken: cancellationToken,
      );

      _logger.info(
        'Completed batch $batchNumber/${batches.length}: '
        '${batchResult.successCount} embeddings, '
        '${batchResult.errorCount} errors, '
        'time: ${batchResult.processingTime.inSeconds}s',
      );

      processedCount += batchResult.successCount;

      // Store embeddings in database
      await _storeEmbeddings(
        tableId: tableId,
        embeddings: batchResult.embeddings,
        texts: batchResult.processedTexts,
        providerId: config.id,
      );

      // Update progress
      await onProgress?.call(
        BatchProgress(
          jobId: job.id,
          providerId: config.id,
          modelId: model.id,
          completedBatch: batchNumber,
          processedRecords: batchResult.successCount,
        ),
      );

      // Rate limiting
      if (batchIndex < batches.length - 1) {
        await Future<void>.delayed(_batchConfig.rateLimitDelay);
      }
    }

    return JobProcessingResult(
      jobId: job.id,
      totalRecords: texts.length,
      processedRecords: processedCount,
      totalTime: Duration.zero, // Will be calculated by caller
    );
  }

  /// Process a single batch with retry logic
  Future<BatchProcessingResult> _processBatch({
    required EmbeddingProvider provider,
    required EmbeddingProviderConfig config,
    required String modelId,
    required Map<String, String> texts,
    required int batchNumber,
    CancellationToken? cancellationToken,
  }) async {
    final stopwatch = Stopwatch()..start();

    final result = await _errorRecoveryService
        .executeWithRetry<List<List<double>>>(
          () => provider.operations.generateEmbeddings(
            modelId: modelId,
            texts: texts,
            cancellationToken: cancellationToken,
          ),
          context:
              'batch $batchNumber processing ($modelId, ${texts.length} texts)',
        );

    stopwatch.stop();
    final embeddings = result.unwrap();

    return BatchProcessingResult(
      providerId: config.id,
      embeddings: embeddings,
      processedTexts: texts,
      errors: const [],
      processingTime: stopwatch.elapsed,
    );
  }

  /// Create an embedding table for the job
  Future<String> _createEmbeddingTable(
    EmbeddingJob job,
    DataSource dataSource,
  ) async {
    _logger.info('Creating embedding table for job: ${job.id}');

    final tableId = await _configService.createEmbeddingTable(
      jobId: job.id,
      dataSourceId: job.dataSourceId,
      embeddingTemplateId: job.embeddingTemplateId,
    );

    _logger.info('Created embedding table: $tableId');
    return tableId;
  }

  /// Add a vector column to the embedding table
  Future<void> _addVectorColumn({
    required String tableId,
    required String providerId,
    required String modelId,
    required VectorType vectorType,
    required int dimensions,
  }) async {
    _logger.info(
      'Adding vector column: $providerId/$modelId ($dimensions dims)',
    );

    await _configService.addVectorColumn(
      tableId: tableId,
      modelProviderId: providerId,
      modelName: modelId,
      vectorType: vectorType,
      dimensions: dimensions,
    );

    _logger.info('Added vector column for $providerId/$modelId');
  }

  /// Store embeddings in the database
  Future<void> _storeEmbeddings({
    required String tableId,
    required List<List<double>> embeddings,
    required Map<String, String> texts,
    required String providerId,
  }) async {
    _logger.fine(
      'Storing ${embeddings.length} embeddings for provider: $providerId',
    );

    for (final (i, entry) in texts.entries.indexed) {
      final MapEntry(key: recordId, value: text) = entry;
      final sourceData = {'content': text};

      // Get the vector column name for this provider
      final columns = await _configService.getEmbeddingColumns(tableId);
      final providerColumn = columns.firstWhereOrNull(
        (col) => col.modelProviderId == providerId,
      );
      if (providerColumn == null) {
        throw StateError(
          'No vector column found for provider $providerId in table $tableId. '
          'Available columns: ${columns.map((c) => (c.id, c.modelName, c.modelProviderId)).join(', ')}',
        );
      }

      await _configService.insertEmbeddingData(
        tableId: tableId,
        recordId: recordId,
        sourceData: sourceData,
        embeddings: {providerColumn.columnName: embeddings[i]},
      );
    }

    _logger.fine('Stored ${embeddings.length} embeddings');
  }
}
