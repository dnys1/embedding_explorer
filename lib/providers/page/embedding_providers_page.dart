import 'package:jaspr/jaspr.dart';

import '../../configurations/model/configuration_manager.dart';
import '../component/embedding_provider_config_dialog.dart';
import '../component/embedding_provider_view.dart';
import '../model/embedding_provider.dart';

class EmbeddingProvidersPage extends StatefulComponent {
  const EmbeddingProvidersPage({super.key});

  @override
  State<EmbeddingProvidersPage> createState() => _EmbeddingProvidersPageState();
}

class _EmbeddingProvidersPageState extends State<EmbeddingProvidersPage>
    with ConfigurationManagerListener {
  EmbeddingProvider? _configuringProvider;

  void _showConfigureProvider(EmbeddingProvider provider) {
    _configuringProvider = provider;

    setState(() {
      // _configuringProvider is already set above
    });
  }

  void _showEditConfigDialog(EmbeddingProvider provider) {
    setState(() {
      _configuringProvider = provider;
    });
  }

  void _hideDialogs() {
    setState(() {
      _configuringProvider = null;
    });
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col h-full', [
      // Page header
      div(classes: 'bg-white border-b px-4 py-3', [
        div(classes: 'flex justify-between items-center', [
          div([
            h1(classes: 'text-xl font-bold text-foreground', [
              text('Model Providers'),
            ]),
            p(classes: 'text-xs text-muted-foreground', [
              text(
                'Configure embedding model providers and manage their available models',
              ),
            ]),
          ]),
        ]),
      ]),

      // Main content - Provider rows
      div(classes: 'flex-1 p-6 overflow-y-auto', [
        div(classes: 'space-y-6', [
          // Built-in providers section
          div([
            h2(classes: 'text-xl font-semibold text-foreground mb-4', [
              text('Built-in Providers'),
            ]),
            div(classes: 'space-y-4', [
              for (final provider in configManager.embeddingProviders.all)
                EmbeddingProviderView(
                  provider: provider,
                  onConfigure: () => _showConfigureProvider(provider),
                  onEdit: provider.config != null
                      ? () => _showEditConfigDialog(provider)
                      : null,
                ),
            ]),
          ]),
        ]),
      ]),

      // Dialogs
      if (_configuringProvider case final provider?)
        div(
          classes:
              'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50',
          [
            EmbeddingProviderConfigDialog(
              provider: provider,
              onClose: _hideDialogs,
            ),
          ],
        ),
    ]);
  }
}
