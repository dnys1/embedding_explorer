import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'common/ui/button.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  Component _buildStep({
    required String number,
    required String title,
    required String description,
    required String linkText,
    required String linkPath,
  }) {
    return div(classes: 'text-center', [
      // Step number circle
      div(
        classes:
            'w-12 h-12 bg-primary-600 text-white rounded-full flex items-center justify-center text-lg font-bold mx-auto mb-4',
        [text(number)],
      ),
      // Step title
      h3(classes: 'text-lg font-semibold text-neutral-900 mb-3', [text(title)]),
      // Step description
      p(classes: 'text-neutral-600 text-sm mb-4 leading-relaxed', [
        text(description),
      ]),
      // Step link
      Link(
        to: linkPath,
        styles: Styles(cursor: Cursor.pointer),
        child: span(
          classes:
              'text-primary-600 hover:text-primary-700 font-medium text-sm transition-colors duration-200',
          [text(linkText)],
        ),
      ),
    ]);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-1 flex-col overflow-y-auto', [
      // Hero Section
      section(classes: 'text-center py-8 px-6', [
        img(src: 'images/logo.png', width: 80, classes: 'mx-auto mb-6'),
        h1(classes: 'text-4xl font-bold text-neutral-900 mb-4', [
          text('Embedding Model Explorer'),
        ]),
        p(classes: 'text-xl text-neutral-600 mb-8 max-w-2xl mx-auto', [
          text(
            'Evaluate and compare different embedding models with your data. ',
          ),
          text(
            'Test multiple providers, analyze performance, and find the best model for your use case.',
          ),
        ]),

        // Quick Start Button
        Link(
          to: '/data-sources',
          child: Button(size: ButtonSize.lg, children: [text('Get Started →')]),
        ),
      ]),

      // How It Works Section
      section(classes: 'py-16 px-6 bg-neutral-50', [
        div(classes: 'max-w-4xl mx-auto', [
          h2(classes: 'text-3xl font-bold text-center text-neutral-900 mb-12', [
            text('How It Works'),
          ]),

          // Steps
          div(classes: 'grid md:grid-cols-2 lg:grid-cols-4 gap-8', [
            _buildStep(
              number: '1',
              title: 'Connect Data Sources',
              description:
                  'Upload CSV files, connect SQLite databases, or choose from sample datasets to get started.',
              linkText: 'Configure Sources',
              linkPath: '/data-sources',
            ),
            _buildStep(
              number: '2',
              title: 'Craft Templates',
              description:
                  'Create embedding templates that structure your data for optimal input to embedding models.',
              linkText: 'Build Templates',
              linkPath: '/templates',
            ),
            _buildStep(
              number: '3',
              title: 'Choose Providers',
              description:
                  'Select from multiple embedding providers and models to test with your data.',
              linkText: 'Setup Providers',
              linkPath: '/providers',
            ),
            _buildStep(
              number: '4',
              title: 'Run & Compare',
              description:
                  'Execute embedding jobs, perform queries, and compare results across different models.',
              linkText: 'Start Jobs',
              linkPath: '/jobs',
            ),
          ]),
        ]),
      ]),

      // Quick Actions Section
      section(classes: 'py-16 px-6', [
        div(classes: 'max-w-2xl mx-auto text-center', [
          h2(classes: 'text-2xl font-bold text-neutral-900 mb-8', [
            text('Quick Actions'),
          ]),
          div(classes: 'flex flex-col sm:flex-row gap-4 justify-center', [
            Link(
              to: '/data-sources',
              child: button(
                classes:
                    'bg-primary-600 hover:bg-primary-700 text-white font-medium py-3 px-6 rounded-md transition-colors duration-200',
                [text('Configure Data Sources')],
              ),
            ),
            Link(
              to: '/dashboard',
              child: button(
                classes:
                    'border border-neutral-300 hover:bg-neutral-50 text-neutral-700 font-medium py-3 px-6 rounded-md transition-colors duration-200',
                [text('View Dashboard')],
              ),
            ),
          ]),
        ]),
      ]),
    ]);
  }
}
