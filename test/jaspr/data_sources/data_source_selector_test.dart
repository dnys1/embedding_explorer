@TestOn('browser')
library;

import 'package:embeddings_explorer/common/ui/ui.dart';
import 'package:embeddings_explorer/data_sources/component/data_source_selector.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_config.dart';
import 'package:embeddings_explorer/data_sources/model/data_source_settings.dart';
import 'package:jaspr/jaspr.dart';

import '../common.dart';

void main() {
  group('DataSourceSelector', () {
    testBrowser('renders correctly', (tester) async {
      final component = DataSourceSelector();
      final componentFinder = find.byComponent(component);
      tester.pumpComponent(component);

      expect(componentFinder, findsOneComponent);

      for (final type in DataSourceType.values) {
        expect(find.byKey(ValueKey(type)), findsOneComponent);
      }

      DataSourceSelectorState state() =>
          (componentFinder.evaluate().first as StatefulElement).state
              as DataSourceSelectorState;

      await tester.click(find.byKey(ValueKey(DataSourceType.csv)));
      await tester.pump();
      expect(state().selectedType, DataSourceType.csv);
      expect(
        find.byType(FileUpload),
        findsOneComponent,
        reason: 'CSV should show FileUpload',
      );

      await tester.click(find.byKey(ValueKey(DataSourceType.sqlite)));
      await tester.pump();
      expect(state().selectedType, DataSourceType.sqlite);
      expect(
        state().sqliteType,
        SqliteDataSourceType.import,
        reason: 'Should default to import',
      );
      expect(
        find.byType(FileUpload),
        findsOneComponent,
        reason: 'SQLite should show FileUpload',
      );

      await tester.click(find.byKey(ValueKey(DataSourceType.sample)));
      await tester.pump();
      expect(state().selectedType, DataSourceType.sample);
      expect(
        find.byType(FileUpload),
        findsNothing,
        reason: 'Sample should not show FileUpload',
      );
    });
  });
}
