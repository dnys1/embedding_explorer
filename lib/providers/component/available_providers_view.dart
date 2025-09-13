import 'dart:math';

import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../util/async_snapshot.dart';
import '../../util/clsx.dart';
import '../model/available_providers.dart';
import '../model/model_provider_config.dart';
import '../service/embedding_provider.dart';

class AvailableProviderView extends StatefulComponent {
  const AvailableProviderView({
    required this.provider,
    required this.onConfigure,
    required this.onEdit,
    super.key,
  });

  final AvailableProvider provider;
  final VoidCallback onConfigure;
  final VoidCallback onEdit;

  @override
  State<AvailableProviderView> createState() => _AvailableProviderViewState();
}

class _AvailableProviderViewState extends State<AvailableProviderView>
    with ConfigurationManagerListener {
  late final Logger _logger = Logger(
    'AvailableProviderView.${provider.type.name}',
  );
  AvailableProvider get provider => component.provider;
  ConfigurationState get configState => _getConfigurationState();

  bool get hasConfiguration => configState.hasConfiguration;
  bool get isPartiallyConfigured => configState.isPartiallyConfigured;
  bool get isFullyConfigured => configState.isFullyConfigured;

  @override
  Component build(BuildContext context) {
    return Card(
      className: 'border border-gray-200',
      children: [
        div(classes: 'p-5', [
          // Provider header with name and gear switch
          div(classes: 'flex items-center justify-between', [
            div(classes: 'flex items-center space-x-4', [
              div(classes: 'text-3xl', [FaIcon(provider.icon)]),
              div([
                h2(classes: 'text-xl font-semibold text-foreground', [
                  text(provider.name),
                ]),
                p(classes: 'text-sm text-muted-foreground', [
                  text(provider.description),
                ]),
              ]),
            ]),
            div(classes: 'flex items-center space-x-3', [
              // Configuration status badge
              if (isFullyConfigured)
                span(
                  classes:
                      'text-xs px-2 py-1 bg-green-100 text-green-800 rounded-full',
                  [text('Configured')],
                )
              else if (isPartiallyConfigured)
                span(
                  classes:
                      'text-xs px-2 py-1 bg-amber-100 text-amber-800 rounded-full flex items-center space-x-1',
                  [FaIcon(FaIcons.solid.warning), text('Needs Credentials')],
                )
              else
                span(
                  classes:
                      'text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full',
                  [text('Not configured')],
                ),
              // Gear switch for provider configuration
              button(
                classes: [
                  hasConfiguration
                      ? (isPartiallyConfigured
                            ? 'p-2 rounded-md bg-amber-100 hover:bg-amber-200 text-amber-600 transition-colors'
                            : 'p-2 rounded-md bg-green-100 hover:bg-green-200 text-green-600 transition-colors')
                      : 'p-2 rounded-md bg-gray-100 hover:bg-gray-200 text-gray-600 transition-colors',
                  'cursor-pointer',
                ].clsx,
                events: {
                  'click': (_) => hasConfiguration
                      ? component.onEdit()
                      : component.onConfigure(),
                },
                [FaIcon(FaIcons.solid.settings)],
              ),
            ]),
          ]),

          // Warning message for partially configured providers
          if (isPartiallyConfigured)
            div(
              classes: 'm-4 p-2 bg-amber-50 border border-amber-200 rounded-md',
              [
                div(classes: 'flex items-center space-x-2', [
                  div(classes: 'text-amber-600 text-sm', [
                    FaIcon(FaIcons.solid.warning),
                  ]),
                  p(classes: 'text-xs text-amber-800', [
                    text(
                      'Missing credentials. Click the gear button to configure.',
                    ),
                  ]),
                ]),
              ],
            ),

          // Model grid
          if (hasConfiguration) div(classes: 'mt-4', [_buildModelsGrid()]),
        ]),
      ],
    );
  }

  Component _buildModelsGrid() {
    return FutureBuilder<Map<String, EmbeddingModel>>(
      future: provider.listAvailableModels(
        configManager.modelProviders.getByType(provider.type)!,
      ),
      builder: (context, snapshot) {
        switch (snapshot.result) {
          case AsyncLoading():
            return div(classes: 'flex justify-center items-center py-8', [
              div(
                classes:
                    'animate-spin h-6 w-6 border-2 border-primary-500 border-t-transparent rounded-full',
                [],
              ),
            ]);
          case AsyncError(:final error):
            return div(classes: 'text-center py-8 text-red-600', [
              text('Error loading models: $error'),
            ]);
          case AsyncData(data: final models):
            if (models.isEmpty) {
              return div(classes: 'text-center py-8 text-gray-600', [
                text('No models available'),
              ]);
            }
            String gridCols(int count, [String? breakpoint]) {
              final buf = StringBuffer();
              if (breakpoint != null) {
                buf.write('$breakpoint:');
              }
              buf.write('grid-cols-${min(count, models.length)}');
              return buf.toString();
            }
            return div(
              classes: [
                'grid',
                gridCols(1),
                gridCols(1, 'sm'),
                gridCols(2, 'md'),
                gridCols(4, 'lg'),
                gridCols(4, 'xl'),
                'gap-4',
              ].clsx,
              [for (final model in models.values) _buildModelTile(model)],
            );
        }
      },
    );
  }

  Component _buildModelTile(EmbeddingModel model) {
    // Check if this specific model is enabled for this provider type
    bool isModelEnabled = false;
    String? providerConfigId;

    if (hasConfiguration) {
      final config = configManager.modelProviders.getByType(provider.type);
      if (config != null) {
        providerConfigId = config.id;
        isModelEnabled = config.enabledModels.contains(model.id);
      }
    }

    // Determine card styling based on configuration state
    String cardClassName;
    Map<String, void Function(Event)> events = {};

    if (isFullyConfigured) {
      cardClassName = isModelEnabled
          ? 'border border-green-300 bg-green-50 hover:bg-green-100 cursor-pointer transition-colors'
          : 'border border-gray-300 bg-gray-50 hover:bg-gray-100 cursor-pointer transition-colors';
      if (providerConfigId case final providerConfigId?) {
        events = {'click': (_) => _toggleModel(model, providerConfigId)};
      }
    } else {
      cardClassName =
          'border border-gray-200 bg-gray-100 cursor-not-allowed opacity-60';
    }

    return Card(
      className: cardClassName,
      children: [
        div(classes: 'p-4', events: events, [
          div(classes: 'flex items-center justify-between mb-2', [
            div(classes: 'flex items-center space-x-2', [
              h3(classes: 'text-sm font-medium text-foreground', [
                text(model.name),
              ]),
              // if (_isModelRecommended(model))
              //   span(
              //     classes:
              //         'text-xs px-1 py-0.5 bg-blue-100 text-blue-800 rounded flex items-center space-x-1',
              //     [FaIcons.solid.star],
              //   ),
            ]),
            // Status indicator based on configuration state
            if (isFullyConfigured)
              div(
                classes: isModelEnabled ? 'text-green-500' : 'text-gray-400',
                [
                  FaIcon(
                    isModelEnabled
                        ? FaIcons.solid.success
                        : FaIcons.regular.circle,
                  ),
                ],
              )
            else if (isPartiallyConfigured)
              div(classes: 'text-amber-500', [FaIcon(FaIcons.solid.warning)])
            else
              div(classes: 'text-gray-300', [FaIcon(FaIcons.regular.circle)]),
          ]),

          p(classes: 'text-xs text-muted-foreground mb-2', [
            text(model.description),
          ]),

          // Show warning for partially configured providers
          if (isPartiallyConfigured)
            p(
              classes:
                  'text-xs text-amber-600 mb-2 font-medium flex items-center space-x-1',
              [
                FaIcon(FaIcons.solid.warning),
                text('Add credentials to enable'),
              ],
            )
          else if (!hasConfiguration)
            p(classes: 'text-xs text-gray-500 mb-2', [
              text('Configure provider first'),
            ]),

          div(classes: 'text-xs text-gray-500', [text('ID: ${model.id}')]),
        ]),
      ],
    );
  }

  /// Determine the configuration state for a provider type
  ConfigurationState _getConfigurationState() {
    final config = configManager.modelProviders.getByType(provider.type);
    if (config == null) {
      return ConfigurationState.notConfigured;
    }

    // Check if credentials are required and whether they're persisted
    final availableProvider = AvailableProviders.all.firstWhere(
      (p) => p.type == provider.type,
      orElse: () =>
          throw StateError('Provider type ${provider.type} not found'),
    );

    if (availableProvider.requiredCredential case final requiredCred?) {
      // If credentials are required but not persisted, it's partially configured
      if (config.credential?.type != requiredCred) {
        return ConfigurationState.partiallyConfigured;
      }
    }

    return ConfigurationState.fullyConfigured;
  }

  void _toggleModel(EmbeddingModel model, String providerConfigId) async {
    final success = await configManager.modelProviders.toggleModel(
      providerConfigId,
      model.id,
    );
    if (!mounted) return;
    if (success) {
      setState(() {}); // Refresh the UI
      _logger.finest(
        'Toggled model ${model.id} for provider config $providerConfigId',
      );
    } else {
      _logger.warning('Failed to toggle model ${model.id}');
    }
  }
}
