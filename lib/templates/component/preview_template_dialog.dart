import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../data_sources/model/data_source.dart';
import '../../util/async_snapshot.dart';
import '../model/embedding_template.dart';

final class PreviewTemplateDialog extends StatefulComponent {
  PreviewTemplateDialog({required this.template, required this.onClose});

  final EmbeddingTemplate template;
  final VoidCallback onClose;

  @override
  State<StatefulComponent> createState() => _PreviewTemplateDialogState();
}

final class _PreviewTemplateDialogState extends State<PreviewTemplateDialog>
    with ConfigurationManagerListener {
  EmbeddingTemplate get template => component.template;

  String _renderTemplate(String template, Map<String, Object?> sampleData) {
    String output = template;
    for (final MapEntry(key: field, value: value) in sampleData.entries) {
      output = output.replaceAll('{{$field}}', value?.toString() ?? '');
    }
    return output;
  }

  @override
  Component build(BuildContext context) {
    final dataSource = configManager.dataSources.expect(template.dataSourceId);

    return Dialog(
      onClose: component.onClose,
      maxWidth: 'max-w-2xl',
      builder: (_) => DialogContent(
        children: [
          DialogHeader(
            children: [
              div(classes: 'flex justify-between items-center', [
                CardTitle(children: [text('Template Preview')]),
                button(
                  classes:
                      'text-muted-foreground hover:text-foreground transition-colors',
                  events: {'click': (event) => component.onClose()},
                  [text('×')],
                ),
              ]),
              CardDescription(
                children: [text('Preview of "${template.name}" template')],
              ),
            ],
          ),

          div(classes: 'space-y-4', [
            // Template info
            div([
              h4(classes: 'font-medium text-foreground mb-2', [
                text('Template Details'),
              ]),
              div(classes: 'text-sm space-y-1', [
                div([
                  span(classes: 'font-medium', [text('Name: ')]),
                  span([text(template.name)]),
                ]),
                if (template.description.isNotEmpty)
                  div([
                    span(classes: 'font-medium', [text('Description: ')]),
                    span([text(template.description)]),
                  ]),
                div([
                  span(classes: 'font-medium', [text('Data Source: ')]),
                  Badge(
                    variant: BadgeVariant.outline,
                    children: [
                      text(
                        '${dataSource.name} (${dataSource.type.name.toUpperCase()})',
                      ),
                    ],
                  ),
                ]),
                div([
                  span(classes: 'font-medium', [text('Status: ')]),
                  Badge(
                    variant: template.isValid
                        ? BadgeVariant.secondary
                        : BadgeVariant.destructive,
                    children: [text(template.isValid ? 'Valid' : 'Invalid')],
                  ),
                ]),
              ]),
            ]),

            _buildDataSourcePreview(dataSource),
          ]),

          DialogFooter(
            children: [
              div(classes: 'flex justify-end w-full', [
                Button(onPressed: component.onClose, children: [text('Close')]),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Component _buildDataSourcePreview(DataSource dataSource) {
    return FutureBuilder(
      future: dataSource.getSampleData(limit: 1),
      builder: (context, snapshot) {
        switch (snapshot.result) {
          case AsyncLoading():
            return div(classes: 'text-sm text-muted-foreground', [
              text('Loading...'),
            ]);
          case AsyncError():
            return fragment([]);
          case AsyncData(data: final sampleData):
            final availableFields = sampleData.first.keys.toList();
            return fragment([
              // Available fields from data source
              if (availableFields.isNotEmpty)
                div([
                  h4(classes: 'font-medium text-foreground mb-2', [
                    text('Available Fields from Data Source'),
                  ]),
                  p(classes: 'text-xs text-muted-foreground mb-2', [
                    text('Fields that can be used in this template:'),
                  ]),
                  div(classes: 'flex flex-wrap gap-1', [
                    for (final field in availableFields)
                      Badge(
                        variant: BadgeVariant.secondary,
                        children: [text('{{$field}}')],
                      ),
                  ]),
                ]),

              // Raw templates
              div(classes: 'space-y-4', [
                h4(classes: 'font-medium text-foreground mb-2', [
                  text('Templates'),
                ]),

                // ID Template
                div([
                  h5(classes: 'text-sm font-medium text-foreground mb-1', [
                    text('ID Template:'),
                  ]),
                  div(classes: 'bg-muted p-3 rounded-md', [
                    pre(classes: 'text-sm font-mono whitespace-pre-wrap', [
                      text(template.idTemplate),
                    ]),
                  ]),
                ]),

                // Body Template
                div([
                  h5(classes: 'text-sm font-medium text-foreground mb-1', [
                    text('Body Template:'),
                  ]),
                  div(classes: 'bg-muted p-3 rounded-md', [
                    pre(classes: 'text-sm font-mono whitespace-pre-wrap', [
                      text(template.template),
                    ]),
                  ]),
                ]),
              ]),

              // Sample output
              if (availableFields.isNotEmpty)
                div(classes: 'space-y-4', [
                  h4(classes: 'font-medium text-foreground mb-2', [
                    text('Sample Output'),
                  ]),
                  p(classes: 'text-xs text-muted-foreground mb-2', [
                    text('Example with placeholder data:'),
                  ]),

                  // ID Template Sample
                  div([
                    h5(classes: 'text-sm font-medium text-foreground mb-1', [
                      text('ID Template Output:'),
                    ]),
                    div(classes: 'bg-muted p-3 rounded-md', [
                      pre(classes: 'text-sm whitespace-pre-wrap font-mono', [
                        text(
                          _renderTemplate(
                            template.idTemplate,
                            sampleData.first,
                          ),
                        ),
                      ]),
                    ]),
                  ]),

                  // Body Template Sample
                  div([
                    h5(classes: 'text-sm font-medium text-foreground mb-1', [
                      text('Body Template Output:'),
                    ]),
                    div(classes: 'bg-muted p-3 rounded-md', [
                      pre(classes: 'text-sm whitespace-pre-wrap font-mono', [
                        text(
                          _renderTemplate(template.template, sampleData.first),
                        ),
                      ]),
                    ]),
                  ]),
                ]),
            ]);
        }
      },
    );
  }
}
