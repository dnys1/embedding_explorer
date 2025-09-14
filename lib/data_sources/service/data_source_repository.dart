import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../configurations/model/configuration_manager.dart';
import '../../database/database_pool.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart';
import '../model/data_source_settings.dart';
import 'csv_data_source.dart';
import 'sqlite_data_source.dart';

/// Repository that manages DataSource instances and their connections.
///
/// This class maintains a cache of DataSource instances, keeping connections
/// alive for efficiency and handling configuration changes automatically.
/// It listens to the ConfigurationManager and ensures data sources are
/// properly connected, updated, and disposed when needed.
class DataSourceRepository with ChangeNotifier {
  static final Logger _logger = Logger('DataSourceRepository');

  final ConfigurationManager _configManager;
  final DatabasePool _databasePool;
  final Map<String, DataSource> _dataSources = {};

  DataSourceRepository(this._configManager, this._databasePool) {
    _configManager.dataSourceConfigs.addListener(_onDataSourceConfigChanged);
  }

  /// Preload existing data sources from configuration
  Future<void> initialize() async {
    final configs = _configManager.dataSourceConfigs.all;
    await Future.wait<void>([
      for (final config in configs)
        Future(() async {
          try {
            await connect(config);
          } catch (e, st) {
            _logger.warning(
              'Failed to connect to data source: ${config.id}',
              e,
              st,
            );
          }
        }),
    ]);
  }

  /// Get all available data sources
  List<DataSource> get all => _dataSources.values.toList();

  List<String> get persistentSqliteDatabaseNames => _databasePool.databaseNames;

  /// Get a data source by ID.
  DataSource? get(String id) => _dataSources[id];

  /// Get a data source by ID, throwing if not found.
  DataSource expect(String id) {
    final dataSource = get(id);
    if (dataSource == null) {
      throw StateError('Data source not found: $id');
    }
    return dataSource;
  }

  /// Load a data source from configuration and a [web.File].
  Future<DataSource> loadFromFile({
    required DataSourceConfig config,
    required web.File file,
  }) async {
    final DataSource dataSource = await switch (config.type) {
      DataSourceType.csv => CsvDataSource.loadFromFile(
        config: config,
        file: file,
      ),
      DataSourceType.sqlite => SqliteDataSource.loadFromFile(
        dbPool: _databasePool,
        config: config,
        file: file,
      ),
    };
    _dataSources[config.id] = dataSource;
    unawaited(_configManager.dataSourceConfigs.add(config));
    return dataSource;
  }

  /// Connect to a data source by its configuration.
  Future<DataSource> connect(DataSourceConfig config) async {
    if (_dataSources[config.id] case final dataSource?) {
      return dataSource;
    }

    final DataSource dataSource = await switch (config.type) {
      DataSourceType.csv => CsvDataSource.connect(config: config),
      DataSourceType.sqlite => SqliteDataSource.connect(
        dbPool: _databasePool,
        config: config,
      ),
    };

    _dataSources[config.id] = dataSource;
    unawaited(_configManager.dataSourceConfigs.add(config));
    return dataSource;
  }

  Future<void> delete(String id) async {
    final dataSource = _dataSources.remove(id);
    notifyListeners();
    try {
      await dataSource?.dispose();
      if (dataSource case SqliteDataSource(
        sqliteSettings: SqliteDataSourceSettings(
          filename: final filename?,
          persistent: true,
        ),
      )) {
        await _databasePool.delete(filename);
      }
      await _configManager.dataSourceConfigs.remove(id);
      _logger.info('Deleted data source: $id');
    } catch (e) {
      _logger.warning('Error disposing data source: $id', e);
    }
  }

  @override
  Future<void> dispose() async {
    _configManager.dataSourceConfigs.removeListener(_onDataSourceConfigChanged);

    await Future.wait(_dataSources.values.map((ds) => ds.dispose()));

    _dataSources.clear();

    super.dispose();
  }

  /// Handle changes to data source configurations
  void _onDataSourceConfigChanged() {
    final currentConfigs = _configManager.dataSourceConfigs.all;
    final currentIds = currentConfigs.map((c) => c.id).toSet();
    final cachedIds = _dataSources.keys.toSet();

    // Remove data sources that no longer exist in config
    final removedIds = cachedIds.difference(currentIds);
    for (final id in removedIds) {
      _removeDataSource(id);
    }

    // Update existing data sources if their config changed
    for (final config in currentConfigs) {
      if (_dataSources.containsKey(config.id)) {
        final existing = _dataSources[config.id]!;
        if (_hasConfigChanged(existing.config, config)) {
          _logger.info('Configuration changed for data source: ${config.id}');
          // Disconnect and recreate the data source with new config
          // TODO:
          // _removeDataSource(config.id);
          // The data source will be recreated on next access
        }
      }
    }

    notifyListeners();
  }

  /// Remove a data source from cache and disconnect it
  void _removeDataSource(String id) {
    final dataSource = _dataSources.remove(id);

    if (dataSource != null) {
      _logger.info('Removing data source from cache: $id');
      // Disconnect asynchronously without waiting
      dataSource.dispose().catchError((Object e) {
        _logger.warning('Error disconnecting removed data source: $id', e);
      });
    }
  }

  /// Check if data source configuration has changed
  bool _hasConfigChanged(
    DataSourceConfig oldConfig,
    DataSourceConfig newConfig,
  ) {
    // Compare key fields that would require reconnection
    return oldConfig.name != newConfig.name ||
        oldConfig.description != newConfig.description ||
        oldConfig.settings != newConfig.settings ||
        oldConfig.updatedAt != newConfig.updatedAt;
  }
}
