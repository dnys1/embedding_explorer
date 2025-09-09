import 'package:jaspr/jaspr.dart';

import '../components/provider_selector.dart';
import '../models/embedding_provider.dart';

class ProviderSelectionPage extends StatefulComponent {
  const ProviderSelectionPage({super.key});

  @override
  State<ProviderSelectionPage> createState() => _ProviderSelectionPageState();
}

class _ProviderSelectionPageState extends State<ProviderSelectionPage> {
  EmbeddingProvider? _selectedProvider;
  Map<String, dynamic>? _providerConfig;
  String? _errorMessage;

  @override
  Component build(BuildContext context) {
    return div(classes: 'min-h-screen bg-gray-50 py-8', [
      div(classes: 'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8', [
        // Page header with breadcrumb
        _buildHeader(),

        // Error message if any
        if (_errorMessage != null) _buildErrorMessage(),

        // Success message if provider is selected
        if (_selectedProvider != null) _buildSuccessMessage(),

        // Provider selector component
        ProviderSelector(
          onProviderSelected: (provider, config) {
            setState(() {
              _selectedProvider = provider;
              _providerConfig = config;
              _errorMessage = null;
            });
          },
          onError: (message) {
            setState(() {
              _errorMessage = message;
            });
          },
        ),

        // Next steps section (if provider is selected)
        if (_selectedProvider != null) _buildNextSteps(),
      ]),
    ]);
  }

  Component _buildHeader() {
    return div(classes: 'mb-8', [
      // Breadcrumb
      nav(
        classes: 'flex',
        attributes: {'aria-label': 'Breadcrumb'},
        [
          ol(classes: 'flex items-center space-x-4', [
            li([
              a(
                href: '/data-source',
                classes: 'text-gray-400 hover:text-gray-500',
                [text('Data Source')],
              ),
            ]),
            li(classes: 'flex items-center', [
              svg(
                classes: 'flex-shrink-0 h-5 w-5 text-gray-300',
                attributes: {'fill': 'currentColor', 'viewBox': '0 0 20 20'},
                [
                  path(
                    attributes: {
                      'd': 'M5.555 17.776l8-16 .894.448-8 16-.894-.448z',
                    },
                    [],
                  ),
                ],
              ),
              a(
                href: '/transformation',
                classes: 'ml-4 text-gray-400 hover:text-gray-500',
                [text('Transformation')],
              ),
            ]),
            li(classes: 'flex items-center', [
              svg(
                classes: 'flex-shrink-0 h-5 w-5 text-gray-300',
                attributes: {'fill': 'currentColor', 'viewBox': '0 0 20 20'},
                [
                  path(
                    attributes: {
                      'd': 'M5.555 17.776l8-16 .894.448-8 16-.894-.448z',
                    },
                    [],
                  ),
                ],
              ),
              span(classes: 'ml-4 text-sm font-medium text-gray-500', [
                text('Provider Selection'),
              ]),
            ]),
          ]),
        ],
      ),

      // Page title
      h1(classes: 'text-3xl font-bold text-gray-900 mt-4', [
        text('Embedding Provider Selection'),
      ]),
      p(classes: 'mt-2 text-gray-600', [
        text(
          'Choose and configure your embedding model provider to generate embeddings.',
        ),
      ]),
    ]);
  }

  Component _buildErrorMessage() {
    return div(classes: 'mb-6 bg-red-50 border border-red-200 rounded-md p-4', [
      div(classes: 'flex', [
        div(classes: 'flex-shrink-0', [
          svg(
            classes: 'h-5 w-5 text-red-400',
            attributes: {'fill': 'currentColor', 'viewBox': '0 0 20 20'},
            [
              path(
                attributes: {
                  'fill-rule': 'evenodd',
                  'd':
                      'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z',
                  'clip-rule': 'evenodd',
                },
                [],
              ),
            ],
          ),
        ]),
        div(classes: 'ml-3', [
          h3(classes: 'text-sm font-medium text-red-800', [
            text('Provider Configuration Error'),
          ]),
          div(classes: 'mt-2 text-sm text-red-700', [
            p([text(_errorMessage!)]),
          ]),
          div(classes: 'mt-4', [
            button(
              classes:
                  'bg-red-100 px-2 py-1 text-sm font-medium text-red-800 rounded-md hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2',
              events: {'click': (_) => setState(() => _errorMessage = null)},
              [text('Dismiss')],
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildSuccessMessage() {
    return div(classes: 'mb-6 bg-green-50 border border-green-200 rounded-md p-4', [
      div(classes: 'flex', [
        div(classes: 'flex-shrink-0', [
          svg(
            classes: 'h-5 w-5 text-green-400',
            attributes: {'fill': 'currentColor', 'viewBox': '0 0 20 20'},
            [
              path(
                attributes: {
                  'fill-rule': 'evenodd',
                  'd':
                      'M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z',
                  'clip-rule': 'evenodd',
                },
                [],
              ),
            ],
          ),
        ]),
        div(classes: 'ml-3', [
          h3(classes: 'text-sm font-medium text-green-800', [
            text('Provider Configured'),
          ]),
          div(classes: 'mt-2 text-sm text-green-700', [
            p([
              text(
                'Successfully configured "${_selectedProvider!.displayName}" provider.',
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildNextSteps() {
    return div(classes: 'mt-8 bg-white rounded-lg shadow-sm border border-gray-200 p-6', [
      h2(classes: 'text-xl font-semibold text-gray-900 mb-4', [
        text('Next Steps'),
      ]),
      div(classes: 'space-y-4', [
        div(classes: 'flex items-start space-x-3', [
          div(
            classes:
                'flex-shrink-0 w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center',
            [
              span(classes: 'text-sm font-medium text-blue-600', [text('1')]),
            ],
          ),
          div(classes: 'flex-1', [
            h3(classes: 'text-sm font-medium text-gray-900', [
              text('Generate Embeddings'),
            ]),
            p(classes: 'text-sm text-gray-500 mt-1', [
              text('Process your data through the selected embedding model.'),
            ]),
          ]),
        ]),
        div(classes: 'flex items-start space-x-3', [
          div(
            classes:
                'flex-shrink-0 w-6 h-6 bg-gray-100 rounded-full flex items-center justify-center',
            [
              span(classes: 'text-sm font-medium text-gray-400', [text('2')]),
            ],
          ),
          div(classes: 'flex-1', [
            h3(classes: 'text-sm font-medium text-gray-500', [
              text('Similarity Search'),
            ]),
            p(classes: 'text-sm text-gray-400 mt-1', [
              text(
                'Query and compare embeddings with vector similarity search.',
              ),
            ]),
          ]),
        ]),
      ]),
      div(classes: 'mt-6 pt-4 border-t border-gray-200 flex justify-between', [
        // Back button
        a(
          href: '/transformation',
          classes: [
            'inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700',
            'bg-white border border-gray-300 rounded-md hover:bg-gray-50',
            'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2',
          ].join(' '),
          [
            svg(
              classes: 'mr-2 h-4 w-4',
              attributes: {
                'fill': 'none',
                'viewBox': '0 0 24 24',
                'stroke': 'currentColor',
              },
              [
                path(
                  attributes: {
                    'stroke-linecap': 'round',
                    'stroke-linejoin': 'round',
                    'stroke-width': '2',
                    'd': 'M10 19l-7-7m0 0l7-7m-7 7h18',
                  },
                  [],
                ),
              ],
            ),
            text('Back to Transformation'),
          ],
        ),

        // Continue button
        button(
          classes: [
            'inline-flex items-center px-4 py-2 text-sm font-medium text-white',
            'bg-blue-600 hover:bg-blue-700 rounded-md transition-colors duration-200',
            'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2',
          ].join(' '),
          events: {'click': (_) => _startEmbeddingGeneration()},
          [
            text('Start Embedding Generation'),
            svg(
              classes: 'ml-2 h-4 w-4',
              attributes: {
                'fill': 'none',
                'viewBox': '0 0 24 24',
                'stroke': 'currentColor',
              },
              [
                path(
                  attributes: {
                    'stroke-linecap': 'round',
                    'stroke-linejoin': 'round',
                    'stroke-width': '2',
                    'd': 'M14 5l7 7m0 0l-7 7m7-7H3',
                  },
                  [],
                ),
              ],
            ),
          ],
        ),
      ]),

      // Progress indicator
      div(classes: 'mt-6 pt-4 border-t border-gray-200', [
        div(classes: 'flex items-center justify-between text-sm', [
          span(classes: 'text-gray-500', [text('Step 3 of 4')]),
          div(classes: 'flex space-x-2', [
            div(classes: 'w-8 h-2 bg-blue-600 rounded-full', []),
            div(classes: 'w-8 h-2 bg-blue-600 rounded-full', []),
            div(classes: 'w-8 h-2 bg-blue-600 rounded-full', []),
            div(classes: 'w-8 h-2 bg-gray-200 rounded-full', []),
          ]),
        ]),
      ]),
    ]);
  }

  void _startEmbeddingGeneration() {
    // TODO: Navigate to results page and start embedding generation
    print(
      'Starting embedding generation with provider: ${_selectedProvider!.displayName}',
    );
    print('Provider config: $_providerConfig');
  }
}
