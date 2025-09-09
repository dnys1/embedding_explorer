import 'dart:async';
import 'dart:js_interop';

import 'package:embeddings_explorer/interop/monaco.dart'
    as monaco
    show loadModule, editor, languages;
import 'package:embeddings_explorer/interop/monaco.dart' hide Uri, RegExp;
import 'package:embeddings_explorer/models/data_source.dart';
import 'package:embeddings_explorer/models/transformation_template.dart';
import 'package:embeddings_explorer/services/data_sources/sqlite_service.dart';
import 'package:embeddings_explorer/util/change_notifier.dart';
import 'package:jaspr/browser.dart' show ValueListenable, ValueNotifier;
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

final class TransformationModel extends ChangeNotifierX {
  factory TransformationModel({required DataSource? dataSource}) {
    dataSource ??= SqliteDataSource.withSampleData(name: 'test');
    return TransformationModel._(dataSource: dataSource);
  }

  TransformationModel._({required DataSource dataSource})
    : _dataSource = dataSource;

  static final Logger _logger = Logger('TransformationEditorModel');

  final DataSource _dataSource;
  DataSource get dataSource => _dataSource;

  final ValueNotifier<TransformationTemplate> _template = ValueNotifier(
    _defaultTemplate,
  );
  List<String> _availableFields = [];
  Map<String, dynamic>? _sampleRow;
  bool _isLoading = false;

  IStandaloneCodeEditor? _editor;
  IStandaloneCodeEditor get editor => _editor!;

  ITextModel get debugTextModel => _editor!.getModel()!;

  void debugSetTextModel(ITextModel model) {
    setState(() {
      _editor?.setModel(model);
    });
  }

  static const TransformationTemplate _defaultTemplate = TransformationTemplate(
    '''
// Transform your data for embedding
// Use template syntax like: "Title: {{title}}, Content: {{content}}"

{{title}} - {{description}}
''',
  );

  bool _isEditorInitialized = false;

  ValueListenable<TransformationTemplate> get template => _template;
  List<String> get availableFields => _availableFields;
  Map<String, dynamic>? get sampleRow => _sampleRow;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  void dismissError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  String get previewText {
    final template = _template.value;
    if (template.isEmpty) {
      return 'Preview will appear here once you define a template...';
    }
    return template.render(_sampleRow);
  }

  Future<void> init() async {
    assert(!_isLoading);
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadAvailableFields(), _initializeEditor()]);
    } catch (e) {
      _error = 'Initialization failed: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableFields() async {
    try {
      if (!_dataSource.isConnected) {
        await _dataSource.connect();
      }
      final (schema, sampleData) = await (
        _dataSource.getSchema(),
        _dataSource.getSampleData(limit: 1),
      ).wait;
      setState(() {
        _availableFields = schema.keys.toList();
        _sampleRow = sampleData.firstOrNull;
      });
    } catch (e) {
      _error = 'Failed to load fields: $e';
    }
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
          value: _template.value,
          language: 'transformation-template',
          theme: 'vs',
          automaticLayout: false,
          fontSize: 14,
          minimap: IEditorMinimapOptions(enabled: false),
          scrollbar: IEditorScrollbarOptions(
            vertical: AnonymousUnion_1753152.hidden,
            horizontal: AnonymousUnion_1753152.hidden,
            handleMouseWheel: false,
          ),
          scrollBeyondLastLine: false,
          wordWrap: AnonymousUnion_2810996.on$,
          contextmenu: false,
          acceptSuggestionOnEnter: true,
          acceptSuggestionOnCommitCharacter: true,
          tabCompletion: 'on',
          tabFocusMode: true,
          suggest: ISuggestOptions(
            insertMode: AnonymousUnion_1259071.replace,
            filterGraceful: true,
          ),
        ),
      );

      // Listen for content changes
      editor.onDidChangeModelContent((_) {
        _template.value = TransformationTemplate(editor.getValue());
      });

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

  void insertField(String field) {
    assert(_isEditorInitialized);

    final editor = _editor;
    if (editor == null) {
      return;
    }
    final fieldTemplate = '{{$field}}';

    // Insert the field template at cursor position
    editor.trigger('keyboard', 'type', {'text': fieldTemplate}.jsify());
    editor.focus();
  }

  @override
  void dispose() {
    _editor?.dispose();
    _template.dispose();
    super.dispose();
  }
}
