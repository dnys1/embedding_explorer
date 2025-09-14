import 'dart:async';
import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import '../../configurations/model/configuration_manager.dart';
import '../../database/database_pool.dart';
import '../../storage/service/storage_service.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart';
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

  final OpfsStorageService _opfsStorage = OpfsStorageService();

  DataSourceRepository(this._configManager, this._databasePool) {
    _configManager.dataSourceConfigs.addListener(_onDataSourceConfigChanged);
  }

  /// Preload existing data sources from configuration
  Future<void> initialize() async {
    final configs = _configManager.dataSourceConfigs.all;
    await Future.wait<void>([
      for (final config in configs) _tryConnect(config),
    ]);
  }

  Future<void> _tryConnect(DataSourceConfig config) async {
    try {
      await connect(config);
    } catch (e, st) {
      _logger.warning('Failed to connect to data source: ${config.id}', e, st);
    }
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

  /// Load a data source from configuration and a [web.Blob], typically a
  /// [web.File].
  Future<DataSource> import({
    required DataSourceConfig config,
    required web.File file,
  }) async {
    final DataSource dataSource = await switch (config.type) {
      DataSourceType.csv => CsvDataSource.import(
        config: config,
        file: file,
        storage: _opfsStorage,
      ),
      DataSourceType.sqlite => SqliteDataSource.import(
        dbPool: _databasePool,
        config: config,
        file: file,
      ),
      DataSourceType.sample => throw UnsupportedError(
        'Loading sample data source from file is not supported',
      ),
    };
    _dataSources[config.id] = dataSource;
    scheduleMicrotask(() {
      unawaited(_configManager.dataSourceConfigs.upsert(config));
    });
    return dataSource;
  }

  /// Connect to a data source by its configuration.
  Future<DataSource> connect(DataSourceConfig config) async {
    if (_dataSources[config.id] case final dataSource?) {
      return dataSource;
    }

    final DataSource dataSource = await switch (config.type) {
      DataSourceType.csv => CsvDataSource.connect(
        config: config,
        storage: _opfsStorage,
      ),
      DataSourceType.sqlite => SqliteDataSource.connect(
        dbPool: _databasePool,
        config: config,
      ),
      DataSourceType.sample => SampleDataSource.connect(
        dbPool: _databasePool,
        config: config,
      ),
    };

    _dataSources[config.id] = dataSource;
    scheduleMicrotask(() {
      unawaited(_configManager.dataSourceConfigs.upsert(config));
    });
    return dataSource;
  }

  Future<void> delete(String id) async {
    final dataSource = _dataSources.remove(id);
    notifyListeners();
    try {
      await dataSource?.dispose();
      if (dataSource is SqliteDataSource) {
        await _databasePool.delete(dataSource.config.filename);
      } else if (dataSource is CsvDataSource) {
        final opfs = await web.window.navigator.storage.getDirectory().toDart;
        await opfs.removeEntry(dataSource.config.filename).toDart;
      }
      await _configManager.dataSourceConfigs.remove(id);
      _logger.info('Deleted data source: $id');
    } catch (e) {
      _logger.warning('Error disposing data source: $id', e);
    }
  }

  Future<void> clear() async {
    try {
      await Future.wait(_dataSources.values.map((ds) => ds.dispose()));
      await _opfsStorage.clear();
    } finally {
      _dataSources.clear();
    }
  }

  @override
  Future<void> dispose() async {
    _configManager.dataSourceConfigs.removeListener(_onDataSourceConfigChanged);
    await clear();
    super.dispose();
  }

  /// Handle changes to data source configurations
  void _onDataSourceConfigChanged() {
    final currentConfigs = _configManager.dataSourceConfigs.all;
    final currentIds = currentConfigs.map((c) => c.id).toSet();
    final cachedIds = _dataSources.keys.toSet();

    final connects = <Future<void> Function()>[];
    final disconnects = <Future<void> Function()>[];

    // Remove data sources that no longer exist in config
    final removedIds = cachedIds.difference(currentIds);
    for (final id in removedIds) {
      _logger.info('Data source config removed: $id');
      disconnects.add(() => _tryDisconnect(id));
    }

    // Add new data sources that are in config but not yet cached
    final newIds = currentIds.difference(cachedIds);
    for (final id in newIds) {
      _logger.info('Data source config added: $id');
      final config = currentConfigs.firstWhere((c) => c.id == id);
      disconnects.add(() => _tryConnect(config));
    }

    // Update existing data sources if their config changed
    for (final config in currentConfigs) {
      if (_dataSources.containsKey(config.id)) {
        final existing = _dataSources[config.id]!;
        if (_hasConfigChanged(existing.config, config)) {
          _logger.info('Configuration changed for data source: ${config.id}');
          // Disconnect and recreate the data source with new config
          disconnects.add(() => _tryDisconnect(config.id));
          connects.add(() => _tryConnect(config));
        }
      }
    }

    Future.wait(
      disconnects.map((f) => f()),
    ).then((_) => Future.wait(connects.map((f) => f()))).whenComplete(() {
      _logger.fine('Data source configurations synchronized');
      notifyListeners();
    });
  }

  /// Remove a data source from cache and disconnect it
  Future<void> _tryDisconnect(String id) async {
    final dataSource = _dataSources.remove(id);

    if (dataSource != null) {
      _logger.info('Removing data source from cache: $id');
      await dataSource.dispose().catchError((Object e) {
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
