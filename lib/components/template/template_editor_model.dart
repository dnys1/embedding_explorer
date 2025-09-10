import 'dart:async';

import 'package:embeddings_explorer/interop/monaco.dart'
    as monaco
    show loadModule, editor, languages;
import 'package:embeddings_explorer/interop/monaco.dart' hide Uri, RegExp;
import 'package:embeddings_explorer/models/configuration_manager.dart';
import 'package:embeddings_explorer/models/data_sources/data_source.dart';
import 'package:embeddings_explorer/models/embedding_template_config.dart';
import 'package:embeddings_explorer/util/change_notifier.dart';
import 'package:jaspr/browser.dart' show ValueListenable, ValueNotifier;
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

final class TemplateEditorModel extends ChangeNotifierX {
  factory TemplateEditorModel({
    required ConfigurationManager configManager,
    EmbeddingTemplateConfig? initialTemplate,
  }) {
    return TemplateEditorModel._(
      configManager: configManager,
      initialTemplate: initialTemplate,
    );
  }

  TemplateEditorModel._({
    required ConfigurationManager configManager,
    EmbeddingTemplateConfig? initialTemplate,
  }) : _configManager = configManager,
       _initialTemplate = initialTemplate;

  static final Logger _logger = Logger('TemplateEditorModel');

  final ConfigurationManager _configManager;
  final EmbeddingTemplateConfig? _initialTemplate;

  ConfigurationManager get configManager => _configManager;

  final ValueNotifier<String> _template = ValueNotifier('');
  final ValueNotifier<String> _name = ValueNotifier('');
  final ValueNotifier<String> _description = ValueNotifier('');
  final ValueNotifier<String> _selectedDataSourceId = ValueNotifier('');

  DataSource? _currentDataSource;
  List<String> _schemaFields = [];
  Map<String, dynamic>? _sampleRow;
  bool _isLoading = false;

  IStandaloneCodeEditor? _editor;
  IStandaloneCodeEditor get editor => _editor!;

  static const String _defaultTemplate = '''// Create your embedding template
// Use {{field}} syntax to reference data fields
// Example: "Title: {{title}} Content: {{content}}"

{{title}} - {{description}}''';

  bool _isEditorInitialized = false;

  ValueListenable<String> get template => _template;
  ValueListenable<String> get name => _name;
  ValueListenable<String> get description => _description;
  ValueListenable<String> get selectedDataSourceId => _selectedDataSourceId;
  List<String> get schemaFields => _schemaFields;
  Map<String, dynamic>? get sampleRow => _sampleRow;
  bool get isLoading => _isLoading;
  DataSource? get currentDataSource => _currentDataSource;

  String? _error;
  String? get error => _error;
  void dismissError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  String get previewText {
    final templateText = _template.value;
    if (templateText.isEmpty) {
      return 'Preview will appear here once you define a template...';
    }
    return _renderTemplate(templateText, _sampleRow);
  }

  String _renderTemplate(String template, Map<String, dynamic>? data) {
    if (data == null) return template;
    final RegExp comments = RegExp(r'//.*$', multiLine: true);

    String result = template.replaceAll(comments, '').trim();
    for (final entry in data.entries) {
      final placeholder = '{{${entry.key}}}';
      result = result.replaceAll(placeholder, entry.value?.toString() ?? '');
    }
    return result;
  }

  void updateName(String newName) {
    if (_name.value != newName) {
      _name.value = newName;
      notifyListeners();
    }
  }

  void updateDescription(String newDescription) {
    if (_description.value != newDescription) {
      _description.value = newDescription;
      notifyListeners();
    }
  }

  Future<void> updateDataSource(String dataSourceId) async {
    if (_selectedDataSourceId.value != dataSourceId) {
      _selectedDataSourceId.value = dataSourceId;

      // Clear current data source data
      _currentDataSource = null;
      _schemaFields = [];
      _sampleRow = null;

      // Load new data source if selected
      if (dataSourceId.isNotEmpty) {
        await _loadDataSourceById(dataSourceId);
      }

      _updateEditorLanguageConfiguration();
      notifyListeners();
    }
  }

  bool validate() {
    return _name.value.isNotEmpty &&
        _template.value.isNotEmpty &&
        _selectedDataSourceId.value.isNotEmpty;
  }

  EmbeddingTemplateConfig createConfig(String id) {
    return EmbeddingTemplateConfig(
      id: id,
      name: _name.value,
      description: _description.value,
      template: _template.value,
      dataSourceId: _selectedDataSourceId.value,
      availableFields: List.of(_schemaFields),
      metadata: {},
      createdAt: _initialTemplate?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> init() async {
    assert(!_isLoading);
    setState(() => _isLoading = true);
    try {
      if (_initialTemplate != null) {
        _name.value = _initialTemplate.name;
        _description.value = _initialTemplate.description;
        _template.value = _initialTemplate.template;
        _selectedDataSourceId.value = _initialTemplate.dataSourceId;

        // Load the data source for the initial template
        if (_initialTemplate.dataSourceId.isNotEmpty) {
          await _loadDataSourceById(_initialTemplate.dataSourceId);
        }
      } else {
        _template.value = _defaultTemplate;
      }

      await _initializeEditor();
    } catch (e) {
      _error = 'Initialization failed: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDataSourceById(String dataSourceId) async {
    try {
      final dataSourceConfig = _configManager.dataSources.getById(dataSourceId);
      if (dataSourceConfig == null) {
        _error = 'Data source not found: $dataSourceId';
        return;
      }

      _currentDataSource = DataSource.fromConfig(dataSourceConfig);
      if (!_currentDataSource!.isConnected) {
        await _currentDataSource!.connect();
      }

      final (schema, sampleData) = await (
        _currentDataSource!.getSchema(),
        _currentDataSource!.getSampleData(limit: 1),
      ).wait;

      _schemaFields = (schema as Map<String, dynamic>).keys.toList();
      _sampleRow = sampleData.isNotEmpty ? sampleData.first : null;

      setState(() {});
    } catch (e) {
      _logger.warning('Failed to load data source fields: $e');
      _error = 'Failed to load data source: $e';
    }
  }

  Future<void> _initializeEditor() async {
    if (_isEditorInitialized) {
      return;
    }
    _logger.finest('Loading Monaco editor module.');
    await monaco.loadModule();

    // Wait for the container to be available
    final container = web.document.getElementById('template-editor-container');
    if (container == null) {
      _logger.severe('Editor container not found (#template-editor-container)');
      _error = 'Editor container not found';
      return;
    }

    _logger.finest('Initializing Monaco editor in container.');

    final editor = _editor = monaco.editor.create(
      container,
      IStandaloneEditorConstructionOptions(
        value: _template.value,
        language: 'template',
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

    _configureTemplateLanguage();
    _updateEditorLanguageConfiguration();

    // Listen for content changes
    editor.onDidChangeModelContent((IModelContentChangedEvent e) {
      final newValue = editor.getValue();
      if (_template.value != newValue) {
        _template.value = newValue;
        notifyListeners();
      }
    });

    _isEditorInitialized = true;
  }

  /// Configures Monaco with a custom language for template syntax
  void _configureTemplateLanguage() {
    _logger.finest('Configuring template language.');

    // Register the template language
    monaco.languages.register(ILanguageExtensionPoint(id: 'template'));

    _updateEditorLanguageConfiguration();
  }

  void _updateEditorLanguageConfiguration() {
    final allFields = _schemaFields;

    // Set syntax highlighting
    monaco.languages.setMonarchTokensProvider(
      'template',
      IMonarchLanguage(
        tokenizer: {
          'root': [
            IExpandedMonarchLanguageRule(
              regex: r'\{\{[^}]*\}\}',
              action: 'variable',
            ),
            IExpandedMonarchLanguageRule(regex: r'//.*$', action: 'comment'),
          ],
        },
      ),
    );

    // Set up completion provider
    monaco.languages.registerCompletionItemProvider(
      'template',
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

            final suggestions = allFields
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
          },
    );

    // Set up hover provider
    monaco.languages.registerHoverProvider(
      'template',
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
          if (allFields.contains(fieldName)) {
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
  void dispose() {
    print('Disposing TemplateEditorModel');
    print(StackTrace.current);
    _editor?.dispose();
    _template.dispose();
    _name.dispose();
    _description.dispose();
    _selectedDataSourceId.dispose();
    super.dispose();
  }
}
