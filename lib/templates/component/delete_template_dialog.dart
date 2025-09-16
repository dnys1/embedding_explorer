import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../model/embedding_template.dart';

final class DeleteTemplateDialog extends StatefulComponent {
  DeleteTemplateDialog({required this.template, required this.onClose});

  final EmbeddingTemplate? template;
  final VoidCallback onClose;

  @override
  State<StatefulComponent> createState() => _DeleteTemplateDialogState();
}

final class _DeleteTemplateDialogState extends State<DeleteTemplateDialog>
    with ConfigurationManagerListener {
  void _deleteTemplate() {
    if (component.template != null) {
      configManager.embeddingTemplates.remove(component.template!.id);
      component.onClose();
    }
  }

  @override
  Component build(BuildContext context) {
    return Dialog(
      onClose: component.onClose,
      maxWidth: 'max-w-md',
      builder: (_) => DialogContent(
        children: [
          DialogHeader(
            children: [
              DialogTitle(children: [text('Delete Template')]),
              DialogDescription(
                children: [
                  text(
                    'Are you sure you want to delete "${component.template?.name}"? This action cannot be undone.',
                  ),
                ],
              ),
            ],
          ),

          DialogFooter(
            children: [
              div(classes: 'flex justify-end space-x-3 w-full', [
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: component.onClose,
                  children: [text('Cancel')],
                ),
                Button(
                  variant: ButtonVariant.destructive,
                  onPressed: _deleteTemplate,
                  children: [text('Delete')],
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
