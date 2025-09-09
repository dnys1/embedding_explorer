import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../models/embedding_provider.dart';
import '../services/providers/custom_http_provider.dart';
import '../services/providers/gemini_provider.dart';
import '../services/providers/openai_provider.dart';

/// Component for selecting and configuring embedding providers
class ProviderSelector extends StatefulComponent {
  final void Function(EmbeddingProvider provider, Map<String, dynamic> config)?
  onProviderSelected;
  final void Function(String message)? onError;

  const ProviderSelector({this.onProviderSelected, this.onError, super.key});

  @override
  State<ProviderSelector> createState() => _ProviderSelectorState();
}

class _ProviderSelectorState extends State<ProviderSelector> {
  late final List<EmbeddingProvider> _availableProviders;
  EmbeddingProvider? _selectedProvider;
  EmbeddingModel? _selectedModel;
  Map<String, dynamic> _config = {};
  bool _isValidating = false;
  ValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _availableProviders = [
      OpenAIProvider(),
      GeminiProvider(),
      CustomHttpProvider(),
    ];
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'max-w-4xl mx-auto p-6 space-y-6', [
      _buildHeader(),
      _buildProviderSelection(),
      if (_selectedProvider != null) _buildModelSelection(),
      if (_selectedProvider != null) _buildConfiguration(),
      if (_validationResult != null) _buildValidationResults(),
      if (_selectedProvider != null && _selectedModel != null)
        _buildActionButtons(),
    ]);
  }

  Component _buildHeader() {
    return div(classes: 'text-center', [
      h1(classes: 'text-3xl font-bold text-gray-900 mb-2', [
        text('Embedding Provider Configuration'),
      ]),
      p(classes: 'text-lg text-gray-600', [
        text('Select and configure your embedding model provider'),
      ]),
    ]);
  }

  Component _buildProviderSelection() {
    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-gray-200 p-6',
      [
        h2(classes: 'text-xl font-semibold text-gray-900 mb-4', [
          text('Choose Provider'),
        ]),
        div(classes: 'grid grid-cols-1 md:grid-cols-3 gap-4', [
          for (final provider in _availableProviders)
            _buildProviderCard(provider),
        ]),
      ],
    );
  }

  Component _buildProviderCard(EmbeddingProvider provider) {
    final isSelected = _selectedProvider?.id == provider.id;

    return div(
      classes: [
        'relative rounded-lg border-2 p-4 cursor-pointer transition-all duration-200',
        if (isSelected)
          'border-blue-500 bg-blue-50'
        else
          'border-gray-200 hover:border-gray-300 hover:bg-gray-50',
      ].join(' '),
      events: {'click': (_) => _selectProvider(provider)},
      [
        div(classes: 'text-center', [
          h3(
            classes: [
              'text-lg font-medium mb-2',
              if (isSelected) 'text-blue-900' else 'text-gray-900',
            ].join(' '),
            [text(provider.displayName)],
          ),
          p(
            classes: [
              'text-sm mb-3',
              if (isSelected) 'text-blue-700' else 'text-gray-500',
            ].join(' '),
            [text(provider.description)],
          ),
          div(classes: 'flex flex-wrap gap-1 justify-center', [
            if (provider.requiresApiKey)
              span(
                classes:
                    'px-2 py-1 text-xs bg-yellow-100 text-yellow-800 rounded',
                [text('API Key Required')],
              ),
            if (provider.supportsCustomConfig)
              span(
                classes:
                    'px-2 py-1 text-xs bg-green-100 text-green-800 rounded',
                [text('Customizable')],
              ),
          ]),
        ]),
        if (isSelected)
          div(classes: 'absolute top-2 right-2', [
            div(
              classes:
                  'w-4 h-4 bg-blue-500 rounded-full flex items-center justify-center',
              [
                svg(
                  classes: 'w-2 h-2 text-white',
                  attributes: {'fill': 'currentColor', 'viewBox': '0 0 8 8'},
                  [
                    path(
                      attributes: {
                        'd':
                            'M6.564.75l-3.59 3.612-1.538-1.55L0 4.26l2.974 2.99L8 2.193z',
                      },
                      [],
                    ),
                  ],
                ),
              ],
            ),
          ]),
      ],
    );
  }

  Component _buildModelSelection() {
    if (_selectedProvider == null) return fragment([]);

    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-gray-200 p-6',
      [
        h2(classes: 'text-xl font-semibold text-gray-900 mb-4', [
          text('Select Model'),
        ]),
        div(classes: 'space-y-3', [
          for (final model in _selectedProvider!.availableModels)
            _buildModelOption(model),
        ]),
      ],
    );
  }

  Component _buildModelOption(EmbeddingModel model) {
    final isSelected = _selectedModel?.id == model.id;

    return div(
      classes: [
        'border rounded-lg p-4 cursor-pointer transition-all duration-200',
        if (isSelected)
          'border-blue-500 bg-blue-50'
        else
          'border-gray-200 hover:border-gray-300',
      ].join(' '),
      events: {'click': (_) => _selectModel(model)},
      [
        div(classes: 'flex items-start justify-between', [
          div(classes: 'flex-1', [
            h3(
              classes: [
                'font-medium',
                if (isSelected) 'text-blue-900' else 'text-gray-900',
              ].join(' '),
              [text(model.name)],
            ),
            p(
              classes: [
                'text-sm mt-1',
                if (isSelected) 'text-blue-700' else 'text-gray-500',
              ].join(' '),
              [text(model.description)],
            ),
            div(classes: 'flex gap-4 mt-2 text-xs text-gray-500', [
              span([text('Dimensions: ${model.dimensions}')]),
              span([text('Max tokens: ${model.maxInputTokens}')]),
              if (model.costPer1kTokens > 0)
                span([
                  text(
                    'Cost: \$${model.costPer1kTokens.toStringAsFixed(6)}/1k tokens',
                  ),
                ]),
            ]),
          ]),
          if (isSelected)
            div(classes: 'ml-4', [
              div(
                classes:
                    'w-4 h-4 bg-blue-500 rounded-full flex items-center justify-center',
                [
                  svg(
                    classes: 'w-2 h-2 text-white',
                    attributes: {'fill': 'currentColor', 'viewBox': '0 0 8 8'},
                    [
                      path(
                        attributes: {
                          'd':
                              'M6.564.75l-3.59 3.612-1.538-1.55L0 4.26l2.974 2.99L8 2.193z',
                        },
                        [],
                      ),
                    ],
                  ),
                ],
              ),
            ]),
        ]),
      ],
    );
  }

  Component _buildConfiguration() {
    if (_selectedProvider == null) return fragment([]);

    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-gray-200 p-6',
      [
        h2(classes: 'text-xl font-semibold text-gray-900 mb-4', [
          text('Configuration'),
        ]),
        div(classes: 'space-y-4', [
          if (_selectedProvider!.requiresApiKey) _buildApiKeyInput(),
          if (_selectedProvider!.supportsCustomConfig) _buildCustomConfig(),
        ]),
      ],
    );
  }

  Component _buildApiKeyInput() {
    return div(classes: 'space-y-2', [
      label(
        classes: 'block text-sm font-medium text-gray-700',
        attributes: {'for': 'api-key'},
        [text('API Key')],
      ),
      input(
        id: 'api-key',
        type: InputType.password,
        classes:
            'block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500',
        attributes: {
          'placeholder': 'Enter your ${_selectedProvider!.displayName} API key',
          'value': _config['apiKey'] as String? ?? '',
        },
        events: {
          'input': (event) {
            final target = event.target as web.HTMLElement;
            _updateConfig('apiKey', (target as web.HTMLInputElement).value);
          },
        },
      ),
      p(classes: 'text-xs text-gray-500', [
        text('Your API key is stored locally and never sent to our servers.'),
      ]),
    ]);
  }

  Component _buildCustomConfig() {
    if (_selectedProvider!.id != 'custom-http') return fragment([]);

    return div(classes: 'space-y-4', [
      // Endpoint URL
      div(classes: 'space-y-2', [
        label(
          classes: 'block text-sm font-medium text-gray-700',
          attributes: {'for': 'endpoint'},
          [text('Endpoint URL')],
        ),
        input(
          id: 'endpoint',
          type: InputType.url,
          classes:
              'block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500',
          attributes: {
            'placeholder': 'https://api.example.com/embeddings',
            'value': _config['endpoint'] as String? ?? '',
          },
          events: {
            'input': (event) {
              final target = event.target as web.HTMLElement;
              _updateConfig('endpoint', (target as web.HTMLInputElement).value);
            },
          },
        ),
      ]),

      // HTTP Method
      div(classes: 'space-y-2', [
        label(classes: 'block text-sm font-medium text-gray-700', [
          text('HTTP Method'),
        ]),
        select(
          classes:
              'block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500',
          events: {
            'change': (event) {
              final target = event.target as web.HTMLElement;
              _updateConfig('method', (target as web.HTMLSelectElement).value);
            },
          },
          [
            option(
              attributes: {
                'value': 'POST',
                if ((_config['method'] as String? ?? 'POST') == 'POST')
                  'selected': 'true',
              },
              [text('POST')],
            ),
            option(
              attributes: {
                'value': 'PUT',
                if ((_config['method'] as String? ?? 'POST') == 'PUT')
                  'selected': 'true',
              },
              [text('PUT')],
            ),
          ],
        ),
      ]),

      // Request Template
      div(classes: 'space-y-2', [
        label(classes: 'block text-sm font-medium text-gray-700', [
          text('Request Template'),
        ]),
        p(classes: 'text-xs text-gray-500 mb-2', [
          text(
            'Use {{input}} as a placeholder for the text to embed. JSON format expected.',
          ),
        ]),
        // TODO: Replace with Monaco Editor when available
        textarea(
          classes:
              'block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500',
          attributes: {
            'rows': '8',
            'placeholder': _getDefaultRequestTemplate(),
          },
          events: {
            'input': (event) {
              final target = event.target as web.HTMLElement;
              _updateConfig(
                'requestTemplate',
                (target as web.HTMLTextAreaElement).value,
              );
            },
          },
          [
            text(
              _config['requestTemplate'] as String? ??
                  _getDefaultRequestTemplate(),
            ),
          ],
        ),
      ]),

      // Response Path
      div(classes: 'space-y-2', [
        label(
          classes: 'block text-sm font-medium text-gray-700',
          attributes: {'for': 'response-path'},
          [text('Response Path')],
        ),
        input(
          id: 'response-path',
          type: InputType.text,
          classes:
              'block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500',
          attributes: {
            'placeholder': 'data.embedding (JSONPath to the embedding array)',
            'value': _config['responsePath'] as String? ?? 'data.embedding',
          },
          events: {
            'input': (event) {
              final target = event.target as web.HTMLElement;
              _updateConfig(
                'responsePath',
                (target as web.HTMLInputElement).value,
              );
            },
          },
        ),
        p(classes: 'text-xs text-gray-500', [
          text('JSONPath to extract the embedding vector from the response.'),
        ]),
      ]),
    ]);
  }

  Component _buildValidationResults() {
    final result = _validationResult!;

    return div(classes: 'bg-white rounded-lg shadow-sm border border-gray-200 p-6', [
      h3(classes: 'text-lg font-semibold text-gray-900 mb-3', [
        text('Configuration Validation'),
      ]),
      if (result.isValid)
        div(classes: 'flex items-center space-x-2 text-green-600', [
          svg(
            classes: 'w-5 h-5',
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
          span(classes: 'font-medium', [text('Configuration is valid')]),
        ])
      else
        div(classes: 'space-y-2', [
          for (final error in result.errors)
            div(classes: 'flex items-start space-x-2 text-red-600', [
              svg(
                classes: 'w-5 h-5 mt-0.5 flex-shrink-0',
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
              span([text(error)]),
            ]),
        ]),
      if (result.warnings.isNotEmpty)
        div(classes: 'mt-3 space-y-2', [
          for (final warning in result.warnings)
            div(classes: 'flex items-start space-x-2 text-yellow-600', [
              svg(
                classes: 'w-5 h-5 mt-0.5 flex-shrink-0',
                attributes: {'fill': 'currentColor', 'viewBox': '0 0 20 20'},
                [
                  path(
                    attributes: {
                      'fill-rule': 'evenodd',
                      'd':
                          'M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z',
                      'clip-rule': 'evenodd',
                    },
                    [],
                  ),
                ],
              ),
              span([text(warning)]),
            ]),
        ]),
    ]);
  }

  Component _buildActionButtons() {
    final canProceed = _validationResult?.isValid ?? false;

    return div(classes: 'flex justify-between', [
      button(
        classes:
            'px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500',
        events: {'click': (_) => _validateConfiguration()},
        [
          if (_isValidating)
            span(classes: 'inline-flex items-center', [
              svg(
                classes: 'animate-spin -ml-1 mr-2 h-4 w-4',
                attributes: {'fill': 'none', 'viewBox': '0 0 24 24'},
                [
                  circle(
                    attributes: {
                      'cx': '12',
                      'cy': '12',
                      'r': '10',
                      'stroke': 'currentColor',
                      'stroke-width': '4',
                      'opacity': '0.25',
                    },
                    [],
                  ),
                  path(
                    attributes: {
                      'fill': 'currentColor',
                      'd':
                          'M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z',
                      'opacity': '0.75',
                    },
                    [],
                  ),
                ],
              ),
              text('Validating...'),
            ])
          else
            text('Validate Configuration'),
        ],
      ),
      button(
        classes: [
          'px-4 py-2 text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2',
          if (canProceed)
            'text-white bg-blue-600 hover:bg-blue-700 focus:ring-blue-500'
          else
            'text-gray-400 bg-gray-200 cursor-not-allowed',
        ].join(' '),
        attributes: canProceed ? {} : {'disabled': 'true'},
        events: canProceed ? {'click': (_) => _proceedWithProvider()} : {},
        [text('Use This Provider')],
      ),
    ]);
  }

  void _selectProvider(EmbeddingProvider provider) {
    setState(() {
      _selectedProvider = provider;
      _selectedModel = null;
      _config = {};
      _validationResult = null;
    });
  }

  void _selectModel(EmbeddingModel model) {
    setState(() {
      _selectedModel = model;
      _config = {..._config, 'model': model.id};
    });
  }

  void _updateConfig(String key, String value) {
    setState(() {
      _config = {..._config, key: value};
      _validationResult = null; // Clear validation when config changes
    });
  }

  void _validateConfiguration() {
    if (_selectedProvider == null) return;

    setState(() {
      _isValidating = true;
    });

    // Simulate async validation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final result = _selectedProvider!.validateConfig(_config);
        setState(() {
          _validationResult = result;
          _isValidating = false;
        });
      }
    });
  }

  void _proceedWithProvider() {
    if (_selectedProvider != null && _validationResult?.isValid == true) {
      component.onProviderSelected?.call(_selectedProvider!, _config);
    }
  }

  String _getDefaultRequestTemplate() {
    return '''
{
  "input": "{{input}}",
  "model": "${_selectedModel?.id ?? 'your-model'}"
}''';
  }
}
