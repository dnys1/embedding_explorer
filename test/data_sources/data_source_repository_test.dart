@TestOn('browser')
library;

import 'package:embeddings_explorer/configurations/model/configuration_manager.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_config.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_settings.dart';
import 'package:embeddings_explorer/data_sources/service/data_source_repository.dart';
import 'package:test/test.dart';

import '../common.dart';

void main() {
  setupTests();

  group('DataSourceRepository', () {
    late ConfigurationManager configManager;
    late DataSourceRepository repository;

    setUp(() async {
      configManager = ConfigurationManager.instance;
      await configManager.initialize(libsqlUri: testLibsqlUri);
      repository = configManager.dataSources;
    });

    tearDown(() async {
      await configManager.clearAll();
    });

    test('should return null for non-existent data source', () async {
      final result = repository.get('non-existent');
      expect(result, isNull);
    });

    test('should cache and reuse data source instances', () async {
      // Create a test data source config
      final settings = CsvDataSourceSettings(
        delimiter: ',',
        hasHeader: true,
        content: 'id,name\n1,Test Item 1\n2,Test Item 2',
      );

      final config = DataSourceConfig(
        id: 'test-csv',
        name: 'Test CSV',
        description: 'Test CSV data source',
        type: DataSourceType.csv,
        settings: settings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await configManager.dataSourceConfigs.add(config);

      // First call should create and cache the data source
      final dataSource1 = repository.get('test-csv');
      expect(dataSource1, isNotNull);
      expect(dataSource1!.id, equals('test-csv'));

      // Second call should return the same cached instance
      final dataSource2 = repository.get('test-csv');
      expect(dataSource2, same(dataSource1));
    });

    test('should handle configuration updates', () async {
      // Create initial config
      final settings = CsvDataSourceSettings(
        delimiter: ',',
        hasHeader: true,
        content: 'id,name\n1,Test Item 1',
      );

      final config = DataSourceConfig(
        id: 'test-csv',
        name: 'Test CSV',
        description: 'Original description',
        type: DataSourceType.csv,
        settings: settings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await configManager.dataSourceConfigs.add(config);

      // Get initial data source
      final dataSource1 = repository.get('test-csv');
      expect(dataSource1, isNotNull);

      // Update the configuration
      final updatedConfig = config.copyWith(
        description: 'Updated description',
        updatedAt: DateTime.now().add(Duration(seconds: 1)),
      );
      await configManager.dataSourceConfigs.add(updatedConfig);

      // Wait a bit for the change notification to process
      await Future<void>.delayed(
        Duration(milliseconds: 10),
      ); // Next call should return a new instance with updated config
      final dataSource2 = repository.get('test-csv');
      expect(dataSource2, isNotNull);
      expect(dataSource2!.config.description, equals('Updated description'));
    });

    test('should clean up removed data sources', () async {
      // Create and add data source
      final settings = CsvDataSourceSettings(
        delimiter: ',',
        hasHeader: true,
        content: 'id,name\n1,Test Item 1',
      );

      final config = DataSourceConfig(
        id: 'test-csv',
        name: 'Test CSV',
        description: 'Test description',
        type: DataSourceType.csv,
        settings: settings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await configManager.dataSourceConfigs.add(config);

      // Get data source (should be cached)
      final dataSource = repository.get('test-csv');
      expect(dataSource, isNotNull);

      // Remove from configuration
      await configManager.dataSourceConfigs.remove('test-csv');

      // Wait for change notification
      await Future<void>.delayed(Duration(milliseconds: 10));

      // Should return null now
      final result = repository.get('test-csv');
      expect(result, isNull);
    });
  });
}
