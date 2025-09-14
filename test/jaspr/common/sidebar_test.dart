@TestOn('browser')
library;

import 'package:embeddings_explorer/common/sidebar.dart';

import '../../common.dart';
import '../common.dart';

void main() {
  setupTests();

  group('Sidebar UI Components', () {
    testBrowser('renders sidebar with UI components', (tester) async {
      tester.pumpComponent(Sidebar(isOpen: true));

      await tester.pump();

      // Check that the sidebar renders
      final sidebar = find.tag('aside');
      expect(sidebar, findsOneComponent);

      // Check that the mobile close button is present
      final closeButton = find.tag('button');
      expect(closeButton, findsOneComponent);
    });

    testBrowser('close button triggers callback', (tester) async {
      bool closeCalled = false;

      tester.pumpComponent(
        Sidebar(
          isOpen: true,
          onClose: () {
            closeCalled = true;
          },
        ),
      );

      await tester.pump();

      // Click the close button
      final closeButton = find.tag('button');
      await tester.click(closeButton);

      expect(closeCalled, isTrue);
    });
  });
}
