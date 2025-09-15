import 'dart:async';
import 'dart:math';

import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../util/async_snapshot.dart';
import '../../util/clsx.dart';
import '../model/embedding_provider.dart';

class EmbeddingProviderView extends StatefulComponent {
  const EmbeddingProviderView({
    required this.provider,
    required this.onConfigure,
    this.onEdit,
    super.key,
  });

  final EmbeddingProvider provider;
  final VoidCallback onConfigure;
  final VoidCallback? onEdit;

  @override
  State<EmbeddingProviderView> createState() => _EmbeddingProviderViewState();
}

class _EmbeddingProviderViewState extends State<EmbeddingProviderView>
    with ConfigurationManagerListener {
  EmbeddingProvider get provider => component.provider;

  bool get hasConfiguration => isPartiallyConfigured || isFullyConfigured;
  bool get isPartiallyConfigured => provider.isPartiallyConfigured;
  bool get isFullyConfigured => provider.isConnected;

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
                  text(provider.displayName),
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
                  'click': (_) => hasConfiguration && component.onEdit != null
                      ? component.onEdit!()
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
          if (isFullyConfigured && provider.config != null)
            div(classes: 'mt-4', [_buildModelsGrid(provider)]),
        ]),
      ],
    );
  }

  Component _buildModelsGrid(EmbeddingProvider provider) {
    return FutureBuilder<Map<String, EmbeddingModel>>(
      future: configManager.embeddingProviders.getAvailableModels(
        provider.config!.id,
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
              [
                for (final model in models.values)
                  _buildModelTile(provider, model),
              ],
            );
        }
      },
    );
  }

  Component _buildModelTile(EmbeddingProvider provider, EmbeddingModel model) {
    final isModelEnabled = provider.config!.enabledModels.contains(model.id);
    return Card(
      className: isModelEnabled
          ? 'border border-green-300 bg-green-50 hover:bg-green-100 cursor-pointer transition-colors'
          : 'border border-gray-300 bg-gray-50 hover:bg-gray-100 cursor-pointer transition-colors',
      children: [
        div(
          classes: 'p-4',
          events: {'click': (_) => _toggleModel(model, provider.config!.id)},
          [
            div(classes: 'flex items-center justify-between mb-2', [
              div(classes: 'flex items-center space-x-2', [
                h3(classes: 'text-sm font-medium text-foreground', [
                  text(model.name),
                ]),
                // if (_isNewModel(model))
                //   span(
                //     classes:
                //         'text-xs px-1 py-0.5 bg-blue-100 text-blue-800 rounded flex items-center space-x-1',
                //     [FaIcons.solid.star],
                //   ),
              ]),
              div(
                classes: isModelEnabled ? 'text-green-500' : 'text-gray-400',
                [
                  FaIcon(
                    isModelEnabled
                        ? FaIcons.solid.success
                        : FaIcons.regular.circle,
                  ),
                ],
              ),
            ]),

            p(classes: 'text-xs text-muted-foreground mb-2', [
              text(model.description),
            ]),

            div(classes: 'text-xs text-gray-500', [text('ID: ${model.id}')]),
          ],
        ),
      ],
    );
  }

  void _toggleModel(EmbeddingModel model, String providerConfigId) {
    unawaited(
      configManager.embeddingProviderConfigs.toggleModel(
        providerConfigId,
        model.id,
      ),
    );
  }
}
