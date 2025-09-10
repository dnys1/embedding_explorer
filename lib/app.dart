import 'package:embeddings_explorer/pages/editor_test_page.dart';
import 'package:embeddings_explorer/pages/embedding_templates_page.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/sidebar.dart';
import 'models/configuration_manager.dart';
import 'pages/configuration_dashboard.dart';
import 'pages/data_sources_page.dart';
import 'pages/home.dart';
import 'pages/jobs_page.dart';
import 'pages/provider_selection_page.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isSidebarOpen = false;
  bool _isLoading = true;
  final ConfigurationManager _configManager = ConfigurationManager();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _configManager.initialize();
    } catch (e) {
      print('Error initializing configuration manager: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Component build(BuildContext context) {
    if (_isLoading) {
      return section(classes: 'h-screen flex items-center justify-center', [
        div(classes: 'text-center', [
          div(
            classes:
                'animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4',
            [],
          ),
          p(classes: 'text-neutral-600', [text('Loading configurations...')]),
        ]),
      ]);
    }

    return section(classes: 'h-screen flex', [
      Router(
        routes: [
          ShellRoute(
            builder: (context, state, child) => _buildLayout(child),
            routes: [
              Route(
                path: '/',
                title: 'Home',
                builder: (context, state) => const Home(),
              ),
              Route(
                path: '/dashboard',
                title: 'Configuration Dashboard',
                builder: (context, state) => const ConfigurationDashboard(),
              ),
              Route(
                path: '/data-sources',
                title: 'Data Sources',
                builder: (context, state) => const DataSourcesPage(),
              ),
              Route(
                path: '/embedding-templates',
                title: 'Embedding Templates',
                builder: (context, state) => const EmbeddingTemplatesPage(),
              ),
              Route(
                path: '/model-providers',
                title: 'Model Providers',
                builder: (context, state) => const ProviderSelectionPage(),
              ),
              Route(
                path: '/jobs',
                title: 'Jobs & Queries',
                builder: (context, state) => const JobsPage(),
              ),
              if (kDebugMode) ...[
                Route(
                  path: '/editor-test',
                  title: 'Editor Test',
                  builder: (context, state) => const EditorTestPage(),
                ),
              ],
            ],
          ),
        ],
      ),
    ]);
  }

  Component _buildLayout(Component child) {
    return div(classes: 'relative flex w-full h-full', [
      // Responsive Sidebar
      Sidebar(
        isOpen: _isSidebarOpen,
        onClose: () => setState(() => _isSidebarOpen = false),
      ),

      // Main content area with responsive margin
      div(
        classes: [
          'flex-1 flex flex-col overflow-hidden',
          'lg:ml-64', // Add left margin on large screens to account for sidebar
        ].join(' '),
        [
          // Mobile header with menu button
          div(
            classes: 'lg:hidden bg-white border-b border-neutral-200 px-4 py-3',
            [
              div(classes: 'flex items-center justify-between', [
                button(
                  classes:
                      'p-2 rounded-md text-neutral-600 hover:text-neutral-900 hover:bg-neutral-100',
                  events: {
                    'click': (_) =>
                        setState(() => _isSidebarOpen = !_isSidebarOpen),
                  },
                  [
                    svg(
                      classes: 'w-6 h-6',
                      attributes: {
                        'fill': 'none',
                        'stroke': 'currentColor',
                        'viewBox': '0 0 24 24',
                      },
                      [
                        path(
                          attributes: {
                            'stroke-linecap': 'round',
                            'stroke-linejoin': 'round',
                            'stroke-width': '2',
                            'd': 'M4 6h16M4 12h16M4 18h16',
                          },
                          [],
                        ),
                      ],
                    ),
                  ],
                ),
                h1(classes: 'text-lg font-semibold text-neutral-900', [
                  text('Embeddings Explorer'),
                ]),
                div(classes: 'w-10', []), // Spacer for centering
              ]),
            ],
          ),

          // Page content
          child,
        ],
      ),
    ]);
  }
}
