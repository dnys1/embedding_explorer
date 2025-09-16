import 'package:jaspr/jaspr.dart';

import '../../common/ui/ui.dart';
import '../../credentials/model/credential.dart';
import '../model/embedding_provider.dart';

final class EmbeddingProviderCredentialsView extends StatefulComponent {
  const EmbeddingProviderCredentialsView({super.key, required this.provider});

  final EmbeddingProvider provider;

  @override
  State<StatefulComponent> createState() =>
      _EmbeddingProviderCredentialsViewState();
}

class _EmbeddingProviderCredentialsViewState
    extends State<EmbeddingProviderCredentialsView> {
  bool _credentialsVisible = false;

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-4', [
      if (component.provider.requiredCredential == CredentialType.apiKey)
        _buildApiKeyInput(),
    ]);
  }

  Component _buildApiKeyInput() {
    return FormField<ApiKeyCredential>(
      name: 'api-key',
      initialValue: component.provider.config?.credential as ApiKeyCredential?,
      onSaved: (credential) {
        // Form will handle the saved credential value
      },
      validator: (credential) {
        if (credential == null || credential.apiKey.trim().isEmpty) {
          return 'API Key is required';
        }
        return null;
      },
      builder: (state) {
        return div(classes: 'space-y-2', [
          Label(htmlFor: 'api-key', children: [text('API Key *')]),
          div(classes: 'relative', [
            Input(
              id: 'api-key',
              type: _credentialsVisible ? InputType.text : InputType.password,
              className: 'pr-12',
              placeholder: component.provider.definition.credentialPlaceholder,
              value: state.value?.apiKey ?? '',
              onChange: (event, target) {
                final newCredential = ApiKeyCredential(target.value);
                state.didChange(newCredential);
              },
            ),
            IconButton(
              className:
                  'absolute inset-y-0 right-0 flex items-center justify-center w-10 h-10',
              variant: ButtonVariant.ghost,
              onPressed: () {
                setState(() {
                  _credentialsVisible = !_credentialsVisible;
                });
              },
              icon: FaIcon(
                _credentialsVisible
                    ? FaIcons.solid.eyeSlash
                    : FaIcons.solid.eye,
              ),
            ),
          ]),
        ]);
      },
    );
  }
}
