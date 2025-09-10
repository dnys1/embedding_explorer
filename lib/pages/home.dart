import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/counter.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'flex flex-1 flex-col justify-center items-center', [
      img(src: 'images/logo.png', width: 80),
      h1([text('Embedding Model Explorer')]),
      p([
        text('Evaluate and compare different embedding models with your data.'),
      ]),
      div(styles: Styles(height: 50.px), []),
      div(classes: 'space-y-4 text-center', [
        p(classes: 'text-neutral-600 max-w-lg', [
          text(
            'Get started by configuring a data source. You can upload CSV files or connect to SQLite databases to begin exploring embedding models.',
          ),
        ]),
        div(classes: 'flex flex-col sm:flex-row gap-4 justify-center', [
          Link(
            to: '/data-sources',
            child: button(
              classes:
                  'bg-primary-600 hover:bg-primary-700 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200',
              [text('Configure Data Sources →')],
            ),
          ),
          Link(
            to: '/dashboard',
            child: button(
              classes:
                  'bg-neutral-600 hover:bg-neutral-700 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200',
              [text('Configuration Dashboard')],
            ),
          ),
        ]),
      ]),
      div(styles: Styles(height: 50.px), []),
      const Counter(),
    ]);
  }
}
