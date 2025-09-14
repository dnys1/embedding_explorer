import 'dart:js_interop';

import 'package:jaspr/browser.dart' show ValueListenable, ValueNotifier;
import 'package:logging/logging.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web/web.dart' as web;

import '../../interop/monaco.dart' hide Uri, RegExp;
import '../../util/change_notifier.dart';
import 'custom_language.dart';

/// Model for managing Monaco editor state and configuration
class MonacoEditorModel extends ChangeNotifierX {
  MonacoEditorModel({
    required String containerId,
    String? language,
    String? initialValue,
    String? theme,
    double? height,
    MonacoCustomLanguage? customLanguage,
    IStandaloneEditorConstructionOptions? options,
  }) : _containerId = containerId,
       _language = language ?? 'plaintext',
       _theme = theme ?? 'vs',
       _height = height ?? 300.0,
       _customLanguage = customLanguage,
       _options = options,
       _value = ValueNotifier(initialValue ?? '');

  static final Logger _logger = Logger('MonacoEditor');

  final String _containerId;
  final String _language;
  final String _theme;
  final double _height;
  final MonacoCustomLanguage? _customLanguage;
  final IStandaloneEditorConstructionOptions? _options;

  final ValueNotifier<String> _value;
  final ValueNotifier<bool> _isInitialized = ValueNotifier(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  IStandaloneCodeEditor? _editor;
  String? _error;

  // Getters
  String get containerId => _containerId;
  String get language => _language;
  String get theme => _theme;
  double get height => _height;
  MonacoCustomLanguage? get customLanguage => _customLanguage;
  IStandaloneEditorConstructionOptions? get options => _options;

  ValueListenable<String> get value => _value;
  ValueListenable<bool> get isInitialized => _isInitialized;
  ValueListenable<bool> get isLoading => _isLoading;

  IStandaloneCodeEditor? get editor => _editor;
  String? get error => _error;

  /// Initialize the Monaco editor
  Future<void> init() async {
    if (_isInitialized.value || _isLoading.value) return;

    setState(() {
      _isLoading.value = true;
      _error = null;
    });

    try {
      // Ensure Monaco is loaded
      await monaco.loadModule();

      // Wait for the container to be available
      final container = web.document.getElementById(_containerId);
      if (container == null) {
        throw Exception('Editor container not found (#$_containerId)');
      }

      _logger.info('Initializing Monaco editor in container: $_containerId');

      // Register custom language if provided
      if (_customLanguage case final customLanguage?) {
        _registerCustomLanguage(customLanguage);
      }

      // Create editor with default options or custom options
      final editorOptions =
          _options ??
          IStandaloneEditorConstructionOptions(
            value: _value.value,
            language: _language,
            theme: _theme,
            automaticLayout: true,
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
          );

      _editor = monaco.editor.create(container, editorOptions);

      // Listen for content changes
      final contentChanges = _editor!.onDidChangeModelContent.stream.debounce(
        const Duration(milliseconds: 300),
      );
      final changeSub = contentChanges.listen((e) {
        final newValue = _editor!.getValue();
        if (_value.value != newValue) {
          _value.value = newValue;
          notifyListeners();
        }
      });
      _editor!.onDidDispose((_) {
        _logger.fine('Monaco editor disposed');
        changeSub.cancel();
      });

      setState(() => _isInitialized.value = true);
      _logger.info('Monaco editor initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize editor: $e';
      _logger.severe('Failed to initialize Monaco editor', e);
    } finally {
      setState(() => _isLoading.value = false);
    }
  }

  void _registerCustomLanguage(MonacoCustomLanguage language) {
    final languageId = language.languageId;

    // Register the language
    monaco.languages.register(ILanguageExtensionPoint(id: languageId));

    if (language.definition case final tokensProvider?) {
      monaco.languages.setMonarchTokensProvider(languageId, tokensProvider);
    }
    if (language.completionItemProvider case final completionProvider?) {
      monaco.languages.registerCompletionItemProvider(
        languageId,
        triggerCharacters: completionProvider.triggerCharacters,
        provideCompletionItems: completionProvider.provideCompletionItems,
      );
    }
    if (language.hoverProvider case final hoverProvider?) {
      monaco.languages.registerHoverProvider(
        languageId,
        provideHover: hoverProvider.provideHover,
      );
    }
  }

  /// Update the editor content programmatically
  void setValue(String newValue) {
    if (_value.value != newValue) {
      _value.value = newValue;
      if (_isInitialized.value && _editor != null) {
        _editor!.setValue(newValue);
      }
      notifyListeners();
    }
  }

  /// Get the current editor content
  String getValue() {
    return _value.value;
  }

  /// Insert text at the current cursor position
  void insertText(String text) {
    if (_isInitialized.value && _editor != null) {
      final selection = _editor!.getSelection();
      if (selection != null) {
        _editor!.trigger('keyboard', 'type', {'text': text}.jsify());
        _editor!.focus();
      }
    }
  }

  /// Focus the editor
  void focus() {
    if (_isInitialized.value && _editor != null) {
      _editor!.focus();
    }
  }

  /// Layout the editor (call this when the container size changes)
  void layout() {
    if (_isInitialized.value && _editor != null) {
      _editor!.layout();
    }
  }

  /// Clear any error state
  void dismissError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  @override
  void dispose() {
    if (disposed) {
      return;
    }
    _logger.fine('Disposing MonacoEditorModel for $_containerId');
    _editor?.dispose();
    _value.dispose();
    _isInitialized.dispose();
    _isLoading.dispose();
    super.dispose();
  }
}
