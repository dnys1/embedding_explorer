import '../../interop/monaco.dart' hide RegExp;
import 'custom_language.dart';

final class TemplateLanguage implements MonacoCustomLanguage {
  TemplateLanguage({required this.schema})
    : completionItemProvider = _TemplateCompletionItemProvider(schema: schema),
      hoverProvider = _TemplateHoverProvider(schema: schema);

  final Map<String, String> schema;

  @override
  String get languageId => 'template';

  @override
  IMonarchLanguage get definition => IMonarchLanguage(
    tokenizer: {
      'root': [
        IExpandedMonarchLanguageRule(
          regex: r'\{\{[^}]*\}\}',
          action: 'variable',
        ),
        IExpandedMonarchLanguageRule(regex: r'//.*$', action: 'comment'),
      ],
    },
  );

  @override
  final MonacoCompletionItemProvider completionItemProvider;

  @override
  final MonacoHoverProvider hoverProvider;
}

final class _TemplateCompletionItemProvider
    implements MonacoCompletionItemProvider {
  _TemplateCompletionItemProvider({required this.schema});

  final Map<String, String> schema;

  @override
  List<String> get triggerCharacters => const ['{'];

  @override
  CompletionList? provideCompletionItems(
    ITextModel model,
    Position position,
    CompletionContext context,
    CancellationToken token,
  ) {
    final line = model.getLineContent(position.lineNumber);

    // Find the word being typed
    var i = 0;
    var nb = line.indexOf('{', i);
    String? word;
    while (nb >= 0) {
      final end = line.indexOf('}', nb + 1);
      if (end < 0) {
        word = line.substring(nb);
        break;
      }
      if (position.column >= nb && position.column <= end + 1) {
        word = line.substring(nb, end + 1);
        break;
      }
      i = end + 1;
      nb = line.indexOf('{', i);
    }

    // Word does not start with '{', so no suggestions
    if (word == null) {
      return null;
    }

    final suggestions = schema.keys
        .where((field) => '{{$field}}'.startsWith(word!))
        .toSet()
        .map(
          (field) => CompletionItem(
            label: '{{$field}}',
            kind: CompletionItemKind.Field,
            detail: 'Data field: $field',
            documentation: 'Insert field value for $field',
            insertText: '{{$field}}'.replaceFirst(word!, ''),
          ),
        )
        .toList();
    return CompletionList(suggestions: suggestions);
  }
}

final class _TemplateHoverProvider implements MonacoHoverProvider {
  _TemplateHoverProvider({required this.schema});

  final Map<String, String> schema;

  @override
  Hover? provideHover(
    ITextModel model,
    Position position,
    CancellationToken token,
  ) {
    var word = model.getLineContent(position.lineNumber);
    // There may be multiple fields in the line, so we need to find the one under the cursor
    var i = 0;
    var nb = word.indexOf('{{', i);
    while (nb >= 0) {
      final end = word.indexOf('}}', nb + 2);
      if (end < 0) break; // No closing braces
      if (position.column >= nb && position.column <= end + 2) {
        // Cursor is within this field
        word = word.substring(nb, end + 2);
        break;
      }
      i = end + 2;
      nb = word.indexOf('{{', i);
    }

    // Find the field under the cursor
    final fieldMatch = RegExp(r'\{\{(\w+)\}\}').matchAsPrefix(word);

    if (fieldMatch != null) {
      final fieldName = fieldMatch.group(1)!;
      if (schema.keys.contains(fieldName)) {
        return Hover(
          contents: [
            IMarkdownString(value: 'Field: **$fieldName**'),
            IMarkdownString(
              value:
                  'This will be replaced with the value from your data source.',
            ),
          ],
        );
      }
    }

    return null;
  }
}
