import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class Sidebar extends StatefulComponent {
  const Sidebar({super.key, this.isOpen = false, this.onClose});

  final bool isOpen;
  final void Function()? onClose;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool get _isCollapsed => !component.isOpen;

  void _closeSidebar() {
    component.onClose?.call();
  }

  @override
  Component build(BuildContext context) {
    final routerState = RouteState.of(context);
    final currentPath = routerState.location;

    return fragment([
      // Mobile overlay when sidebar is open
      if (!_isCollapsed)
        div(
          classes: 'fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden',
          events: {'click': (_) => _closeSidebar()},
          [],
        ),

      // Sidebar
      aside(
        classes: [
          'fixed inset-y-0 left-0 z-50 bg-neutral-900 text-white flex flex-col shadow-lg transition-transform duration-300 ease-in-out',
          'w-64', // Fixed width
          // Responsive behavior
          'lg:translate-x-0', // Always visible on large screens
          if (_isCollapsed)
            '-translate-x-full'
          else
            'translate-x-0', // Hidden/visible on smaller screens
        ].join(' '),
        [
          // Header with mobile toggle
          div(classes: 'p-4 border-b border-neutral-700', [
            div(classes: 'flex items-center justify-between', [
              div(classes: 'flex items-center space-x-2', [
                img(src: 'images/logo.png', width: 24, height: 24),
                h2(classes: 'text-lg font-semibold text-white', [
                  Link(to: '/dashboard', child: text('Embeddings Explorer')),
                ]),
              ]),
              // Mobile close button
              button(
                classes:
                    'lg:hidden p-1 rounded-md text-neutral-400 hover:text-white hover:bg-neutral-800',
                events: {'click': (_) => _closeSidebar()},
                [
                  svg(
                    classes: 'w-5 h-5',
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
                          'd': 'M6 18L18 6M6 6l12 12',
                        },
                        [],
                      ),
                    ],
                  ),
                ],
              ),
            ]),
          ]),

          // Navigation
          nav(classes: 'flex-1 px-2 py-4 space-y-1', [
            _buildNavItem(
              context,
              icon: 'database',
              label: 'Data Sources',
              path: '/data-sources',
              isActive: currentPath.startsWith('/data-source'),
            ),
            _buildNavItem(
              context,
              icon: 'template',
              label: 'Templates',
              path: '/templates',
              isActive: currentPath.startsWith('/transformation'),
            ),
            _buildNavItem(
              context,
              icon: 'provider',
              label: 'Providers',
              path: '/providers',
              isActive: currentPath.startsWith('/providers'),
            ),
            _buildNavItem(
              context,
              icon: 'query',
              label: 'Jobs',
              path: '/jobs',
              isActive: currentPath.startsWith('/jobs'),
            ),
          ]),

          // Footer
          div(classes: 'p-4 border-t border-neutral-700', [
            Link(
              to: '/about',
              child: div(
                classes:
                    'flex items-center space-x-2 text-neutral-400 hover:text-white transition-colors duration-200',
                [
                  _buildIcon('info'),
                  span(classes: 'text-sm', [text('About')]),
                ],
              ),
            ),
          ]),
        ],
      ),
    ]);
  }

  Component _buildNavItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String path,
    required bool isActive,
  }) {
    return Link(
      to: path,
      child: div(
        classes: [
          'flex items-center space-x-3 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200',
          if (isActive)
            'bg-neutral-800 text-white'
          else
            'text-neutral-300 hover:bg-neutral-700 hover:text-white',
        ].join(' '),
        [
          _buildIcon(icon),
          span([text(label)]),
        ],
      ),
    );
  }

  Component _buildIcon(String iconType) {
    // Using simple text icons for now - can be replaced with proper icon library later
    final iconMap = {
      'database': '🗃️',
      'template': '📝',
      'provider': '🤖',
      'query': '🔍',
      'info': 'ℹ️',
    };

    return span(classes: 'w-5 h-5 flex items-center justify-center text-sm', [
      text(iconMap[iconType] ?? '•'),
    ]);
  }
}
