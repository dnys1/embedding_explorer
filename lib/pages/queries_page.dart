import 'package:jaspr/jaspr.dart';

class QueriesPage extends StatelessComponent {
  const QueriesPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'h-full bg-neutral-50 flex flex-col', [
      // Page header
      div(classes: 'bg-white border-b border-neutral-200 px-6 py-4', [
        h1(classes: 'text-2xl font-bold text-neutral-900', [
          text('Queries & Jobs'),
        ]),
        p(classes: 'mt-1 text-sm text-neutral-600', [
          text(
            'Create and manage embedding jobs by combining data sources, templates, and model providers',
          ),
        ]),
      ]),

      // Main content area
      div(classes: 'flex-1 overflow-y-auto px-6 py-6', [
        div(classes: 'max-w-5xl', [
          // Coming soon placeholder
          div(classes: 'text-center py-12', [
            div(classes: 'text-4xl mb-4', [text('🚧')]),
            h2(classes: 'text-xl font-semibold text-neutral-900 mb-2', [
              text('Coming Soon'),
            ]),
            p(classes: 'text-neutral-600 max-w-md mx-auto', [
              text(
                'The job management interface is under construction. This will allow you to create embedding jobs by combining your configured data sources, templates, and model providers.',
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}
