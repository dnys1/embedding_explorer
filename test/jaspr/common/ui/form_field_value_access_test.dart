@TestOn('browser')
library;

import 'package:embeddings_explorer/common/ui/ui.dart';
import 'package:embeddings_explorer/credentials/model/credential.dart';
import 'package:jaspr/jaspr.dart';

import '../../../common.dart';
import '../../common.dart';

void main() {
  setupTests();

  group('Form Field Value Access', () {
    testBrowser('can access field values by name', (tester) async {
      final formKey = FormKey();
      String? savedName;
      ApiKeyCredential? savedCredential;

      tester.pumpComponent(
        Form(
          formKey: formKey,
          child: div([
            TextFormField(
              name: 'config-name',
              initialValue: 'Test Configuration',
              onSaved: (value) => savedName = value,
            ),
            FormField<ApiKeyCredential>(
              name: 'api-key',
              initialValue: ApiKeyCredential('test-key-123'),
              onSaved: (value) => savedCredential = value,
              builder: (state) => div([text('API Key Field')]),
            ),
          ]),
        ),
      );

      await tester.pump();

      // Get form state
      final formContext = formKey.currentContext;
      expect(formContext, isNotNull);

      final formState = Form.of(formContext!);

      // Test getting field values by name
      final configName = formState.getFieldValue<String>('config-name');
      final apiKey = formState.getFieldValue<ApiKeyCredential>('api-key');

      expect(configName, equals('Test Configuration'));
      expect(apiKey?.apiKey, equals('test-key-123'));

      // Test getting all field values
      final allValues = formState.getFieldValues();
      expect(allValues['config-name'], equals('Test Configuration'));
      expect(
        (allValues['api-key'] as ApiKeyCredential?)?.apiKey,
        equals('test-key-123'),
      );

      // Test that save still works
      formState.save();
      expect(savedName, equals('Test Configuration'));
      expect(savedCredential?.apiKey, equals('test-key-123'));
    });

    testBrowser('returns null for non-existent field names', (tester) async {
      final formKey = FormKey();

      tester.pumpComponent(
        Form(
          formKey: formKey,
          child: TextFormField(
            name: 'existing-field',
            initialValue: 'test value',
          ),
        ),
      );

      await tester.pump();

      final formContext = formKey.currentContext;
      final formState = Form.of(formContext!);

      // Test accessing non-existent field
      final nonExistent = formState.getFieldValue<String>('non-existent-field');
      expect(nonExistent, isNull);

      // Test that existing field still works
      final existing = formState.getFieldValue<String>('existing-field');
      expect(existing, equals('test value'));
    });

    testBrowser('field values update when changed', (tester) async {
      final formKey = FormKey();

      tester.pumpComponent(
        Form(
          formKey: formKey,
          child: TextFormField(
            name: 'dynamic-field',
            initialValue: 'initial value',
          ),
        ),
      );

      await tester.pump();

      final formContext = formKey.currentContext;
      final formState = Form.of(formContext!);

      // Initial value
      expect(
        formState.getFieldValue<String>('dynamic-field'),
        equals('initial value'),
      );

      // Change the field value
      await tester.input(find.tag('input'), value: 'updated value');
      await tester.pump();

      // Value should be updated
      expect(
        formState.getFieldValue<String>('dynamic-field'),
        equals('updated value'),
      );
    });
  });
}
