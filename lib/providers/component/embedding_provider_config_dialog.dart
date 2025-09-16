import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../credentials/model/credential.dart';
import '../model/embedding_provider.dart';
import '../model/embedding_provider_config.dart';
import 'embedding_provider_credentials_view.dart';

class EmbeddingProviderConfigDialog extends StatefulComponent {
  final EmbeddingProvider provider;
  final VoidCallback? onClose;

  const EmbeddingProviderConfigDialog({
    super.key,
    required this.provider,
    this.onClose,
  });

  @override
  State<StatefulComponent> createState() =>
      _EmbeddingProviderConfigDialogState();
}

class _EmbeddingProviderConfigDialogState
    extends State<EmbeddingProviderConfigDialog>
    with ConfigurationManagerListener {
  EmbeddingProvider get provider => component.provider;

  // Form management
  final _formKey = FormKey();

  // Form values - these will be populated by form callbacks
  String? _name;
  bool _persistCredentials = false;

  @override
  void initState() {
    super.initState();
    _initializeFormValues();
  }

  void _initializeFormValues() {
    // Initialize form with existing values if editing
    if (provider.config case final config?) {
      _name = config.name;
      _persistCredentials = config.persistCredentials;
    } else {
      // Default values for new configuration
      _name = provider.displayName;
      _persistCredentials = false;
    }
  }

  @override
  Component build(BuildContext context) {
    return Dialog(
      onClose: component.onClose,
      maxWidth: 'max-w-2xl',
      builder: (_) => DialogContent(
        children: [
          DialogHeader(
            children: [
              div(classes: 'flex justify-between items-center', [
                DialogTitle(
                  children: [text('Configure ${provider.displayName}')],
                ),
                IconButton(
                  onPressed: component.onClose,
                  icon: FaIcon(FaIcons.solid.close),
                ),
              ]),
              if (provider.description.isNotEmpty)
                DialogDescription(children: [text(provider.description)]),
            ],
          ),

          // Form wrapper
          Form(
            formKey: _formKey,
            onSubmit: _handleFormSubmit,
            child: div(classes: 'space-y-6', [
              if (provider.type == EmbeddingProviderType.custom)
                _buildNameSection(),
              if (provider.requiredCredential != null) ...[
                _buildCredentialsSection(),
                _buildPersistenceSection(),
              ],
            ]),
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
                  onPressed: _handleSaveButtonClick,
                  children: [text('Save Configuration')],
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Component _buildNameSection() {
    return div(classes: 'space-y-4', [
      h3(classes: 'text-lg font-semibold text-foreground', [
        text('Configuration Name'),
      ]),
      TextFormField(
        name: 'configuration-name',
        initialValue: _name,
        validator: Validators.compose([
          Validators.required,
          Validators.minLength(3),
          Validators.maxLength(50),
        ]),
        onSaved: (value) => _name = value,
        decoration: const InputDecoration(
          label: 'Configuration Name',
          helperText: 'A descriptive name for this provider configuration',
        ),
      ),
    ]);
  }

  Component _buildCredentialsSection() {
    return div(classes: 'space-y-4', [
      h3(classes: 'text-lg font-semibold text-foreground', [
        text('Credentials'),
      ]),

      // Use the existing credentials view for proper credential management
      EmbeddingProviderCredentialsView(provider: provider),
    ]);
  }

  Component _buildPersistenceSection() {
    return div(classes: 'space-y-4', [
      h3(classes: 'text-lg font-semibold text-foreground', [
        text('Storage Options'),
      ]),

      // Credential persistence checkbox
      div(
        classes: 'flex items-center space-x-2 pt-3 border-t border-gray-200',
        [
          Checkbox(
            id: 'persist-credentials',
            checked: _persistCredentials,
            onChanged: (checked) {
              setState(() {
                _persistCredentials = checked;
              });
            },
          ),
          label(
            classes: 'text-sm text-gray-700 cursor-pointer',
            attributes: {'for': 'persist-credentials'},
            [text('Remember credentials for future sessions')],
          ),
        ],
      ),

      if (_persistCredentials)
        div(
          classes:
              'text-xs text-amber-600 bg-amber-50 p-2 rounded border border-amber-200',
          [
            div(classes: 'flex items-center space-x-1', [
              FaIcon(FaIcons.solid.warning),
              text(
                'Warning: Credentials will be stored locally in your browser. Only enable this if you trust this device.',
              ),
            ]),
          ],
        )
      else
        div(
          classes:
              'text-xs text-gray-500 bg-gray-50 p-2 rounded border border-gray-200',
          [
            text(
              '💡 Credentials will only be kept for this session and not saved to storage.',
            ),
          ],
        ),
    ]);
  }

  void _handleFormSubmit() {
    // This is called when the form is submitted
    _saveConfiguration();
  }

  void _handleSaveButtonClick() {
    // Validate and submit the form programmatically

    final currentContext = _formKey.currentContext;
    if (currentContext == null) {
      print('Form context is null, cannot submit form');
      return;
    }
    final formState = Form.of(currentContext);
    if (formState.validate()) {
      formState.save();
      _saveConfiguration();
    }
  }

  void _saveConfiguration() {
    // Ensure we have required values
    final configName = _name?.trim();
    if (configName == null || configName.isEmpty) {
      print('Configuration name is required');
      return;
    }

    // Get the credential from the form field
    final formContext = _formKey.currentContext;
    Credential? credential;
    if (formContext != null) {
      final formState = Form.of(formContext);
      credential = formState.getFieldValue<ApiKeyCredential>('api-key');
    }

    final settings = <String, dynamic>{}; // Currently no additional settings

    if (provider.config case final config?) {
      // Update existing configuration
      configManager.embeddingProviderConfigs
          .updateConfig(
            config.id,
            name: configName,
            credential: credential,
            settings: settings,
            persistCredentials: _persistCredentials,
            enabledModels: config.enabledModels,
          )
          .ignore();
    } else {
      // Add new configuration
      configManager.embeddingProviderConfigs
          .addConfig(
            name: configName,
            type: provider.type,
            description: provider.description,
            credential: credential,
            settings: settings,
            persistCredentials: _persistCredentials,
          )
          .ignore();
    }

    component.onClose?.call();

    print('Provider configuration saved successfully');
  }
}
