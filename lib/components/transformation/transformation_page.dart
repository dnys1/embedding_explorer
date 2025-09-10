import 'package:embeddings_explorer/components/transformation/transformation_model.dart';
import 'package:jaspr/jaspr.dart';

import '../../models/data_sources/data_source.dart';
import 'transformation_editor.dart';

class TransformationPage extends StatefulComponent {
  TransformationPage({super.key, required DataSource? dataSource})
    : model = TransformationModel(dataSource: dataSource);

  final TransformationModel model;

  @override
  State<TransformationPage> createState() => _TransformationPageState();
}

class _TransformationPageState extends State<TransformationPage> {
  TransformationModel get model => component.model;

  @override
  void initState() {
    super.initState();
    context.binding.addPostFrameCallback(() {
      model.init();
    });
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'h-full bg-neutral-50 flex flex-col', [
      // Page header
      div(classes: 'bg-white border-b border-neutral-200 px-6 py-4', [
        h1(classes: 'text-2xl font-bold text-neutral-900', [
          text('Embedding Templates'),
        ]),
        p(classes: 'mt-1 text-sm text-neutral-600', [
          text('Create templates to transform your data for embedding models'),
        ]),
      ]),

      // Main content area
      div(classes: 'flex-1 overflow-hidden', [
        // Main content
        _buildTransformationContent(),
      ]),
    ]);
  }

  Component _buildTransformationContent() {
    return div(classes: 'h-full overflow-y-auto px-6 py-6', [
      div(classes: 'max-w-6xl space-y-6', [
        // Data source info card
        _buildDataSourceInfo(),

        // Error message if any
        ListenableBuilder(
          listenable: model,
          builder: (_) {
            if (model.error case final error?) {
              return _buildErrorMessage(error);
            }
            return div([]);
          },
        ),

        // Transformation editor
        _buildTransformationEditor(),

        // Action buttons
        _buildActionButtons(),
      ]),
    ]);
  }

  Component _buildDataSourceInfo() {
    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-neutral-200 p-6',
      [
        div(classes: 'flex items-center justify-between', [
          div([
            h2(classes: 'text-lg font-semibold text-neutral-900', [
              text('Connected Data Source'),
            ]),
            p(classes: 'text-sm text-neutral-500 mt-1', [
              text(
                '${model.dataSource.name} (${model.dataSource.type.toUpperCase()})',
              ),
            ]),
          ]),
          div(classes: 'flex items-center space-x-2', [
            div(classes: 'h-2 w-2 bg-green-400 rounded-full', []),
            span(classes: 'text-sm text-green-600 font-medium', [
              text('Connected'),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildErrorMessage(String error) {
    return div(classes: 'bg-red-50 border border-red-200 rounded-md p-4', [
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
            text('Transformation Error'),
          ]),
          div(classes: 'mt-2 text-sm text-red-700', [
            p([text(error)]),
          ]),
          div(classes: 'mt-4', [
            button(
              classes:
                  'bg-red-100 px-2 py-1 text-sm font-medium text-red-800 rounded-md hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2',
              events: {'click': (_) => model.dismissError()},
              [text('Dismiss')],
            ),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildTransformationEditor() {
    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-neutral-200',
      [
        div(classes: 'px-6 py-4 border-b border-neutral-200', [
          h2(classes: 'text-lg font-semibold text-neutral-900', [
            text('Transformation Configuration'),
          ]),
          p(classes: 'text-sm text-neutral-500 mt-1', [
            text(
              'Define how your data should be transformed before embedding generation.',
            ),
          ]),
        ]),
        div(classes: 'p-6', [TransformationEditor(model: model)]),
      ],
    );
  }

  Component _buildActionButtons() {
    return ValueListenableBuilder(
      listenable: model.template,
      builder: (context, template) {
        final hasValidTemplate = template.validate();
        return div(classes: 'bg-white rounded-lg shadow-sm border border-neutral-200 p-6', [
          div(classes: 'flex items-center justify-between', [
            // Back button
            a(
              href: '/data-source',
              classes: [
                'inline-flex items-center px-4 py-2 text-sm font-medium text-neutral-700',
                'bg-white border border-neutral-300 rounded-md hover:bg-neutral-50',
                'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
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
                text('Back to Data Source'),
              ],
            ),

            // Continue button
            a(
              href: hasValidTemplate ? '/provider-selection' : '',
              classes: [
                'inline-flex items-center px-4 py-2 text-sm font-medium rounded-md',
                'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
                if (hasValidTemplate)
                  'text-white bg-primary-600 hover:bg-primary-700'
                else
                  'text-neutral-400 bg-neutral-200 cursor-not-allowed pointer-events-none',
              ].join(' '),
              [
                text('Continue to Provider Selection'),
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
          div(classes: 'mt-6 pt-4 border-t border-neutral-200', [
            div(classes: 'flex items-center justify-between text-sm', [
              span(classes: 'text-neutral-500', [text('Step 2 of 4')]),
              div(classes: 'flex space-x-2', [
                div(classes: 'w-8 h-2 bg-primary-600 rounded-full', []),
                div(classes: 'w-8 h-2 bg-primary-600 rounded-full', []),
                div(classes: 'w-8 h-2 bg-neutral-200 rounded-full', []),
                div(classes: 'w-8 h-2 bg-neutral-200 rounded-full', []),
              ]),
            ]),
          ]),
        ]);
      },
    );
  }
}
