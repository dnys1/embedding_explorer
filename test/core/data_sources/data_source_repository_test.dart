@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:math';

import 'package:embeddings_explorer/configurations/model/configuration_manager.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_config.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_settings.dart';
import 'package:embeddings_explorer/data_sources/service/data_source_repository.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

import '../../common.dart';

void main() {
  setupTests();

  group('DataSourceRepository', () {
    late ConfigurationManager configManager;
    late DataSourceRepository repository;
    late StreamController<void> repositoryChanges;

    setUpAll(() async {
      configManager = ConfigurationManager.instance;
      await configManager.initialize(
        libsqlUri: testLibsqlUri,
        clearOnInit: true,
        poolName: 'test_${Random().nextInt(10000)}',
      );
      repository = configManager.dataSources;
    });

    setUp(() {
      repositoryChanges = StreamController<void>.broadcast(sync: true);
      void handleChange() {
        repositoryChanges.add(null);
      }

      repository.addListener(handleChange);
      addTearDown(() {
        repository.removeListener(handleChange);
        return repositoryChanges.close();
      });
    });

    tearDown(() async {
      await configManager.clearAll();
    });

    Future<void> nextChange() async {
      await repositoryChanges.stream.first.timeout(Duration(seconds: 5));
    }

    test('should return null for non-existent data source', () async {
      final result = repository.get('non-existent');
      expect(result, isNull);
    });

    test('should cache and reuse data source instances', () async {
      // Create a test data source config
      final settings = CsvDataSourceSettings(delimiter: ',', hasHeader: true);
      const content = 'id,name\n1,Test Item 1\n2,Test Item 2';

      final config = DataSourceConfig(
        id: 'test-csv',
        name: 'Test CSV',
        description: 'Test CSV data source',
        type: DataSourceType.csv,
        filename: 'test.csv',
        settings: settings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dataSource = await repository.import(
        config: config,
        file: web.File([content.toJS].toJS, 'test.csv'),
      );

      // First call should create and cache the data source
      final dataSource1 = repository.get('test-csv');
      expect(dataSource1, isNotNull);
      expect(dataSource1, same(dataSource));

      // Second call should return the same cached instance
      final dataSource2 = repository.get('test-csv');
      expect(dataSource2, same(dataSource1));
    });

    test('should handle configuration updates', () async {
      // Create initial config
      final settings = CsvDataSourceSettings(delimiter: ',', hasHeader: true);
      const content = 'id,name\n1,Test Item 1';

      final config = DataSourceConfig(
        id: 'test-csv',
        name: 'Test CSV',
        description: 'Original description',
        type: DataSourceType.csv,
        filename: 'test.csv',
        settings: settings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dataSource = await repository.import(
        config: config,
        file: web.File([content.toJS].toJS, 'test.csv'),
      );
      await nextChange();

      // Get initial data source
      final dataSource1 = repository.get('test-csv');
      expect(dataSource1, isNotNull);
      expect(dataSource1, same(dataSource));

      // Update the configuration
      final updatedConfig = config.copyWith(
        description: 'Updated description',
        updatedAt: DateTime.now().add(Duration(seconds: 1)),
      );

      unawaited(configManager.dataSourceConfigs.upsert(updatedConfig));
      await nextChange();

      final dataSource2 = repository.get('test-csv');
      expect(
        dataSource2,
        isNotNull,
        reason: 'Not in repo: ${repository.all.map((e) => e.id).toList()}',
      );
      expect(dataSource2!.config.description, equals('Updated description'));
    });

    test('should clean up removed data sources', () async {
      // Create and add data source
      final settings = CsvDataSourceSettings(delimiter: ',', hasHeader: true);
      const content = 'id,name\n1,Test Item 1';

      final config = DataSourceConfig(
        id: 'test-csv',
        name: 'Test CSV',
        description: 'Test description',
        type: DataSourceType.csv,
        filename: 'test.csv',
        settings: settings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.import(
        config: config,
        file: web.File([content.toJS].toJS, 'test.csv'),
      );
      await nextChange();

      // Get data source (should be cached)
      final dataSource = repository.get('test-csv');
      expect(dataSource, isNotNull);

      // Remove from configuration
      unawaited(configManager.dataSourceConfigs.remove('test-csv'));
      await nextChange();

      // Should return null now
      final result = repository.get('test-csv');
      expect(result, isNull);
    });
  });
}
