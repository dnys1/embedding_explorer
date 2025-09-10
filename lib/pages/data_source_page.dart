import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/data_source_selector.dart';
import '../models/data_sources/data_source.dart';

class DataSourcePage extends StatefulComponent {
  const DataSourcePage({super.key});

  @override
  State<DataSourcePage> createState() => _DataSourcePageState();
}

class _DataSourcePageState extends State<DataSourcePage> {
  DataSource? _selectedDataSource;
  String? _errorMessage;

  @override
  Component build(BuildContext context) {
    return div(classes: 'h-full bg-neutral-50 flex flex-col', [
      // Page header
      div(classes: 'bg-white border-b border-neutral-200 px-6 py-4', [
        h1(classes: 'text-2xl font-bold text-neutral-900', [
          text('Data Sources'),
        ]),
        p(classes: 'mt-1 text-sm text-neutral-600', [
          text(
            'Configure your data sources to begin exploring embedding models',
          ),
        ]),
      ]),

      // Main content area
      div(classes: 'flex-1 overflow-y-auto px-6 py-6', [
        div(classes: 'max-w-5xl', [
          // Error message if any
          if (_errorMessage != null)
            div(classes: 'mb-6 bg-red-50 border border-red-200 rounded-md p-4', [
              div(classes: 'flex', [
                div(classes: 'flex-shrink-0', [
                  svg(
                    classes: 'h-5 w-5 text-red-400',
                    attributes: {
                      'fill': 'currentColor',
                      'viewBox': '0 0 20 20',
                    },
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
                    text('Configuration Error'),
                  ]),
                  div(classes: 'mt-2 text-sm text-red-700', [
                    p([text(_errorMessage!)]),
                  ]),
                  div(classes: 'mt-4', [
                    button(
                      classes:
                          'bg-red-100 px-2 py-1 text-sm font-medium text-red-800 rounded-md hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2',
                      onClick: () => setState(() => _errorMessage = null),
                      [text('Dismiss')],
                    ),
                  ]),
                ]),
              ]),
            ]),

          // Success message if data source is selected
          if (_selectedDataSource != null)
            div(
              classes:
                  'mb-6 bg-green-50 border border-green-200 rounded-md p-4',
              [
                div(classes: 'flex', [
                  div(classes: 'flex-shrink-0', [
                    svg(
                      classes: 'h-5 w-5 text-green-400',
                      attributes: {
                        'fill': 'currentColor',
                        'viewBox': '0 0 20 20',
                      },
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
                      text('Data Source Connected'),
                    ]),
                    div(classes: 'mt-2 text-sm text-green-700', [
                      p([
                        text(
                          'Successfully connected to "${_selectedDataSource!.name}" ',
                        ),
                        span(classes: 'font-medium', [
                          text('(${_selectedDataSource!.type.toUpperCase()})'),
                        ]),
                      ]),
                    ]),
                  ]),
                ]),
              ],
            ),

          // Data source selector component
          DataSourceSelector(
            onDataSourceSelected: (dataSource) {
              setState(() {
                _selectedDataSource = dataSource;
                _errorMessage = null;
              });
            },
            onError: (message) {
              setState(() {
                _errorMessage = message;
              });
            },
            initialDataSource: _selectedDataSource,
          ),

          // Next steps section (if data source is selected)
          if (_selectedDataSource != null)
            div(
              classes:
                  'mt-8 bg-white rounded-lg shadow-sm border border-neutral-200 p-6',
              [
                h2(classes: 'text-xl font-semibold text-neutral-900 mb-4', [
                  text('Next Steps'),
                ]),
                div(classes: 'space-y-4', [
                  div(classes: 'flex items-start space-x-3', [
                    div(
                      classes:
                          'flex-shrink-0 w-6 h-6 bg-primary-100 rounded-full flex items-center justify-center',
                      [
                        span(classes: 'text-sm font-medium text-primary-600', [
                          text('1'),
                        ]),
                      ],
                    ),
                    div(classes: 'flex-1', [
                      h3(classes: 'text-sm font-medium text-neutral-900', [
                        text('Data Transformation'),
                      ]),
                      p(classes: 'text-sm text-neutral-500 mt-1', [
                        text(
                          'Configure how your data should be transformed for embedding generation.',
                        ),
                      ]),
                    ]),
                  ]),
                  div(classes: 'flex items-start space-x-3', [
                    div(
                      classes:
                          'flex-shrink-0 w-6 h-6 bg-neutral-100 rounded-full flex items-center justify-center',
                      [
                        span(classes: 'text-sm font-medium text-neutral-400', [
                          text('2'),
                        ]),
                      ],
                    ),
                    div(classes: 'flex-1', [
                      h3(classes: 'text-sm font-medium text-neutral-500', [
                        text('Embedding Model Selection'),
                      ]),
                      p(classes: 'text-sm text-neutral-400 mt-1', [
                        text(
                          'Choose embedding providers and configure API access.',
                        ),
                      ]),
                    ]),
                  ]),
                  div(classes: 'flex items-start space-x-3', [
                    div(
                      classes:
                          'flex-shrink-0 w-6 h-6 bg-neutral-100 rounded-full flex items-center justify-center',
                      [
                        span(classes: 'text-sm font-medium text-neutral-400', [
                          text('3'),
                        ]),
                      ],
                    ),
                    div(classes: 'flex-1', [
                      h3(classes: 'text-sm font-medium text-neutral-500', [
                        text('Results & Analysis'),
                      ]),
                      p(classes: 'text-sm text-neutral-400 mt-1', [
                        text(
                          'View and compare embedding results with similarity search.',
                        ),
                      ]),
                    ]),
                  ]),
                ]),
                div(classes: 'mt-6 pt-4 border-t border-neutral-200', [
                  a(
                    href: '#',
                    onClick: () {
                      Router.of(context).push(
                        '/embedding-templates',
                        extra: _selectedDataSource,
                      );
                    },
                    classes: [
                      'px-4 py-2 text-sm font-medium text-white rounded-md transition-colors duration-200',
                      'bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
                    ].join(' '),
                    [text('Continue to Embedding Templates →')],
                  ),
                ]),
              ],
            ),
        ]),
      ]),
    ]);
  }
}
