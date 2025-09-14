import 'package:jaspr/browser.dart' hide Position;
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

import 'interop/monaco.dart' hide RegExp;

final class EditorTestPage extends StatefulComponent {
  const EditorTestPage({super.key});

  @override
  State<StatefulComponent> createState() => _EditorTestPageState();
}

class _EditorTestPageState extends State<EditorTestPage> {
  static final Logger _logger = Logger('EditorTestPage');
  var _isEditorInitialized = false;
  String? _error;
  IStandaloneCodeEditor? _editor;
  final _availableFields = <String>[
    'name',
    'email',
    'age',
    'address',
    'phone',
    'company',
    'position',
    'department',
    'startDate',
    'endDate',
    'status',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the editor after the first frame is rendered
    context.binding.addPostFrameCallback(() {
      _initializeEditor();
    });
  }

  Future<void> _initializeEditor() async {
    if (_isEditorInitialized) {
      _logger.finest('Editor already initialized, skipping re-initialization.');
      return;
    }

    try {
      _logger.finest('Loading Monaco editor module.');
      await monaco.loadModule();

      final container = web.document.getElementById('transformation-editor');
      if (container == null) {
        _logger.severe('Editor container not found (#transformation-editor)');
        _error = 'Editor container not found';
        return;
      }

      _logger.finest('Initializing Monaco editor in container.');

      _setupLanguageSupport();

      final editor = _editor = monaco.editor.create(
        container,
        IStandaloneEditorConstructionOptions(
          value: '',
          language: 'transformation-template',
          theme: 'vs',
          automaticLayout: false,
          fontSize: 14,
          minimap: IEditorMinimapOptions(enabled: false),
          scrollbar: IEditorScrollbarOptions(
            vertical: AnonymousUnion_1753152.hidden,
            horizontal: AnonymousUnion_1753152.hidden,
          ),
          scrollBeyondLastLine: false,
          wordWrap: AnonymousUnion_2810996.on$,
          contextmenu: false,
          // acceptSuggestionOnEnter: true,
          // acceptSuggestionOnCommitCharacter: true,
          tabCompletion: 'on',
          tabFocusMode: true,
          suggest: ISuggestOptions(
            insertMode: AnonymousUnion_1259071.replace,
            filterGraceful: true,
          ),
        ),
      );

      // // Listen for content changes
      // editor.onDidChangeModelContent((_) {
      //   _template.value = TransformationTemplate(editor.getValue());
      // });

      _isEditorInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize editor: $e';
    }
  }

  /// Configures Monaco with a custom language for template syntax
  void _setupLanguageSupport() {
    if (_availableFields.isEmpty) {
      _logger.warning(
        'No available fields to setup language support for transformation templates.',
      );
      return;
    }

    // Register the custom language
    monaco.languages.register(
      ILanguageExtensionPoint(
        id: 'transformation-template',
        extensions: ['.tpl'],
        aliases: ['Template', 'transformation-template'],
      ),
    );

    // Setup syntax highlighting
    monaco.languages.setMonarchTokensProvider(
      'transformation-template',
      IMonarchLanguage(
        brackets: [
          IMonarchLanguageBracket(
            open: '{',
            close: '}',
            token: 'delimiter.curly',
          ),
        ],
        tokenizer: {
          'root': [
            IExpandedMonarchLanguageRule(
              regex: r'\{\{[^}]*\}\}',
              action: 'variable',
            ),
            IExpandedMonarchLanguageRule(regex: r'[{}]', action: 'delimiter'),
            IExpandedMonarchLanguageRule(
              regex: r'[a-zA-Z_]\w*',
              action: 'identifier',
            ),
            IExpandedMonarchLanguageRule(regex: r'"[^"]*"', action: 'string'),
            IExpandedMonarchLanguageRule(regex: r"'[^']*'", action: 'string'),
          ],
        },
      ),
    );

    // Setup completion provider for field suggestions
    monaco.languages.registerCompletionItemProvider(
      'transformation-template',
      triggerCharacters: ['{'],
      provideCompletionItems:
          (
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

            final suggestions = _availableFields
                .where((field) => '{{$field}}'.startsWith(word!))
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
          },
    );

    // Setup hover provider for field documentation
    monaco.languages.registerHoverProvider(
      'transformation-template',
      provideHover: (ITextModel model, Position position, CancellationToken token) {
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
          if (_availableFields.contains(fieldName)) {
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
      },
    );
  }

  @override
  Component build(BuildContext context) {
    return div(
      id: 'transformation-editor',
      classes: 'w-full',
      styles: Styles(height: 400.px),
      [],
    );
  }
}
