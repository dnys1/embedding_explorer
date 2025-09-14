import 'dart:async';

import 'package:jaspr/browser.dart' show ValueListenable, ValueNotifier;
import 'package:logging/logging.dart';

import '../../common/monaco/custom_language.dart';
import '../../common/monaco/monaco_editor_model.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../data_sources/model/data_source.dart';
import '../../interop/monaco.dart'
    show
        CancellationToken,
        CompletionContext,
        CompletionItem,
        CompletionItemKind,
        CompletionList,
        Hover,
        IExpandedMonarchLanguageRule,
        IMarkdownString,
        IMonarchLanguage,
        ITextModel,
        Position,
        Range;
import '../../util/change_notifier.dart';
import '../model/embedding_template_config.dart';

final class TemplateEditorModel extends ChangeNotifierX
    implements
        MonacoCustomLanguage,
        MonacoCompletionItemProvider,
        MonacoHoverProvider {
  TemplateEditorModel({
    required ConfigurationManager configManager,
    EmbeddingTemplateConfig? initialTemplate,
  }) : _configManager = configManager,
       _initialTemplate = initialTemplate,
       _name = ValueNotifier(initialTemplate?.name ?? ''),
       _description = ValueNotifier(initialTemplate?.description ?? ''),
       _selectedDataSourceId = ValueNotifier(
         initialTemplate?.dataSourceId ?? '',
       );

  static final Logger _logger = Logger('TemplateEditor');

  final ConfigurationManager _configManager;
  final EmbeddingTemplateConfig? _initialTemplate;

  ConfigurationManager get configManager => _configManager;

  final ValueNotifier<String> _name;
  final ValueNotifier<String> _description;
  final ValueNotifier<String> _selectedDataSourceId;
  final ValueNotifier<String?> _error = ValueNotifier(null);

  late final MonacoEditorModel editor = MonacoEditorModel(
    containerId: 'template-editor',
    language: languageId,
    customLanguage: this,
    height: 400,
    initialValue: _initialTemplate?.template ?? _defaultTemplate,
  );

  DataSource? _currentDataSource;
  List<String> _schemaFields = [];
  Map<String, dynamic>? _sampleRow;
  bool _isLoading = false;

  static const String _defaultTemplate = '''// Create your embedding template
// Use {{field}} syntax to reference data fields
// Example: "Title: {{title}} Content: {{content}}"

{{title}} - {{description}}''';

  ValueListenable<String> get name => _name;
  ValueListenable<String> get description => _description;
  ValueListenable<String> get selectedDataSourceId => _selectedDataSourceId;
  ValueListenable<String?> get error => _error;
  List<String> get schemaFields => _schemaFields;
  Map<String, dynamic>? get sampleRow => _sampleRow;
  bool get isLoading => _isLoading;
  DataSource? get currentDataSource => _currentDataSource;

  void dismissError() {
    if (_error.value != null) {
      _error.value = null;
    }
  }

  Future<void> init() async {
    assert(!_isLoading);
    setState(() => _isLoading = true);
    try {
      _logger.fine(
        'Initializing template editor with template: $_initialTemplate',
      );
      await Future.wait([
        if (_initialTemplate != null)
          _loadDataSourceById(_initialTemplate.dataSourceId),
        editor.init(),
      ]);
    } catch (e) {
      _error.value = 'Initialization failed: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDataSourceById(String dataSourceId) async {
    try {
      _currentDataSource = _configManager.dataSources.get(dataSourceId);
      if (_currentDataSource == null) {
        _error.value = 'Data source not found: $dataSourceId';
        return;
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
      _error.value = 'Failed to load data source: $e';
    }
  }

  String get previewText {
    final templateText = editor.value.value;
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

      notifyListeners();
    }
  }

  bool validate() {
    return _name.value.isNotEmpty &&
        editor.value.value.isNotEmpty &&
        _selectedDataSourceId.value.isNotEmpty;
  }

  EmbeddingTemplateConfig createConfig(String id) {
    return EmbeddingTemplateConfig(
      id: id,
      name: _name.value,
      description: _description.value,
      template: editor.value.value,
      dataSourceId: _selectedDataSourceId.value,
      availableFields: List.of(_schemaFields),
      metadata: {},
      createdAt: _initialTemplate?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    if (disposed) {
      return;
    }
    _logger.fine('Disposing TemplateEditorModel');
    _name.dispose();
    _description.dispose();
    _selectedDataSourceId.dispose();
    editor.dispose();
    super.dispose();
  }

  // Monaco

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
  MonacoCompletionItemProvider? get completionItemProvider => this;

  @override
  MonacoHoverProvider? get hoverProvider => this;

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
    Range? wordRange;
    String? word;
    var i = 0;
    var nb = line.indexOf('{');
    while (nb >= 0) {
      final end = line.indexOf('}', nb);
      if (end < 0) {
        word = line.substring(nb);
        wordRange = Range(
          position.lineNumber,
          nb + 1,
          position.lineNumber,
          line.length + 1,
        );
        break;
      }
      if (position.column >= nb && position.column <= end + 1) {
        word = line.substring(nb, end + 1);
        wordRange = Range(
          position.lineNumber,
          nb + 1,
          position.lineNumber,
          end + 1,
        );
        break;
      }
      i = end + 1;
      nb = line.indexOf('{', i);
    }

    // Word does not start with '{', so no suggestions
    if (word == null) {
      return null;
    }

    final suggestions = _schemaFields
        .where((field) => '{{$field}}'.startsWith(word!))
        .toSet()
        .map(
          (field) => CompletionItem(
            label: '{{$field}}',
            kind: CompletionItemKind.Field,
            detail: 'Data field: $field',
            documentation: 'Insert field value for $field',
            insertText: '{{$field}}',
            range: wordRange,
          ),
        )
        .toList();
    return CompletionList(suggestions: suggestions);
  }

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
      if (_schemaFields.contains(fieldName)) {
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
