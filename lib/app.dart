import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:logging/logging.dart';

import 'common/sidebar.dart';
import 'common/ui/button.dart';
import 'configurations/model/configuration_manager.dart';
import 'configurations/page/configuration_dashboard_page.dart';
import 'configurations/page/configuration_view_data_page.dart';
import 'data_sources/page/data_sources_page.dart';
import 'editor_test_page.dart';
import 'home_page.dart';
import 'jobs/page/job_results_page.dart';
import 'jobs/page/jobs_page.dart';
import 'providers/page/embedding_providers_page.dart';
import 'templates/page/embedding_templates_page.dart';

class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static final Logger _logger = Logger('App');
  bool _isSidebarOpen = false;
  bool _isLoading = true;
  final ConfigurationManager _configManager = ConfigurationManager.instance;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _configManager.initialize();
    } catch (e) {
      _logger.severe('Error initializing configuration manager', e);
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
          p(classes: 'text-neutral-600', [text('Loading...')]),
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
                builder: (context, state) => const HomePage(),
              ),
              Route(
                path: '/dashboard',
                title: 'Dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
              Route(
                path: '/dashboard/view-data',
                title: 'Dashboard',
                builder: (context, state) => ConfigurationViewDataPage(
                  configDb: _configManager.configService.database,
                ),
              ),
              Route(
                path: '/data-sources',
                title: 'Data Sources',
                builder: (context, state) => const DataSourcesPage(),
              ),
              Route(
                path: '/templates',
                title: 'Embedding Templates',
                builder: (context, state) => const EmbeddingTemplatesPage(),
              ),
              Route(
                path: '/providers',
                title: 'Model Providers',
                builder: (context, state) => const EmbeddingProvidersPage(),
              ),
              Route(
                path: '/jobs',
                title: 'Jobs & Queries',
                builder: (context, state) => const JobsPage(),
              ),
              Route(
                path: '/jobs/:jobId',
                title: 'Job Results',
                builder: (context, state) {
                  final jobId = state.params['jobId'];
                  if (jobId == null) {
                    return const JobsPage(); // Fallback if no jobId
                  }
                  return JobResultsPage(jobId: jobId);
                },
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
                IconButton(
                  className:
                      'p-2 rounded-md text-neutral-600 hover:text-neutral-900 hover:bg-neutral-100',
                  onPressed: () =>
                      setState(() => _isSidebarOpen = !_isSidebarOpen),
                  icon: svg(
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
