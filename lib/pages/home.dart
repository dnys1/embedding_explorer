import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/counter.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'flex flex-1 flex-col justify-center items-center', [
      img(src: 'images/logo.svg', width: 80),
      h1([text('Embedding Model Explorer')]),
      p([
        text('Evaluate and compare different embedding models with your data.'),
      ]),
      div(styles: Styles(height: 50.px), []),
      div(classes: 'space-y-4 text-center', [
        p(classes: 'text-gray-600 max-w-lg', [
          text(
            'Get started by configuring a data source. You can upload CSV files or connect to SQLite databases to begin exploring embedding models.',
          ),
        ]),
        Link(
          to: '/data-source',
          child: button(
            classes:
                'bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md transition-colors duration-200',
            [text('Configure Data Source →')],
          ),
        ),
      ]),
      div(styles: Styles(height: 50.px), []),
      const Counter(),
    ]);
  }
}
