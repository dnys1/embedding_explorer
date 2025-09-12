import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../common/ui/button.dart';
import '../model/configuration_manager.dart';

class Dashboard extends StatefulComponent {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with ConfigurationManagerListener {
  ConfigurationSummary get _summary => configManager.getSummary();

  @override
  Component build(BuildContext context) {
    return div(classes: 'h-full bg-neutral-50 flex flex-col', [
      // Page header
      div(classes: 'bg-white border-b border-neutral-200 px-6 py-4', [
        div(classes: 'flex items-center justify-between', [
          div([
            h1(classes: 'text-2xl font-bold text-neutral-900', [
              text('Dashboard'),
            ]),
            p(classes: 'mt-1 text-sm text-neutral-600', [
              text('Manage your data sources, templates, and providers'),
            ]),
          ]),
          div(classes: 'flex space-x-2', [
            // button(
            //   classes:
            //       'px-4 py-2 text-sm font-medium text-neutral-700 bg-white border border-neutral-300 rounded-md hover:bg-neutral-50',
            //   events: {'click': (_) => _createSampleConfigurations()},
            //   [text('Add Sample Data')],
            // ),
            button(
              classes:
                  'px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700',
              events: {'click': (_) => _clearAllConfigurations()},
              [text('Clear All')],
            ),
          ]),
        ]),
      ]),

      // Main content
      div(classes: 'flex-1 overflow-y-auto px-6 py-6', [
        div(classes: 'max-w-7xl', [
          // Summary cards
          _buildSummaryCards(),

          div(classes: 'mt-8 space-y-8', [
            // Data sources section
            _buildDataSourcesSection(),

            // Embedding templates section
            _buildEmbeddingTemplatesSection(),

            // Model providers section
            _buildModelProvidersSection(),

            // Custom provider templates section
            _buildCustomProviderTemplatesSection(),
          ]),
        ]),
      ]),
    ]);
  }

  Component _buildSummaryCards() {
    final totalProviderCount =
        _summary.modelProviderCount + _summary.customProviderTemplateCount;
    return div(
      classes: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8',
      [
        _buildSummaryCard(
          title: 'Data Sources',
          value: '${_summary.dataSourceCount}',
          icon: '🗃️',
          color: 'bg-primary-500',
        ),
        _buildSummaryCard(
          title: 'Templates',
          value: '${_summary.embeddingTemplateCount}',
          subtitle: _summary.embeddingTemplateCount == 0
              ? null
              : '${_summary.validTemplatesCount} valid',
          icon: '📝',
          color: 'bg-green-500',
        ),
        _buildSummaryCard(
          title: 'Providers',
          value: '$totalProviderCount',
          subtitle: totalProviderCount == 0
              ? null
              : '${_summary.modelProviderCount} active',
          icon: '🤖',
          color: 'bg-purple-500',
        ),
        _buildSummaryCard(
          title: 'Storage',
          value: _getStorageInfo(),
          subtitle: 'Local storage',
          icon: '💾',
          color: 'bg-yellow-500',
        ),
      ],
    );
  }

  Component _buildSummaryCard({
    required String title,
    required String value,
    String? subtitle,
    required String icon,
    required String color,
  }) {
    return div(classes: 'bg-white rounded-lg shadow p-6', [
      div(classes: 'flex items-center', [
        div(classes: '$color text-white p-3 rounded-full text-xl', [
          text(icon),
        ]),
        div(classes: 'ml-4', [
          p(classes: 'text-sm font-medium text-neutral-600', [text(title)]),
          p(classes: 'text-2xl font-semibold text-neutral-900', [text(value)]),
          if (subtitle != null)
            p(classes: 'text-sm text-neutral-500', [text(subtitle)]),
        ]),
      ]),
    ]);
  }

  Component _buildDataSourcesSection() {
    final dataSources = configManager.dataSources.all;

    return div(classes: 'bg-white rounded-lg shadow', [
      div(classes: 'px-6 py-4 border-b border-neutral-200', [
        div(classes: 'flex items-center justify-between', [
          h2(classes: 'text-lg font-medium text-neutral-900', [
            text('Data Sources (${dataSources.length})'),
          ]),
          Button(
            variant: ButtonVariant.secondary,
            onPressed: () => Router.of(context).push('/data-sources'),
            children: [text('Configure')],
          ),
        ]),
      ]),
      div(classes: 'divide-y divide-neutral-200', [
        if (dataSources.isEmpty)
          div(classes: 'px-6 py-8 text-center text-neutral-500', [
            text('No data sources configured yet'),
          ])
        else
          ...dataSources.map(
            (config) => _buildConfigItem(
              title: config.name,
              subtitle: config.type.name.toUpperCase(),
              description: config.description.isNotEmpty
                  ? config.description
                  : 'No description',
              onDelete: () => configManager.dataSources.remove(config.id),
            ),
          ),
      ]),
    ]);
  }

  Component _buildEmbeddingTemplatesSection() {
    final templates = configManager.embeddingTemplates.all;

    return div(classes: 'bg-white rounded-lg shadow', [
      div(classes: 'px-6 py-4 border-b border-neutral-200', [
        div(classes: 'flex items-center justify-between', [
          h2(classes: 'text-lg font-medium text-neutral-900', [
            text('Embedding Templates (${templates.length})'),
          ]),
          Button(
            variant: ButtonVariant.secondary,
            onPressed: () => Router.of(context).push('/templates'),
            children: [text('Configure')],
          ),
        ]),
      ]),
      div(classes: 'divide-y divide-neutral-200', [
        if (templates.isEmpty)
          div(classes: 'px-6 py-8 text-center text-neutral-500', [
            text('No templates configured yet'),
          ])
        else
          ...templates.map((config) {
            final dataSource = configManager.dataSources.getById(
              config.dataSourceId,
            );
            final dataSourceInfo = dataSource != null
                ? '${dataSource.name} (${dataSource.type.name.toUpperCase()})'
                : 'Missing data source';

            return _buildConfigItem(
              title: config.name,
              subtitle: config.isValid ? 'Valid' : 'Invalid',
              description: config.description.isNotEmpty
                  ? '${config.description} • Data: $dataSourceInfo'
                  : 'Data: $dataSourceInfo',
              onDelete: () =>
                  configManager.embeddingTemplates.remove(config.id),
            );
          }),
      ]),
    ]);
  }

  Component _buildModelProvidersSection() {
    final providers = configManager.modelProviders.all;

    return div(classes: 'bg-white rounded-lg shadow', [
      div(classes: 'px-6 py-4 border-b border-neutral-200', [
        div(classes: 'flex items-center justify-between', [
          h2(classes: 'text-lg font-medium text-neutral-900', [
            text('Model Providers (${providers.length})'),
          ]),
          Button(
            variant: ButtonVariant.secondary,
            onPressed: () => Router.of(context).push('/providers'),
            children: [text('Configure')],
          ),
        ]),
      ]),
      div(classes: 'divide-y divide-neutral-200', [
        if (providers.isEmpty)
          div(classes: 'px-6 py-8 text-center text-neutral-500', [
            text('No providers configured yet'),
          ])
        else
          ...providers.map(
            (config) => _buildConfigItem(
              title: config.name,
              subtitle: config.type.name,
              description: config.description.isNotEmpty
                  ? config.description
                  : 'No description',
              onDelete: () => configManager.modelProviders.remove(config.id),
            ),
          ),
      ]),
    ]);
  }

  Component _buildCustomProviderTemplatesSection() {
    final templates = configManager.customProviderTemplates.all;

    return div(classes: 'bg-white rounded-lg shadow', [
      div(classes: 'px-6 py-4 border-b border-neutral-200', [
        div(classes: 'flex items-center justify-between', [
          h2(classes: 'text-lg font-medium text-neutral-900', [
            text('Custom Providers (${templates.length})'),
          ]),
          Button(
            variant: ButtonVariant.secondary,
            onPressed: () => Router.of(context).push('/providers#custom'),
            children: [text('Configure')],
          ),
        ]),
      ]),
      div(classes: 'divide-y divide-neutral-200', [
        if (templates.isEmpty)
          div(classes: 'px-6 py-8 text-center text-neutral-500', [
            text('No custom provider templates configured yet'),
          ])
        else
          ...templates.map(
            (template) => _buildConfigItem(
              title: template.name,
              subtitle: 'CUSTOM TEMPLATE',
              description: template.description.isNotEmpty
                  ? '${template.description} • Base URI: ${template.baseUri}'
                  : 'Base URI: ${template.baseUri}',
              onDelete: () =>
                  configManager.customProviderTemplates.remove(template.id),
            ),
          ),
      ]),
    ]);
  }

  Component _buildConfigItem({
    required String title,
    required String subtitle,
    required String description,
    required void Function() onDelete,
  }) {
    return div(classes: 'px-6 py-4', [
      div(classes: 'flex items-center justify-between', [
        div(classes: 'flex-1 min-w-0', [
          div(classes: 'flex items-center', [
            h3(classes: 'text-sm font-medium text-neutral-900 truncate', [
              text(title),
            ]),
            span(
              classes:
                  'ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-neutral-100 text-neutral-800',
              [text(subtitle)],
            ),
          ]),
          p(classes: 'mt-1 text-sm text-neutral-500 truncate', [
            text(description),
          ]),
        ]),
        button(
          classes: 'ml-4 text-red-600 hover:text-red-800 text-sm',
          events: {'click': (_) => onDelete()},
          [text('Delete')],
        ),
      ]),
    ]);
  }

  String _getStorageInfo() {
    // TODO: This would need to be implemented with actual storage size calculation
    return '< 1KB';
  }

  void _clearAllConfigurations() {
    configManager.clearAll();
  }

  // Simple confirm dialog (would be better to use a proper modal)
  bool confirm(String message) {
    // In a real implementation, this would show a proper confirmation dialog
    print('Confirm: $message');
    return true; // For demo purposes, always confirm
  }
}
