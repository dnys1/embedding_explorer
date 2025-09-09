import 'package:embeddings_explorer/models/data_source.dart';
import 'package:embeddings_explorer/pages/editor_test_page.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/transformation/transformation_page.dart';
import 'pages/about.dart';
import 'pages/data_source_page.dart';
import 'pages/home.dart';
import 'pages/provider_selection_page.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'h-screen flex flex-col flex-wrap', [
      Router(
        routes: [
          ShellRoute(
            builder: (context, state, child) => child,
            // fragment([const Header(), child]),
            routes: [
              Route(
                path: '/',
                title: 'Home',
                builder: (context, state) => const Home(),
              ),
              Route(
                path: '/data-source',
                title: 'Data Source',
                builder: (context, state) => const DataSourcePage(),
              ),
              Route(
                path: '/transformation',
                title: 'Data Transformation',
                builder: (context, state) =>
                    TransformationPage(dataSource: state.extra as DataSource?),
              ),
              Route(
                path: '/provider-selection',
                title: 'Provider Selection',
                builder: (context, state) => const ProviderSelectionPage(),
              ),
              Route(
                path: '/about',
                title: 'About',
                builder: (context, state) => const About(),
              ),
              Route(
                path: '/editor-test',
                title: 'Editor Test',
                builder: (context, state) => const EditorTestPage(),
              ),
            ],
          ),
        ],
      ),
    ]);
  }
}
