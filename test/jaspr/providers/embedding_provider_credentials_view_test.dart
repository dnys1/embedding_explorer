@TestOn('browser')
library;

import 'package:embeddings_explorer/providers/component/embedding_provider_credentials_view.dart';
import 'package:embeddings_explorer/providers/service/builtin_providers/openai_provider.dart';
import 'package:web/web.dart' as web;

import '../../common.dart';
import '../common.dart';

void main() {
  setupTests();

  group('EmbeddingProviderCredentialsView Styling', () {
    testBrowser(
      'renders API key input with properly positioned toggle button',
      (tester) async {
        const factory = OpenAIFactory();
        final provider = factory.createUnconfigured();

        tester.pumpComponent(
          EmbeddingProviderCredentialsView(provider: provider),
        );

        await tester.pump();

        // Check that the input exists
        final input = find.tag('input');
        expect(input, findsOneComponent);

        // Check that the input has proper padding for the button (pr-12)
        final inputElement = tester.findNode<web.HTMLInputElement>(input);
        expect(inputElement?.className, contains('pr-12'));

        // Check that the button exists
        final button = find.tag('button');
        expect(button, findsOneComponent);

        // Check that the button has proper positioning classes
        final buttonElement = tester.findNode<web.HTMLButtonElement>(button);
        final buttonClassString = buttonElement?.className ?? '';
        expect(buttonClassString, contains('absolute'));
        expect(buttonClassString, contains('inset-y-0'));
        expect(buttonClassString, contains('right-0'));
        expect(buttonClassString, contains('flex'));
        expect(buttonClassString, contains('items-center'));
        expect(buttonClassString, contains('justify-center'));
      },
    );

    testBrowser('toggles password visibility when button is clicked', (
      tester,
    ) async {
      const factory = OpenAIFactory();
      final provider = factory.createUnconfigured();

      tester.pumpComponent(
        EmbeddingProviderCredentialsView(provider: provider),
      );

      await tester.pump();

      // Initially should be password type with eye icon
      final input = find.tag('input');
      final inputElement = tester.findNode<web.HTMLInputElement>(input);
      expect(inputElement?.type, equals('password'));

      // Click the toggle button
      final button = find.tag('button');
      await tester.click(button);
      await tester.pump();

      // Should now be text type
      final updatedInput = tester.findNode<web.HTMLInputElement>(
        find.tag('input'),
      );
      expect(updatedInput?.type, equals('text'));

      // Click again to toggle back
      await tester.click(button);
      await tester.pump();

      // Should be back to password type
      final finalInput = tester.findNode<web.HTMLInputElement>(
        find.tag('input'),
      );
      expect(finalInput?.type, equals('password'));
    });
  });
}
