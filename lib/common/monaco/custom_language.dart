import '../../interop/monaco.dart';

/// Definition for a custom language in Monaco Editor, including syntax highlighting,
/// autocomplete, and hover information.
abstract class MonacoCustomLanguage {
  /// The unique identifier for the custom language.
  String get languageId;

  /// A Monarch language definition for syntax highlighting.
  IMonarchLanguage? get definition;

  /// Optional completion item provider for IntelliSense/autocomplete.
  MonacoCompletionItemProvider? get completionItemProvider;

  /// Optional hover provider for displaying information on hover.
  MonacoHoverProvider? get hoverProvider;
}

/// The completion item provider interface defines the contract between
/// extensions and
/// the
/// [IntelliSense](https://code.visualstudio.com/docs/editor/intellisense).
///
/// When computing *complete* completion items is expensive, providers can
/// optionally implement
/// the `resolveCompletionItem`-function. In that case it is enough to return
/// completion
/// items with a CompletionItem.labellabel from the
/// CompletionItemProvider.provideCompletionItemsprovideCompletionItems-function.
/// Subsequently,
/// when a completion item is shown in the UI and gains focus this provider is
/// asked to resolve
/// the item, like adding CompletionItem.documentationdoc-comment or
/// CompletionItem.detaildetails.
abstract class MonacoCompletionItemProvider {
  List<String> get triggerCharacters;

  /// Provide completion items for the given position and document.
  CompletionList? provideCompletionItems(
    ITextModel model,
    Position position,
    CompletionContext context,
    CancellationToken token,
  );
}

/// The hover provider interface defines the contract between extensions and
/// the
/// [hover](https://code.visualstudio.com/docs/editor/intellisense)-feature.
abstract class MonacoHoverProvider {
  /// Provide a hover for the given position, context and document. Multiple
  /// hovers at the same
  /// position will be merged by the editor. A hover can have a range which
  /// defaults
  /// to the word range at the position when omitted.
  Hover? provideHover(
    ITextModel model,
    Position position,
    CancellationToken token,
  );
}
