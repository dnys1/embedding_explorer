// ignore_for_file: camel_case_types, constant_identifier_names
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names, unnecessary_parenthesis

// ignore_for_file: no_leading_underscores_for_library_prefixes
@JS('monaco')
library;

import 'dart:core' as core show Uri;
import 'dart:core';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/meta.dart' as _i2;
import 'package:web/web.dart' as _i3;

import '_tuples.dart' as _i4;

@JS()
external MonacoEditor get editor;

@JS()
external MonacoLanguages get languages;

Future<void> loadModule() async {
  if (globalContext['monaco'].isDefinedAndNotNull) {
    return;
  }
  final monacoUri = core.Uri.base.resolve('./js/monaco.js').toString();
  await importModule(monacoUri.toJS).toDart;
  assert(globalContext['monaco'].isDefinedAndNotNull);
}

/// Monaco Editor main API
extension type MonacoEditor._(JSObject _) implements JSObject {
  /// Creates a new editor instance
  external IStandaloneCodeEditor create(
    JSObject container,
    IStandaloneEditorConstructionOptions? options,
  );

  /// Creates a diff editor instance
  external IStandaloneDiffEditor createDiffEditor(
    JSObject container,
    IStandaloneDiffEditorConstructionOptions? options,
  );

  /// Creates a model for the editor
  external ITextModel createModel(String value, String? language, JSAny? uri);

  /// Gets all available themes
  external JSArray<JSString> getThemes();

  /// Defines a new theme
  external void defineTheme(String themeName, IStandaloneThemeData themeData);

  /// Sets the current theme
  external void setTheme(String themeName);
}

/// Monaco Languages API for custom language support
extension type MonacoLanguages._(JSObject _) implements JSObject {
  /// Registers a new language
  external void register(ILanguageExtensionPoint language);

  /// Sets the monarch tokens provider for a language
  external void setMonarchTokensProvider(
    String languageId,
    IMonarchLanguage monarchLanguage,
  );

  /// Sets the completion item provider for a language
  @JS('registerCompletionItemProvider')
  external void _registerCompletionItemProvider(
    String languageId,
    CompletionItemProvider provider,
  );

  void registerCompletionItemProvider(
    String languageId, {
    required List<String> triggerCharacters,
    required CompletionList? Function(
      ITextModel model,
      Position position,
      CompletionContext context,
      CancellationToken token,
    )
    provideCompletionItems,
  }) {
    _registerCompletionItemProvider(
      languageId,
      CompletionItemProvider(
        triggerCharacters: triggerCharacters.map((it) => it.toJS).toList().toJS,
        provideCompletionItems: provideCompletionItems.toJS,
      ),
    );
  }

  /// Sets the hover provider for a language
  @JS('registerHoverProvider')
  external void _registerHoverProvider(
    String languageId,
    HoverProvider provider,
  );

  void registerHoverProvider(
    String languageId, {
    required Hover? Function(
      ITextModel model,
      Position position,
      CancellationToken token,
    )
    provideHover,
  }) {
    _registerHoverProvider(
      languageId,
      HoverProvider(provideHover: provideHover.toJS),
    );
  }

  /// Sets the signature help provider for a language
  external void registerSignatureHelpProvider(
    String languageId,
    SignatureHelpProvider provider,
  );

  /// Gets all registered languages
  external JSArray<ILanguageExtensionPoint> getLanguages();
}

extension type ITrustedTypePolicyOptions._(JSObject _) implements JSObject {
  external _AnonymousFunction_9009365? createHTML;

  external _AnonymousFunction_9009365? createScript;

  external _AnonymousFunction_9009365? createScriptURL;
}
extension type ITrustedTypePolicy._(JSObject _) implements JSObject {
  external String get name;
  external JSFunction? get createHTML;
  external JSFunction? get createScript;
  external JSFunction? get createScriptURL;
}
extension type Environment._(JSObject _) implements JSObject {
  /// Define a global `monaco` symbol.
  /// This is true by default in AMD and false by default in ESM.
  external bool? globalAPI;

  /// The base url where the editor sources are found (which contains the vs
  /// folder)
  external String? baseUrl;

  /// A web worker factory.
  /// NOTE: If `getWorker` is defined, `getWorkerUrl` is not invoked.
  external JSFunction? get getWorker;

  /// Return the location for web worker scripts.
  /// NOTE: If `getWorker` is defined, `getWorkerUrl` is not invoked.
  external JSFunction? get getWorkerUrl;

  /// Create a trusted types policy (same API as
  /// window.trustedTypes.createPolicy)
  external JSFunction? get createTrustedTypesPolicy;
}
extension type IDisposable._(JSObject _) implements JSObject {
  external JSAny? dispose();
}
extension type IEvent<T extends JSAny?>._(JSObject _) implements JSObject {
  @JS('call')
  external IDisposable _call(JSAny? thisArg, JSFunction listener);

  IDisposable call(void Function(T) listener) => _call(null, listener.toJS);
}
extension type CancellationToken._(JSObject _) implements JSObject {
  /// A flag signalling is cancellation has been requested.
  external bool get isCancellationRequested;

  /// An event which fires when cancellation is requested. This event
  /// only ever fires `once` as cancellation can only happen once. Listeners
  /// that are registered after cancellation will be called (next event loop
  /// run),
  /// but also only once.
  external _AnonymousFunction_1135486 get onCancellationRequested;
}
extension type UriComponents._(JSObject _) implements JSObject {
  external String scheme;

  external String? authority;

  external String? path;

  external String? query;

  external String? fragment;
}

/// Uniform Resource Identifier (Uri) http://tools.ietf.org/html/rfc3986.
/// This class is a simple parser which creates the basic component parts
/// (http://tools.ietf.org/html/rfc3986#section-3) with minimal validation
/// and encoding.
///
/// ```txt
///       foo://example.com:8042/over/there?name=ferret#nose
///       \_/   \______________/\_________/ \_________/ \__/
///        |           |            |            |        |
///     scheme     authority       path        query   fragment
///        |   _____________________|__
///       / \ /                        \
///       urn:example:animal:ferret:nose
/// ```
extension type Uri._(JSObject _) implements UriComponents {
  external Uri();

  /// scheme is the 'http' part of
  /// 'http://www.example.com/some/path?query#fragment'.
  /// The part before the first colon.
  @_i2.redeclare
  external String get scheme;

  /// authority is the 'www.example.com' part of
  /// 'http://www.example.com/some/path?query#fragment'.
  /// The part between the first double slashes and the next slash.
  @_i2.redeclare
  external String get authority;

  /// path is the '/some/path' part of
  /// 'http://www.example.com/some/path?query#fragment'.
  @_i2.redeclare
  external String get path;

  /// query is the 'query' part of
  /// 'http://www.example.com/some/path?query#fragment'.
  @_i2.redeclare
  external String get query;

  /// fragment is the 'fragment' part of
  /// 'http://www.example.com/some/path?query#fragment'.
  @_i2.redeclare
  external String get fragment;
  external static JSAny isUri(JSAny? thing);

  /// Returns a string representing the corresponding file system path of this
  /// Uri.
  /// Will handle UNC paths, normalizes windows drive letters to lower-case, and
  /// uses the
  /// platform specific path separator.
  ///
  /// * Will *not* validate the path for invalid characters and semantics.
  /// * Will *not* look at the scheme of this Uri.
  /// * The result shall *not* be used for display purposes but for accessing a
  /// file on disk.
  ///
  ///
  /// The *difference* to `Uri#path` is the use of the platform specific
  /// separator and the handling
  /// of UNC paths. See the below sample of a file-uri with an authority (UNC
  /// path).
  ///
  /// ```ts
  ///  const u = Uri.parse('file://server/c$/folder/file.txt')
  ///  u.authority === 'server'
  ///  u.path === '/shares/c$/file.txt'
  ///  u.fsPath === '\\server\c$\folder\file.txt'
  /// ```
  ///
  /// Using `Uri#path` to read a file (using fs-apis) would not be enough
  /// because parts of the path,
  /// namely the server name, would be missing. Therefore `Uri#fsPath` exists -
  /// it's sugar to ease working
  /// with URIs that represent files on disk (`file` scheme).
  external String get fsPath;
  @JS('with')
  external Uri with$(AnonymousType_1126581 change);

  /// Creates a new Uri from a string, e.g. `http://www.example.com/some/path`,
  /// `file:///usr/home`, or `scheme:with/path`.
  /// - [value]:  A string which represents an Uri (see `Uri#toString`).
  external static Uri parse(String value, [bool? strict]);

  /// Creates a new Uri from a file system path, e.g. `c:\my\files`,
  /// `/usr/home`, or `\\server\share\some\path`.
  ///
  /// The *difference* between `Uri#parse` and `Uri#file` is that the latter
  /// treats the argument
  /// as path, not as stringified-uri. E.g. `Uri.file(path)` is **not the same
  /// as**
  /// `Uri.parse('file://' + path)` because the path might contain characters
  /// that are
  /// interpreted (# and ?). See the following sample:
  /// ```ts
  /// const good = Uri.file('/coding/c#/project1');
  /// good.scheme === 'file';
  /// good.path === '/coding/c#/project1';
  /// good.fragment === '';
  /// const bad = Uri.parse('file://' + '/coding/c#/project1');
  /// bad.scheme === 'file';
  /// bad.path === '/coding/c'; // path is now broken
  /// bad.fragment === '/project1';
  /// ```
  /// - [path]:  A file system path (see `Uri#fsPath`)
  external static Uri file(String path);

  /// Creates new Uri from uri components.
  ///
  /// Unless `strict` is `true` the scheme is defaults to be `file`. This
  /// function performs
  /// validation and should be used for untrusted uri components retrieved from
  /// storage,
  /// user input, command arguments etc
  external static Uri from(UriComponents components, [bool? strict]);

  /// Join a Uri path with path fragments and normalizes the resulting path.
  /// - [uri]:  The input Uri.
  /// - [pathFragment]:  The path fragment to add to the Uri path.
  ///
  /// Returns The resulting Uri.
  external static Uri joinPath(
    Uri uri,
    JSArray<JSString> pathFragment, [
    JSArray<JSString> pathFragment2,
    JSArray<JSString> pathFragment3,
    JSArray<JSString> pathFragment4,
    JSArray<JSString> pathFragment5,
    JSArray<JSString> pathFragment6,
    JSArray<JSString> pathFragment7,
    JSArray<JSString> pathFragment8,
  ]);

  /// Creates a string representation for this Uri. It's guaranteed that calling
  /// `Uri.parse` with the result of this function creates an Uri which is equal
  /// to this Uri.
  ///
  /// * The result shall *not* be used for display purposes but for
  /// externalization or transport.
  /// * The result will be encoded using the percentage encoding and encoding
  /// happens mostly
  /// ignore the scheme-specific encoding rules.
  /// - [skipEncoding]:  Do not encode the result, default is `false`
  @JS('toString')
  external String toString$([bool? skipEncoding]);
  external UriComponents toJSON();

  /// A helper function to revive URIs.
  ///
  /// **Note** that this function should only be used when receiving Uri#toJSON
  /// generated data
  /// and that it doesn't do any validation. Use Uri.from when received
  /// "untrusted"
  /// uri components such as command arguments or data from storage.
  /// - [data]:  The Uri components or Uri to revive.
  ///
  /// Returns The revived Uri or undefined or null.
  external static Uri revive(AnonymousUnion_4256847 data);

  /// A helper function to revive URIs.
  ///
  /// **Note** that this function should only be used when receiving Uri#toJSON
  /// generated data
  /// and that it doesn't do any validation. Use Uri.from when received
  /// "untrusted"
  /// uri components such as command arguments or data from storage.
  /// - [data]:  The Uri components or Uri to revive.
  ///
  /// Returns The revived Uri or undefined or null.
  @JS('revive')
  external static JSAny? revive$1(AnonymousUnion_4256847 data);

  /// A helper function to revive URIs.
  ///
  /// **Note** that this function should only be used when receiving Uri#toJSON
  /// generated data
  /// and that it doesn't do any validation. Use Uri.from when received
  /// "untrusted"
  /// uri components such as command arguments or data from storage.
  /// - [data]:  The Uri components or Uri to revive.
  ///
  /// Returns The revived Uri or undefined or null.
  @JS('revive')
  external static JSAny? revive$2(AnonymousUnion_4256847 data);

  /// A helper function to revive URIs.
  ///
  /// **Note** that this function should only be used when receiving Uri#toJSON
  /// generated data
  /// and that it doesn't do any validation. Use Uri.from when received
  /// "untrusted"
  /// uri components such as command arguments or data from storage.
  /// - [data]:  The Uri components or Uri to revive.
  ///
  /// Returns The revived Uri or undefined or null.
  @JS('revive')
  external static JSAny? revive$3(AnonymousUnion_4256847 data);
}
extension type MarkdownStringTrustedOptions._(JSObject _) implements JSObject {
  external JSArray<JSString> get enabledCommands;
}

/// Virtual Key Codes, the value does not hold any inherent meaning.
/// Inspired somewhat from
/// https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
/// But these are "more general", as they should work across browsers & OS`s.
extension type const KeyCode._(int _) {
  static const KeyCode DependsOnKbLayout = KeyCode._(-1);

  /// Placed first to cover the 0 value of the enum.
  static const KeyCode Unknown = KeyCode._(0);

  static const KeyCode Backspace = KeyCode._(1);

  static const KeyCode Tab = KeyCode._(2);

  static const KeyCode Enter = KeyCode._(3);

  static const KeyCode Shift = KeyCode._(4);

  static const KeyCode Ctrl = KeyCode._(5);

  static const KeyCode Alt = KeyCode._(6);

  static const KeyCode PauseBreak = KeyCode._(7);

  static const KeyCode CapsLock = KeyCode._(8);

  static const KeyCode Escape = KeyCode._(9);

  static const KeyCode Space = KeyCode._(10);

  static const KeyCode PageUp = KeyCode._(11);

  static const KeyCode PageDown = KeyCode._(12);

  static const KeyCode End = KeyCode._(13);

  static const KeyCode Home = KeyCode._(14);

  static const KeyCode LeftArrow = KeyCode._(15);

  static const KeyCode UpArrow = KeyCode._(16);

  static const KeyCode RightArrow = KeyCode._(17);

  static const KeyCode DownArrow = KeyCode._(18);

  static const KeyCode Insert = KeyCode._(19);

  static const KeyCode Delete = KeyCode._(20);

  static const KeyCode Digit0 = KeyCode._(21);

  static const KeyCode Digit1 = KeyCode._(22);

  static const KeyCode Digit2 = KeyCode._(23);

  static const KeyCode Digit3 = KeyCode._(24);

  static const KeyCode Digit4 = KeyCode._(25);

  static const KeyCode Digit5 = KeyCode._(26);

  static const KeyCode Digit6 = KeyCode._(27);

  static const KeyCode Digit7 = KeyCode._(28);

  static const KeyCode Digit8 = KeyCode._(29);

  static const KeyCode Digit9 = KeyCode._(30);

  static const KeyCode KeyA = KeyCode._(31);

  static const KeyCode KeyB = KeyCode._(32);

  static const KeyCode KeyC = KeyCode._(33);

  static const KeyCode KeyD = KeyCode._(34);

  static const KeyCode KeyE = KeyCode._(35);

  static const KeyCode KeyF = KeyCode._(36);

  static const KeyCode KeyG = KeyCode._(37);

  static const KeyCode KeyH = KeyCode._(38);

  static const KeyCode KeyI = KeyCode._(39);

  static const KeyCode KeyJ = KeyCode._(40);

  static const KeyCode KeyK = KeyCode._(41);

  static const KeyCode KeyL = KeyCode._(42);

  static const KeyCode KeyM = KeyCode._(43);

  static const KeyCode KeyN = KeyCode._(44);

  static const KeyCode KeyO = KeyCode._(45);

  static const KeyCode KeyP = KeyCode._(46);

  static const KeyCode KeyQ = KeyCode._(47);

  static const KeyCode KeyR = KeyCode._(48);

  static const KeyCode KeyS = KeyCode._(49);

  static const KeyCode KeyT = KeyCode._(50);

  static const KeyCode KeyU = KeyCode._(51);

  static const KeyCode KeyV = KeyCode._(52);

  static const KeyCode KeyW = KeyCode._(53);

  static const KeyCode KeyX = KeyCode._(54);

  static const KeyCode KeyY = KeyCode._(55);

  static const KeyCode KeyZ = KeyCode._(56);

  static const KeyCode Meta = KeyCode._(57);

  static const KeyCode ContextMenu = KeyCode._(58);

  static const KeyCode F1 = KeyCode._(59);

  static const KeyCode F2 = KeyCode._(60);

  static const KeyCode F3 = KeyCode._(61);

  static const KeyCode F4 = KeyCode._(62);

  static const KeyCode F5 = KeyCode._(63);

  static const KeyCode F6 = KeyCode._(64);

  static const KeyCode F7 = KeyCode._(65);

  static const KeyCode F8 = KeyCode._(66);

  static const KeyCode F9 = KeyCode._(67);

  static const KeyCode F10 = KeyCode._(68);

  static const KeyCode F11 = KeyCode._(69);

  static const KeyCode F12 = KeyCode._(70);

  static const KeyCode F13 = KeyCode._(71);

  static const KeyCode F14 = KeyCode._(72);

  static const KeyCode F15 = KeyCode._(73);

  static const KeyCode F16 = KeyCode._(74);

  static const KeyCode F17 = KeyCode._(75);

  static const KeyCode F18 = KeyCode._(76);

  static const KeyCode F19 = KeyCode._(77);

  static const KeyCode F20 = KeyCode._(78);

  static const KeyCode F21 = KeyCode._(79);

  static const KeyCode F22 = KeyCode._(80);

  static const KeyCode F23 = KeyCode._(81);

  static const KeyCode F24 = KeyCode._(82);

  static const KeyCode NumLock = KeyCode._(83);

  static const KeyCode ScrollLock = KeyCode._(84);

  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the ';:' key
  static const KeyCode Semicolon = KeyCode._(85);

  /// For any country/region, the '+' key
  /// For the US standard keyboard, the '=+' key
  static const KeyCode Equal = KeyCode._(86);

  /// For any country/region, the ',' key
  /// For the US standard keyboard, the ',<' key
  static const KeyCode Comma = KeyCode._(87);

  /// For any country/region, the '-' key
  /// For the US standard keyboard, the '-_' key
  static const KeyCode Minus = KeyCode._(88);

  /// For any country/region, the '.' key
  /// For the US standard keyboard, the '.>' key
  static const KeyCode Period = KeyCode._(89);

  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '/?' key
  static const KeyCode Slash = KeyCode._(90);

  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '`~' key
  static const KeyCode Backquote = KeyCode._(91);

  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '[{' key
  static const KeyCode BracketLeft = KeyCode._(92);

  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the '\|' key
  static const KeyCode Backslash = KeyCode._(93);

  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the ']}' key
  static const KeyCode BracketRight = KeyCode._(94);

  /// Used for miscellaneous characters; it can vary by keyboard.
  /// For the US standard keyboard, the ''"' key
  static const KeyCode Quote = KeyCode._(95);

  /// Used for miscellaneous characters; it can vary by keyboard.
  static const KeyCode OEM_8 = KeyCode._(96);

  /// Either the angle bracket key or the backslash key on the RT 102-key
  /// keyboard.
  static const KeyCode IntlBackslash = KeyCode._(97);

  static const KeyCode Numpad0 = KeyCode._(98);

  static const KeyCode Numpad1 = KeyCode._(99);

  static const KeyCode Numpad2 = KeyCode._(100);

  static const KeyCode Numpad3 = KeyCode._(101);

  static const KeyCode Numpad4 = KeyCode._(102);

  static const KeyCode Numpad5 = KeyCode._(103);

  static const KeyCode Numpad6 = KeyCode._(104);

  static const KeyCode Numpad7 = KeyCode._(105);

  static const KeyCode Numpad8 = KeyCode._(106);

  static const KeyCode Numpad9 = KeyCode._(107);

  static const KeyCode NumpadMultiply = KeyCode._(108);

  static const KeyCode NumpadAdd = KeyCode._(109);

  static const KeyCode NUMPAD_SEPARATOR = KeyCode._(110);

  static const KeyCode NumpadSubtract = KeyCode._(111);

  static const KeyCode NumpadDecimal = KeyCode._(112);

  static const KeyCode NumpadDivide = KeyCode._(113);

  /// Cover all key codes when IME is processing input.
  static const KeyCode KEY_IN_COMPOSITION = KeyCode._(114);

  static const KeyCode ABNT_C1 = KeyCode._(115);

  static const KeyCode ABNT_C2 = KeyCode._(116);

  static const KeyCode AudioVolumeMute = KeyCode._(117);

  static const KeyCode AudioVolumeUp = KeyCode._(118);

  static const KeyCode AudioVolumeDown = KeyCode._(119);

  static const KeyCode BrowserSearch = KeyCode._(120);

  static const KeyCode BrowserHome = KeyCode._(121);

  static const KeyCode BrowserBack = KeyCode._(122);

  static const KeyCode BrowserForward = KeyCode._(123);

  static const KeyCode MediaTrackNext = KeyCode._(124);

  static const KeyCode MediaTrackPrevious = KeyCode._(125);

  static const KeyCode MediaStop = KeyCode._(126);

  static const KeyCode MediaPlayPause = KeyCode._(127);

  static const KeyCode LaunchMediaPlayer = KeyCode._(128);

  static const KeyCode LaunchMail = KeyCode._(129);

  static const KeyCode LaunchApp2 = KeyCode._(130);

  /// VK_CLEAR, 0x0C, CLEAR key
  static const KeyCode Clear = KeyCode._(131);

  /// Placed last to cover the length of the enum.
  /// Please do not depend on this value!
  static const KeyCode MAX_VALUE = KeyCode._(132);
}

/// A position in the editor. This interface is suitable for serialization.
extension type IPosition._(JSObject _) implements JSObject {
  /// line number (starts at 1)
  external double get lineNumber;

  /// column (the first character in a line is between column 1 and column 2)
  external double get column;
}

/// A range in the editor. This interface is suitable for serialization.
extension type IRange._(JSObject _) implements JSObject {
  /// Line number on which the range starts (starts at 1).
  external double get startLineNumber;

  /// Column on which the range starts in line `startLineNumber` (starts at 1).
  external double get startColumn;

  /// Line number on which the range ends.
  external double get endLineNumber;

  /// Column on which the range ends in line `endLineNumber`.
  external double get endColumn;
}

/// A position in the editor.
extension type Position._(JSObject _) implements IPosition, JSObject {
  external Position(num lineNumber, num column);

  /// line number (starts at 1)
  external int get lineNumber;

  /// column (the first character in a line is between column 1 and column 2)
  external int get column;

  /// Create a new position from this position.
  /// - [newLineNumber]:  new line number
  /// - [newColumn]:  new column
  @JS('with')
  external Position with$([num? newLineNumber, num? newColumn]);

  /// Derive a new position from this position.
  /// - [deltaLineNumber]:  line number delta
  /// - [deltaColumn]:  column delta
  external Position delta([num? deltaLineNumber, num? deltaColumn]);

  /// Test if this position equals other position
  external bool equals(IPosition other);

  /// Test if position `a` equals position `b`
  @JS('equals')
  external static bool equals$1(IPosition? a, IPosition? b);

  /// Test if this position is before other position.
  /// If the two positions are equal, the result will be false.
  external bool isBefore(IPosition other);

  /// Test if position `a` is before position `b`.
  /// If the two positions are equal, the result will be false.
  @JS('isBefore')
  external static bool isBefore$1(IPosition a, IPosition b);

  /// Test if this position is before other position.
  /// If the two positions are equal, the result will be true.
  external bool isBeforeOrEqual(IPosition other);

  /// Test if position `a` is before position `b`.
  /// If the two positions are equal, the result will be true.
  @JS('isBeforeOrEqual')
  external static bool isBeforeOrEqual$1(IPosition a, IPosition b);

  /// A function that compares positions, useful for sorting
  external static double compare(IPosition a, IPosition b);

  /// Clone this position.
  external Position clone();

  /// Convert to a human-readable representation.
  @JS('toString')
  external String toString$();

  /// Create a `Position` from an `IPosition`.
  external static Position lift(IPosition pos);

  /// Test if `obj` is an `IPosition`.
  external static JSAny isIPosition(JSAny? obj);
  external IPosition toJSON();
}

/// A range in the editor. (startLineNumber,startColumn) is <=
/// (endLineNumber,endColumn)
extension type Range._(JSObject _) implements IRange, JSObject {
  external Range(
    num startLineNumber,
    num startColumn,
    num endLineNumber,
    num endColumn,
  );

  /// Line number on which the range starts (starts at 1).
  external double get startLineNumber;

  /// Column on which the range starts in line `startLineNumber` (starts at 1).
  external double get startColumn;

  /// Line number on which the range ends.
  external double get endLineNumber;

  /// Column on which the range ends in line `endLineNumber`.
  external double get endColumn;

  /// Test if this range is empty.
  external bool isEmpty();

  /// Test if `range` is empty.
  @JS('isEmpty')
  external static bool isEmpty$1(IRange range);

  /// Test if position is in this range. If the position is at the edges, will
  /// return true.
  external bool containsPosition(IPosition position);

  /// Test if `position` is in `range`. If the position is at the edges, will
  /// return true.
  @JS('containsPosition')
  external static bool containsPosition$1(IRange range, IPosition position);

  /// Test if range is in this range. If the range is equal to this range, will
  /// return true.
  external bool containsRange(IRange range);

  /// Test if `otherRange` is in `range`. If the ranges are equal, will return
  /// true.
  @JS('containsRange')
  external static bool containsRange$1(IRange range, IRange otherRange);

  /// Test if `range` is strictly in this range. `range` must start after and
  /// end before this range for the result to be true.
  external bool strictContainsRange(IRange range);

  /// Test if `otherRange` is strictly in `range` (must start after, and end
  /// before). If the ranges are equal, will return false.
  @JS('strictContainsRange')
  external static bool strictContainsRange$1(IRange range, IRange otherRange);

  /// A reunion of the two ranges.
  /// The smallest position will be used as the start point, and the largest one
  /// as the end point.
  external Range plusRange(IRange range);

  /// A reunion of the two ranges.
  /// The smallest position will be used as the start point, and the largest one
  /// as the end point.
  @JS('plusRange')
  external static Range plusRange$1(IRange a, IRange b);

  /// A intersection of the two ranges.
  external JSAny? intersectRanges(IRange range);

  /// A intersection of the two ranges.
  @JS('intersectRanges')
  external static JSAny? intersectRanges$1(IRange a, IRange b);

  /// Test if this range equals other.
  external bool equalsRange(IRange? other);

  /// Test if range `a` equals `b`.
  @JS('equalsRange')
  external static bool equalsRange$1(IRange? a, IRange? b);

  /// Return the end position (which will be after or equal to the start
  /// position)
  external Position getEndPosition();

  /// Return the end position (which will be after or equal to the start
  /// position)
  @JS('getEndPosition')
  external static Position getEndPosition$1(IRange range);

  /// Return the start position (which will be before or equal to the end
  /// position)
  external Position getStartPosition();

  /// Return the start position (which will be before or equal to the end
  /// position)
  @JS('getStartPosition')
  external static Position getStartPosition$1(IRange range);

  /// Transform to a user presentable string representation.
  @JS('toString')
  external String toString$();

  /// Create a new range using this range's start position, and using
  /// endLineNumber and endColumn as the end position.
  external Range setEndPosition(num endLineNumber, num endColumn);

  /// Create a new range using this range's end position, and using
  /// startLineNumber and startColumn as the start position.
  external Range setStartPosition(num startLineNumber, num startColumn);

  /// Create a new empty range using this range's start position.
  external Range collapseToStart();

  /// Create a new empty range using this range's start position.
  @JS('collapseToStart')
  external static Range collapseToStart$1(IRange range);

  /// Create a new empty range using this range's end position.
  external Range collapseToEnd();

  /// Create a new empty range using this range's end position.
  @JS('collapseToEnd')
  external static Range collapseToEnd$1(IRange range);

  /// Moves the range by the given amount of lines.
  external Range delta(num lineCount);
  external static Range fromPositions(IPosition start, [IPosition? end]);

  /// Create a `Range` from an `IRange`.
  external static JSAny lift(JSAny? range);

  /// Create a `Range` from an `IRange`.
  @JS('lift')
  external static Range lift$1(IRange range);

  /// Create a `Range` from an `IRange`.
  @JS('lift')
  external static JSAny? lift$2(IRange? range);

  /// Test if `obj` is an `IRange`.
  external static JSAny isIRange(JSAny? obj);

  /// Test if the two ranges are touching in any way.
  external static bool areIntersectingOrTouching(IRange a, IRange b);

  /// Test if the two ranges are intersecting. If the ranges are touching it
  /// returns true.
  external static bool areIntersecting(IRange a, IRange b);

  /// A function that compares ranges, useful for sorting ranges
  /// It will first compare ranges on the startPosition and then on the
  /// endPosition
  external static double compareRangesUsingStarts(IRange? a, IRange? b);

  /// A function that compares ranges, useful for sorting ranges
  /// It will first compare ranges on the endPosition and then on the
  /// startPosition
  external static double compareRangesUsingEnds(IRange a, IRange b);

  /// Test if the range spans multiple lines.
  external static bool spansMultipleLines(IRange range);
  external IRange toJSON();
}

/// A selection in the editor.
/// The selection is a range that has an orientation.
extension type ISelection._(JSObject _) implements JSObject {
  /// The line number on which the selection has started.
  external double get selectionStartLineNumber;

  /// The column on `selectionStartLineNumber` where the selection has started.
  external double get selectionStartColumn;

  /// The line number on which the selection has ended.
  external double get positionLineNumber;

  /// The column on `positionLineNumber` where the selection has ended.
  external double get positionColumn;
}

/// The direction of a selection.
extension type const SelectionDirection._(int _) {
  /// The selection starts above where it ends.
  static const SelectionDirection LTR = SelectionDirection._(0);

  /// The selection starts below where it ends.
  static const SelectionDirection RTL = SelectionDirection._(1);
}
extension type IRulerOption._(JSObject _) implements JSObject {
  external double get column;
  external String? get color;
}
typedef LineNumbersType = String;
extension type IMarkdownString._(JSObject _) implements JSObject {
  external factory IMarkdownString({
    String value,
    AnonymousUnion_1099144? isTrusted,
    bool? supportThemeIcons,
    bool? supportHtml,
    UriComponents? baseUri,
  });

  external AnonymousType_8718114? uris;

  external String get value;
  external AnonymousUnion_1099144? get isTrusted;
  external bool? get supportThemeIcons;
  external bool? get supportHtml;
  external UriComponents? get baseUri;
}

/// Configuration options for editor scrollbars
extension type IEditorScrollbarOptions._(JSObject _) implements JSObject {
  external factory IEditorScrollbarOptions({
    double? arrowSize,
    AnonymousUnion_1753152? vertical,
    AnonymousUnion_1753152? horizontal,
    bool? useShadows,
    bool? verticalHasArrows,
    bool? horizontalHasArrows,
    bool? handleMouseWheel,
    bool? alwaysConsumeMouseWheel,
    double? horizontalScrollbarSize,
    double? verticalScrollbarSize,
    double? verticalSliderSize,
    double? horizontalSliderSize,
    bool? scrollByPage,
    bool? ignoreHorizontalScrollbarInContentHeight,
  });

  /// The size of arrows (if displayed).
  /// Defaults to 11.
  /// **NOTE**: This option cannot be updated using `updateOptions()`
  external double? arrowSize;

  /// Render vertical scrollbar.
  /// Defaults to 'auto'.
  external AnonymousUnion_1753152? vertical;

  /// Render horizontal scrollbar.
  /// Defaults to 'auto'.
  external AnonymousUnion_1753152? horizontal;

  /// Cast horizontal and vertical shadows when the content is scrolled.
  /// Defaults to true.
  /// **NOTE**: This option cannot be updated using `updateOptions()`
  external bool? useShadows;

  /// Render arrows at the top and bottom of the vertical scrollbar.
  /// Defaults to false.
  /// **NOTE**: This option cannot be updated using `updateOptions()`
  external bool? verticalHasArrows;

  /// Render arrows at the left and right of the horizontal scrollbar.
  /// Defaults to false.
  /// **NOTE**: This option cannot be updated using `updateOptions()`
  external bool? horizontalHasArrows;

  /// Listen to mouse wheel events and react to them by scrolling.
  /// Defaults to true.
  external bool? handleMouseWheel;

  /// Always consume mouse wheel events (always call preventDefault() and
  /// stopPropagation() on the browser events).
  /// Defaults to true.
  /// **NOTE**: This option cannot be updated using `updateOptions()`
  external bool? alwaysConsumeMouseWheel;

  /// Height in pixels for the horizontal scrollbar.
  /// Defaults to 10 (px).
  external double? horizontalScrollbarSize;

  /// Width in pixels for the vertical scrollbar.
  /// Defaults to 10 (px).
  external double? verticalScrollbarSize;

  /// Width in pixels for the vertical slider.
  /// Defaults to `verticalScrollbarSize`.
  /// **NOTE**: This option cannot be updated using `updateOptions()`
  external double? verticalSliderSize;

  /// Height in pixels for the horizontal slider.
  /// Defaults to `horizontalScrollbarSize`.
  /// **NOTE**: This option cannot be updated using `updateOptions()`
  external double? horizontalSliderSize;

  /// Scroll gutter clicks move by page vs jump to position.
  /// Defaults to false.
  external bool? scrollByPage;

  /// When set, the horizontal scrollbar will not increase content height.
  /// Defaults to false.
  external bool? ignoreHorizontalScrollbarInContentHeight;
}
extension type IEditorStickyScrollOptions._(JSObject _) implements JSObject {
  /// Enable the sticky scroll
  external bool? enabled;

  /// Maximum number of sticky lines to show
  external double? maxLineCount;

  /// Model to choose for sticky scroll by default
  external AnonymousUnion_1641319? defaultModel;

  /// Define whether to scroll sticky scroll with editor horizontal scrollbae
  external bool? scrollWithEditor;
}

/// Configuration options for editor minimap
extension type IEditorMinimapOptions._(JSObject _) implements JSObject {
  external factory IEditorMinimapOptions({
    bool? enabled,
    bool? autohide,
    AnonymousUnion_1265516? side,
    AnonymousUnion_5814346? size,
    AnonymousUnion_7444867? showSlider,
    bool? renderCharacters,
    double? maxColumn,
    double? scale,
    bool? showRegionSectionHeaders,
    bool? showMarkSectionHeaders,
    double? sectionHeaderFontSize,
    double? sectionHeaderLetterSpacing,
  });

  /// Enable the rendering of the minimap.
  /// Defaults to true.
  external bool? enabled;

  /// Control the rendering of minimap.
  external bool? autohide;

  /// Control the side of the minimap in editor.
  /// Defaults to 'right'.
  external AnonymousUnion_1265516? side;

  /// Control the minimap rendering mode.
  /// Defaults to 'actual'.
  external AnonymousUnion_5814346? size;

  /// Control the rendering of the minimap slider.
  /// Defaults to 'mouseover'.
  external AnonymousUnion_7444867? showSlider;

  /// Render the actual text on a line (as opposed to color blocks).
  /// Defaults to true.
  external bool? renderCharacters;

  /// Limit the width of the minimap to render at most a certain number of
  /// columns.
  /// Defaults to 120.
  external double? maxColumn;

  /// Relative size of the font in the minimap. Defaults to 1.
  external double? scale;

  /// Whether to show named regions as section headers. Defaults to true.
  external bool? showRegionSectionHeaders;

  /// Whether to show MARK: comments as section headers. Defaults to true.
  external bool? showMarkSectionHeaders;

  /// Font size of section headers. Defaults to 9.
  external double? sectionHeaderFontSize;

  /// Spacing between the section header characters (in CSS px). Defaults to 1.
  external double? sectionHeaderLetterSpacing;
}

/// Configuration options for editor find widget
extension type IEditorFindOptions._(JSObject _) implements JSObject {
  /// Controls whether the cursor should move to find matches while typing.
  external bool? cursorMoveOnType;

  /// Controls if we seed search string in the Find Widget with editor
  /// selection.
  external AnonymousUnion_6317386? seedSearchStringFromSelection;

  /// Controls if Find in Selection flag is turned on in the editor.
  external AnonymousUnion_1372272? autoFindInSelection;

  external bool? addExtraSpaceOnTop;

  /// Controls whether the search result and diff result automatically restarts
  /// from the beginning (or the end) when no further matches can be found
  external bool? loop;
}

/// Configuration options for editor hover
extension type IEditorHoverOptions._(JSObject _) implements JSObject {
  /// Enable the hover.
  /// Defaults to true.
  external bool? enabled;

  /// Delay for showing the hover.
  /// Defaults to 300.
  external double? delay;

  /// Is the hover sticky such that it can be clicked and its contents selected?
  /// Defaults to true.
  external bool? sticky;

  /// Controls how long the hover is visible after you hovered out of it.
  /// Require sticky setting to be true.
  external double? hidingDelay;

  /// Should the hover be shown above the line if possible?
  /// Defaults to false.
  external bool? above;
}

/// Configuration options for editor comments
extension type IEditorCommentsOptions._(JSObject _) implements JSObject {
  /// Insert a space after the line comment token and inside the block comments
  /// tokens.
  /// Defaults to true.
  external bool? insertSpace;

  /// Ignore empty lines when inserting line comments.
  /// Defaults to true.
  external bool? ignoreEmptyLines;
}

/// Configuration options for editor suggest widget
extension type ISuggestOptions._(JSObject _) implements JSObject {
  external factory ISuggestOptions({
    bool? filterGraceful,
    bool? snippetsPreventQuickSuggestions,
    bool? localityBonus,
    bool? shareSuggestSelections,
    AnonymousUnion_1128509? selectionMode,
    bool? showIcons,
    bool? showStatusBar,
    bool? preview,
    AnonymousUnion_1305061? previewMode,
    bool? showInlineDetails,
    bool? showMethods,
    bool? showFunctions,
    bool? showConstructors,
    bool? showDeprecated,
    bool? matchOnWordStartOnly,
    bool? showFields,
    bool? showVariables,
    bool? showClasses,
    bool? showStructs,
    bool? showInterfaces,
    bool? showModules,
    bool? showProperties,
    bool? showEvents,
    bool? showOperators,
    bool? showUnits,
    bool? showValues,
    bool? showConstants,
    bool? showEnums,
    bool? showEnumMembers,
    bool? showKeywords,
    bool? showWords,
    bool? showColors,
    bool? showFiles,
    bool? showReferences,
    bool? showFolders,
    bool? showTypeParameters,
    bool? showIssues,
    bool? showUsers,
    bool? showSnippets,
    AnonymousUnion_1259071? insertMode,
  });

  /// Overwrite word ends on accept. Default to false.
  external AnonymousUnion_1259071? insertMode;

  /// Enable graceful matching. Defaults to true.
  external bool? filterGraceful;

  /// Prevent quick suggestions when a snippet is active. Defaults to true.
  external bool? snippetsPreventQuickSuggestions;

  /// Favors words that appear close to the cursor.
  external bool? localityBonus;

  /// Enable using global storage for remembering suggestions.
  external bool? shareSuggestSelections;

  /// Select suggestions when triggered via quick suggest or trigger characters
  external AnonymousUnion_1128509? selectionMode;

  /// Enable or disable icons in suggestions. Defaults to true.
  external bool? showIcons;

  /// Enable or disable the suggest status bar.
  external bool? showStatusBar;

  /// Enable or disable the rendering of the suggestion preview.
  external bool? preview;

  /// Configures the mode of the preview.
  external AnonymousUnion_1305061? previewMode;

  /// Show details inline with the label. Defaults to true.
  external bool? showInlineDetails;

  /// Show method-suggestions.
  external bool? showMethods;

  /// Show function-suggestions.
  external bool? showFunctions;

  /// Show constructor-suggestions.
  external bool? showConstructors;

  /// Show deprecated-suggestions.
  external bool? showDeprecated;

  /// Controls whether suggestions allow matches in the middle of the word
  /// instead of only at the beginning
  external bool? matchOnWordStartOnly;

  /// Show field-suggestions.
  external bool? showFields;

  /// Show variable-suggestions.
  external bool? showVariables;

  /// Show class-suggestions.
  external bool? showClasses;

  /// Show struct-suggestions.
  external bool? showStructs;

  /// Show interface-suggestions.
  external bool? showInterfaces;

  /// Show module-suggestions.
  external bool? showModules;

  /// Show property-suggestions.
  external bool? showProperties;

  /// Show event-suggestions.
  external bool? showEvents;

  /// Show operator-suggestions.
  external bool? showOperators;

  /// Show unit-suggestions.
  external bool? showUnits;

  /// Show value-suggestions.
  external bool? showValues;

  /// Show constant-suggestions.
  external bool? showConstants;

  /// Show enum-suggestions.
  external bool? showEnums;

  /// Show enumMember-suggestions.
  external bool? showEnumMembers;

  /// Show keyword-suggestions.
  external bool? showKeywords;

  /// Show text-suggestions.
  external bool? showWords;

  /// Show color-suggestions.
  external bool? showColors;

  /// Show file-suggestions.
  external bool? showFiles;

  /// Show reference-suggestions.
  external bool? showReferences;

  /// Show folder-suggestions.
  external bool? showFolders;

  /// Show typeParameter-suggestions.
  external bool? showTypeParameters;

  /// Show issue-suggestions.
  external bool? showIssues;

  /// Show user-suggestions.
  external bool? showUsers;

  /// Show snippet-suggestions.
  external bool? showSnippets;
}
extension type IInlineSuggestOptions._(JSObject _) implements JSObject {
  /// Enable or disable the rendering of automatic inline completions.
  external bool? enabled;

  /// Configures the mode.
  /// Use `prefix` to only show ghost text if the text to replace is a prefix of
  /// the suggestion text.
  /// Use `subword` to only show ghost text if the replace text is a subword of
  /// the suggestion text.
  /// Use `subwordSmart` to only show ghost text if the replace text is a
  /// subword of the suggestion text, but the subword must start after the
  /// cursor position.
  /// Defaults to `prefix`.
  external AnonymousUnion_1305061? mode;

  external AnonymousUnion_8388362? showToolbar;

  external bool? suppressSuggestions;

  /// Does not clear active inline suggestions when the editor loses focus.
  external bool? keepOnBlur;

  /// Font family for inline suggestions.
  external AnonymousUnion_1117146? fontFamily;
}
extension type IInlineEditOptions._(JSObject _) implements JSObject {
  /// Enable or disable the rendering of automatic inline edit.
  external bool? enabled;

  external AnonymousUnion_8388362? showToolbar;

  /// Font family for inline suggestions.
  external AnonymousUnion_1117146? fontFamily;

  /// Does not clear active inline suggestions when the editor loses focus.
  external bool? keepOnBlur;
}
extension type ISmartSelectOptions._(JSObject _) implements JSObject {
  external bool? selectLeadingAndTrailingWhitespace;

  external bool? selectSubwords;
}
typedef GoToLocationValues = AnonymousUnion_1533781;

/// Configuration options for go to location
extension type IGotoLocationOptions._(JSObject _) implements JSObject {
  external GoToLocationValues? multiple;

  external GoToLocationValues? multipleDefinitions;

  external GoToLocationValues? multipleTypeDefinitions;

  external GoToLocationValues? multipleDeclarations;

  external GoToLocationValues? multipleImplementations;

  external GoToLocationValues? multipleReferences;

  external GoToLocationValues? multipleTests;

  external String? alternativeDefinitionCommand;

  external String? alternativeTypeDefinitionCommand;

  external String? alternativeDeclarationCommand;

  external String? alternativeImplementationCommand;

  external String? alternativeReferenceCommand;

  external String? alternativeTestsCommand;
}
typedef QuickSuggestionsValue = AnonymousUnion_6911130;

/// Configuration options for quick suggestions
extension type IQuickSuggestionsOptions._(JSObject _) implements JSObject {}

/// Configuration options for editor padding
extension type IEditorPaddingOptions._(JSObject _) implements JSObject {
  /// Spacing between top edge of editor and first line.
  external double? top;

  /// Spacing between bottom edge of editor and last line.
  external double? bottom;
}

/// Configuration options for parameter hints
extension type IEditorParameterHintOptions._(JSObject _) implements JSObject {
  /// Enable parameter hints.
  /// Defaults to true.
  external bool? enabled;

  /// Enable cycling of parameter hints.
  /// Defaults to false.
  external bool? cycle;
}

/// Configuration options for auto closing quotes and brackets
typedef EditorAutoClosingStrategy = AnonymousUnion_1207780;

/// Configuration options for typing over closing quotes or brackets
typedef EditorAutoClosingEditStrategy = AnonymousUnion_4728824;

/// Configuration options for auto wrapping quotes and brackets
typedef EditorAutoSurroundStrategy = AnonymousUnion_2482489;
extension type const ShowLightbulbIconMode._(String _) {
  static const ShowLightbulbIconMode Off = ShowLightbulbIconMode._('off');

  static const ShowLightbulbIconMode OnCode = ShowLightbulbIconMode._('onCode');

  static const ShowLightbulbIconMode On = ShowLightbulbIconMode._('on');
}

/// Configuration options for editor lightbulb
extension type IEditorLightbulbOptions._(JSObject _) implements JSObject {
  /// Enable the lightbulb code action.
  /// The three possible values are `off`, `on` and `onCode` and the default is
  /// `onCode`.
  /// `off` disables the code action menu.
  /// `on` shows the code action menu on code and on empty lines.
  /// `onCode` shows the code action menu on code only.
  external ShowLightbulbIconMode? enabled;
}

/// Configuration options for editor inlayHints
extension type IEditorInlayHintsOptions._(JSObject _) implements JSObject {
  /// Enable the inline hints.
  /// Defaults to true.
  external AnonymousUnion_2815775? enabled;

  /// Font size of inline hints.
  /// Default to 90% of the editor font size.
  external double? fontSize;

  /// Font family of inline hints.
  /// Defaults to editor font family.
  external String? fontFamily;

  /// Enables the padding around the inlay hint.
  /// Defaults to false.
  external bool? padding;
}
extension type IGuidesOptions._(JSObject _) implements JSObject {
  /// Enable highlighting of the active bracket pair.
  /// Defaults to true.
  external bool? highlightActiveBracketPair;

  /// Enable rendering of indent guides.
  /// Defaults to true.
  external bool? indentation;
}
typedef InUntrustedWorkspace = String;

/// Configuration options for unicode highlighting.
extension type IUnicodeHighlightOptions._(JSObject _) implements JSObject {
  /// Controls whether characters that just reserve space or have no width at
  /// all are highlighted.
  external bool? invisibleCharacters;

  /// Controls whether characters are highlighted that can be confused with
  /// basic ASCII characters, except those that are common in the current user
  /// locale.
  external bool? ambiguousCharacters;
}
extension type IBracketPairColorizationOptions._(JSObject _)
    implements JSObject {
  /// Enable or disable bracket pair colorization.
  external bool? enabled;

  /// Use independent color pool per bracket type.
  external bool? independentColorPoolPerBracketType;
}

/// Configuration options for editor drop into behavior
extension type IDropIntoEditorOptions._(JSObject _) implements JSObject {
  /// Enable dropping into editor.
  /// Defaults to true.
  external bool? enabled;

  /// Controls if a widget is shown after a drop.
  /// Defaults to 'afterDrop'.
  external AnonymousUnion_4338314? showDropSelector;
}

/// Configuration options for editor pasting as into behavior
extension type IPasteAsOptions._(JSObject _) implements JSObject {
  /// Enable paste as functionality in editors.
  /// Defaults to true.
  external bool? enabled;

  /// Controls if a widget is shown after a drop.
  /// Defaults to 'afterPaste'.
  external AnonymousUnion_2852331? showPasteSelector;
}

/// Configuration options for the editor.
extension type IEditorOptions._(JSObject _) implements JSObject {
  /// This editor is used inside a diff editor.
  external bool? inDiffEditor;

  /// The aria label for the editor's textarea (when it is focused).
  external String? ariaLabel;

  /// Whether the aria-required attribute should be set on the editors textarea.
  external bool? ariaRequired;

  /// Control whether a screen reader announces inline suggestion content
  /// immediately.
  external bool? screenReaderAnnounceInlineSuggestion;

  /// The `tabindex` property of the editor's textarea
  external double? tabIndex;

  /// Locales used for segmenting lines into words when doing word related
  /// navigations or operations.
  ///
  /// Specify the BCP 47 language tag of the word you wish to recognize (e.g.,
  /// ja, zh-CN, zh-Hant-TW, etc.).
  /// Defaults to empty array
  external AnonymousUnion_8724622? wordSegmenterLocales;

  /// A string containing the word separators used when doing word navigation.
  /// Defaults to `~!@#$%^&*()-=+[{]}\\|;:\'",.<>/?
  external String? wordSeparators;

  /// Enable Linux primary clipboard.
  /// Defaults to true.
  external bool? selectionClipboard;

  /// Control the rendering of line numbers.
  /// If it is a function, it will be invoked when rendering a line number and
  /// the return value will be rendered.
  /// Otherwise, if it is a truthy, line numbers will be rendered normally
  /// (equivalent of using an identity function).
  /// Otherwise, line numbers will not be rendered.
  /// Defaults to `on`.
  external LineNumbersType? lineNumbers;

  /// Controls the minimal number of visible leading and trailing lines
  /// surrounding the cursor.
  /// Defaults to 0.
  external double? cursorSurroundingLines;

  /// Controls when `cursorSurroundingLines` should be enforced
  /// Defaults to `default`, `cursorSurroundingLines` is not enforced when
  /// cursor position is changed
  /// by mouse.
  external AnonymousUnion_5824844? cursorSurroundingLinesStyle;

  /// Render last line number when the file ends with a newline.
  /// Defaults to 'on' for Windows and macOS and 'dimmed' for Linux.
  external AnonymousUnion_1704253? renderFinalNewline;

  /// Remove unusual line terminators like LINE SEPARATOR (LS), PARAGRAPH
  /// SEPARATOR (PS).
  /// Defaults to 'prompt'.
  external AnonymousUnion_1421152? unusualLineTerminators;

  /// Should the corresponding line be selected when clicking on the line
  /// number?
  /// Defaults to true.
  external bool? selectOnLineNumbers;

  /// Control the width of line numbers, by reserving horizontal space for
  /// rendering at least an amount of digits.
  /// Defaults to 5.
  external double? lineNumbersMinChars;

  /// Enable the rendering of the glyph margin.
  /// Defaults to true in vscode and to false in monaco-editor.
  external bool? glyphMargin;

  /// The width reserved for line decorations (in px).
  /// Line decorations are placed between line numbers and the editor content.
  /// You can pass in a string in the format floating point followed by "ch".
  /// e.g. 1.3ch.
  /// Defaults to 10.
  external AnonymousUnion_1467782? lineDecorationsWidth;

  /// When revealing the cursor, a virtual padding (px) is added to the cursor,
  /// turning it into a rectangle.
  /// This virtual padding ensures that the cursor gets revealed before hitting
  /// the edge of the viewport.
  /// Defaults to 30 (px).
  external double? revealHorizontalRightPadding;

  /// Render the editor selection with rounded borders.
  /// Defaults to true.
  external bool? roundedSelection;

  /// Class name to be added to the editor.
  external String? extraEditorClassName;

  /// Should the editor be read only. See also `domReadOnly`.
  /// Defaults to false.
  external bool? readOnly;

  /// The message to display when the editor is readonly.
  external IMarkdownString? readOnlyMessage;

  /// Should the textarea used for input use the DOM `readonly` attribute.
  /// Defaults to false.
  external bool? domReadOnly;

  /// Enable linked editing.
  /// Defaults to false.
  external bool? linkedEditing;

  /// deprecated, use linkedEditing instead
  external bool? renameOnType;

  /// Should the editor render validation decorations.
  /// Defaults to editable.
  external AnonymousUnion_9690158? renderValidationDecorations;

  /// Control the behavior and rendering of the scrollbars.
  external IEditorScrollbarOptions? scrollbar;

  /// Control the behavior of sticky scroll options
  external IEditorStickyScrollOptions? stickyScroll;

  /// Control the behavior and rendering of the minimap.
  external IEditorMinimapOptions? minimap;

  /// Control the behavior of the find widget.
  external IEditorFindOptions? find;

  /// Display overflow widgets as `fixed`.
  /// Defaults to `false`.
  external bool? fixedOverflowWidgets;

  /// The number of vertical lanes the overview ruler should render.
  /// Defaults to 3.
  external double? overviewRulerLanes;

  /// Controls if a border should be drawn around the overview ruler.
  /// Defaults to `true`.
  external bool? overviewRulerBorder;

  /// Control the cursor animation style, possible values are 'blink', 'smooth',
  /// 'phase', 'expand' and 'solid'.
  /// Defaults to 'blink'.
  external AnonymousUnion_6445351? cursorBlinking;

  /// Zoom the font in the editor when using the mouse wheel in combination with
  /// holding Ctrl.
  /// Defaults to false.
  external bool? mouseWheelZoom;

  /// Control the mouse pointer style, either 'text' or 'default' or 'copy'
  /// Defaults to 'text'
  external AnonymousUnion_1276488? mouseStyle;

  /// Enable smooth caret animation.
  /// Defaults to 'off'.
  external AnonymousUnion_4883143? cursorSmoothCaretAnimation;

  /// Control the cursor style, either 'block' or 'line'.
  /// Defaults to 'line'.
  external AnonymousUnion_1155020? cursorStyle;

  /// Control the width of the cursor when cursorStyle is set to 'line'
  external double? cursorWidth;

  /// Enable font ligatures.
  /// Defaults to false.
  external AnonymousUnion_5411652? fontLigatures;

  /// Enable font variations.
  /// Defaults to false.
  external AnonymousUnion_5411652? fontVariations;

  /// Controls whether to use default color decorations or not using the default
  /// document color provider
  external bool? defaultColorDecorators;

  /// Disable the use of `transform: translate3d(0px, 0px, 0px)` for the editor
  /// margin and lines layers.
  /// The usage of `transform: translate3d(0px, 0px, 0px)` acts as a hint for
  /// browsers to create an extra layer.
  /// Defaults to false.
  external bool? disableLayerHinting;

  /// Disable the optimizations for monospace fonts.
  /// Defaults to false.
  external bool? disableMonospaceOptimizations;

  /// Should the cursor be hidden in the overview ruler.
  /// Defaults to false.
  external bool? hideCursorInOverviewRuler;

  /// Enable that scrolling can go one screen size after the last line.
  /// Defaults to true.
  external bool? scrollBeyondLastLine;

  /// Enable that scrolling can go beyond the last column by a number of
  /// columns.
  /// Defaults to 5.
  external double? scrollBeyondLastColumn;

  /// Enable that the editor animates scrolling to a position.
  /// Defaults to false.
  external bool? smoothScrolling;

  /// Enable that the editor will install a ResizeObserver to check if its
  /// container dom node size has changed.
  /// Defaults to false.
  external bool? automaticLayout;

  /// Control the wrapping of the editor.
  /// When `wordWrap` = "off", the lines will never wrap.
  /// When `wordWrap` = "on", the lines will wrap at the viewport width.
  /// When `wordWrap` = "wordWrapColumn", the lines will wrap at
  /// `wordWrapColumn`.
  /// When `wordWrap` = "bounded", the lines will wrap at min(viewport width,
  /// wordWrapColumn).
  /// Defaults to "off".
  external AnonymousUnion_2810996? wordWrap;

  /// Override the `wordWrap` setting.
  external AnonymousUnion_1569193? wordWrapOverride1;

  /// Override the `wordWrapOverride1` setting.
  external AnonymousUnion_1569193? wordWrapOverride2;

  /// Control the wrapping of the editor.
  /// When `wordWrap` = "off", the lines will never wrap.
  /// When `wordWrap` = "on", the lines will wrap at the viewport width.
  /// When `wordWrap` = "wordWrapColumn", the lines will wrap at
  /// `wordWrapColumn`.
  /// When `wordWrap` = "bounded", the lines will wrap at min(viewport width,
  /// wordWrapColumn).
  /// Defaults to 80.
  external double? wordWrapColumn;

  /// Control indentation of wrapped lines. Can be: 'none', 'same', 'indent' or
  /// 'deepIndent'.
  /// Defaults to 'same' in vscode and to 'none' in monaco-editor.
  external AnonymousUnion_1450754? wrappingIndent;

  /// Controls the wrapping strategy to use.
  /// Defaults to 'simple'.
  external AnonymousUnion_1536603? wrappingStrategy;

  /// Configure word wrapping characters. A break will be introduced before
  /// these characters.
  external String? wordWrapBreakBeforeCharacters;

  /// Configure word wrapping characters. A break will be introduced after these
  /// characters.
  external String? wordWrapBreakAfterCharacters;

  /// Sets whether line breaks appear wherever the text would otherwise overflow
  /// its content box.
  /// When wordBreak = 'normal', Use the default line break rule.
  /// When wordBreak = 'keepAll', Word breaks should not be used for
  /// Chinese/Japanese/Korean (CJK) text. Non-CJK text behavior is the same as
  /// for normal.
  external AnonymousUnion_1534200? wordBreak;

  /// Performance guard: Stop rendering a line after x characters.
  /// Defaults to 10000.
  /// Use -1 to never stop rendering
  external double? stopRenderingLineAfter;

  /// Configure the editor's hover.
  external IEditorHoverOptions? hover;

  /// Enable detecting links and making them clickable.
  /// Defaults to true.
  external bool? links;

  /// Enable inline color decorators and color picker rendering.
  external bool? colorDecorators;

  /// Controls what is the condition to spawn a color picker from a color
  /// dectorator
  external AnonymousUnion_1211872? colorDecoratorsActivatedOn;

  /// Controls the max number of color decorators that can be rendered in an
  /// editor at once.
  external double? colorDecoratorsLimit;

  /// Control the behaviour of comments in the editor.
  external IEditorCommentsOptions? comments;

  /// Enable custom contextmenu.
  /// Defaults to true.
  external bool? contextmenu;

  /// A multiplier to be used on the `deltaX` and `deltaY` of mouse wheel scroll
  /// events.
  /// Defaults to 1.
  external double? mouseWheelScrollSensitivity;

  /// FastScrolling mulitplier speed when pressing `Alt`
  /// Defaults to 5.
  external double? fastScrollSensitivity;

  /// Enable that the editor scrolls only the predominant axis. Prevents
  /// horizontal drift when scrolling vertically on a trackpad.
  /// Defaults to true.
  external bool? scrollPredominantAxis;

  /// Enable that the selection with the mouse and keys is doing column
  /// selection.
  /// Defaults to false.
  external bool? columnSelection;

  /// The modifier to be used to add multiple cursors with the mouse.
  /// Defaults to 'alt'
  external AnonymousUnion_2038418? multiCursorModifier;

  /// Merge overlapping selections.
  /// Defaults to true
  external bool? multiCursorMergeOverlapping;

  /// Configure the behaviour when pasting a text with the line count equal to
  /// the cursor count.
  /// Defaults to 'spread'.
  external AnonymousUnion_9182975? multiCursorPaste;

  /// Controls the max number of text cursors that can be in an active editor at
  /// once.
  external double? multiCursorLimit;

  /// Configure the editor's accessibility support.
  /// Defaults to 'auto'. It is best to leave this to 'auto'.
  external AnonymousUnion_1536131? accessibilitySupport;

  /// Controls the number of lines in the editor that can be read out by a
  /// screen reader
  external double? accessibilityPageSize;

  /// Suggest options.
  external ISuggestOptions? suggest;

  external IInlineSuggestOptions? inlineSuggest;

  external IInlineEditOptions? experimentalInlineEdit;

  /// Smart select options.
  external ISmartSelectOptions? smartSelect;

  external IGotoLocationOptions? gotoLocation;

  /// Enable quick suggestions (shadow suggestions)
  /// Defaults to true.
  external AnonymousUnion_1800907? quickSuggestions;

  /// Quick suggestions show delay (in ms)
  /// Defaults to 10 (ms)
  external double? quickSuggestionsDelay;

  /// Controls the spacing around the editor.
  external IEditorPaddingOptions? padding;

  /// Parameter hint options.
  external IEditorParameterHintOptions? parameterHints;

  /// Options for auto closing brackets.
  /// Defaults to language defined behavior.
  external EditorAutoClosingStrategy? autoClosingBrackets;

  /// Options for auto closing comments.
  /// Defaults to language defined behavior.
  external EditorAutoClosingStrategy? autoClosingComments;

  /// Options for auto closing quotes.
  /// Defaults to language defined behavior.
  external EditorAutoClosingStrategy? autoClosingQuotes;

  /// Options for pressing backspace near quotes or bracket pairs.
  external EditorAutoClosingEditStrategy? autoClosingDelete;

  /// Options for typing over closing quotes or brackets.
  external EditorAutoClosingEditStrategy? autoClosingOvertype;

  /// Options for auto surrounding.
  /// Defaults to always allowing auto surrounding.
  external EditorAutoSurroundStrategy? autoSurround;

  /// Controls whether the editor should automatically adjust the indentation
  /// when users type, paste, move or indent lines.
  /// Defaults to advanced.
  external AnonymousUnion_1459732? autoIndent;

  /// Emulate selection behaviour of tab characters when using spaces for
  /// indentation.
  /// This means selection will stick to tab stops.
  external bool? stickyTabStops;

  /// Enable format on type.
  /// Defaults to false.
  external bool? formatOnType;

  /// Enable format on paste.
  /// Defaults to false.
  external bool? formatOnPaste;

  /// Controls if the editor should allow to move selections via drag and drop.
  /// Defaults to false.
  external bool? dragAndDrop;

  /// Enable the suggestion box to pop-up on trigger characters.
  /// Defaults to true.
  external bool? suggestOnTriggerCharacters;

  /// Accept suggestions on ENTER.
  /// Defaults to 'on'.
  external AnonymousUnion_1780222? acceptSuggestionOnEnter;

  /// Accept suggestions on provider defined characters.
  /// Defaults to true.
  external bool? acceptSuggestionOnCommitCharacter;

  /// Enable snippet suggestions. Default to 'true'.
  external AnonymousUnion_1366129? snippetSuggestions;

  /// Copying without a selection copies the current line.
  external bool? emptySelectionClipboard;

  /// Syntax highlighting is copied.
  external bool? copyWithSyntaxHighlighting;

  /// The history mode for suggestions.
  external AnonymousUnion_4282826? suggestSelection;

  /// The font size for the suggest widget.
  /// Defaults to the editor font size.
  external double? suggestFontSize;

  /// The line height for the suggest widget.
  /// Defaults to the editor line height.
  external double? suggestLineHeight;

  /// Enable tab completion.
  external AnonymousUnion_4464549? tabCompletion;

  /// Enable selection highlight.
  /// Defaults to true.
  external bool? selectionHighlight;

  /// Enable semantic occurrences highlight.
  /// Defaults to 'singleFile'.
  /// 'off' disables occurrence highlighting
  /// 'singleFile' triggers occurrence highlighting in the current document
  /// 'multiFile'  triggers occurrence highlighting across valid open documents
  external AnonymousUnion_2487039? occurrencesHighlight;

  /// Show code lens
  /// Defaults to true.
  external bool? codeLens;

  /// Code lens font family. Defaults to editor font family.
  external String? codeLensFontFamily;

  /// Code lens font size. Default to 90% of the editor font size
  external double? codeLensFontSize;

  /// Control the behavior and rendering of the code action lightbulb.
  external IEditorLightbulbOptions? lightbulb;

  /// Timeout for running code actions on save.
  external double? codeActionsOnSaveTimeout;

  /// Enable code folding.
  /// Defaults to true.
  external bool? folding;

  /// Selects the folding strategy. 'auto' uses the strategies contributed for
  /// the current document, 'indentation' uses the indentation based folding
  /// strategy.
  /// Defaults to 'auto'.
  external AnonymousUnion_2133250? foldingStrategy;

  /// Enable highlight for folded regions.
  /// Defaults to true.
  external bool? foldingHighlight;

  /// Auto fold imports folding regions.
  /// Defaults to true.
  external bool? foldingImportsByDefault;

  /// Maximum number of foldable regions.
  /// Defaults to 5000.
  external double? foldingMaximumRegions;

  /// Controls whether the fold actions in the gutter stay always visible or
  /// hide unless the mouse is over the gutter.
  /// Defaults to 'mouseover'.
  external AnonymousUnion_1702192? showFoldingControls;

  /// Controls whether clicking on the empty content after a folded line will
  /// unfold the line.
  /// Defaults to false.
  external bool? unfoldOnClickAfterEndOfLine;

  /// Enable highlighting of matching brackets.
  /// Defaults to 'always'.
  external AnonymousUnion_6300795? matchBrackets;

  /// Enable experimental whitespace rendering.
  /// Defaults to 'svg'.
  external AnonymousUnion_6994842? experimentalWhitespaceRendering;

  /// Enable rendering of whitespace.
  /// Defaults to 'selection'.
  external AnonymousUnion_6087383? renderWhitespace;

  /// Enable rendering of control characters.
  /// Defaults to true.
  external bool? renderControlCharacters;

  /// Enable rendering of current line highlight.
  /// Defaults to all.
  external AnonymousUnion_1469778? renderLineHighlight;

  /// Control if the current line highlight should be rendered only the editor
  /// is focused.
  /// Defaults to false.
  external bool? renderLineHighlightOnlyWhenFocus;

  /// Inserting and deleting whitespace follows tab stops.
  external bool? useTabStops;

  /// The font family
  external String? fontFamily;

  /// The font weight
  external String? fontWeight;

  /// The font size
  external double? fontSize;

  /// The line height
  external double? lineHeight;

  /// The letter spacing
  external double? letterSpacing;

  /// Controls fading out of unused variables.
  external bool? showUnused;

  /// Controls whether to focus the inline editor in the peek widget by default.
  /// Defaults to false.
  external AnonymousUnion_1100602? peekWidgetDefaultFocus;

  /// Sets a placeholder for the editor.
  /// If set, the placeholder is shown if the editor is empty.
  external String? placeholder;

  /// Controls whether the definition link opens element in the peek widget.
  /// Defaults to false.
  external bool? definitionLinkOpensInPeek;

  /// Controls strikethrough deprecated variables.
  external bool? showDeprecated;

  /// Controls whether suggestions allow matches in the middle of the word
  /// instead of only at the beginning
  external bool? matchOnWordStartOnly;

  /// Control the behavior and rendering of the inline hints.
  external IEditorInlayHintsOptions? inlayHints;

  /// Control if the editor should use shadow DOM.
  external bool? useShadowDOM;

  /// Controls the behavior of editor guides.
  external IGuidesOptions? guides;

  /// Controls the behavior of the unicode highlight feature
  /// (by default, ambiguous and invisible characters are highlighted).
  external IUnicodeHighlightOptions? unicodeHighlight;

  /// Configures bracket pair colorization (disabled by default).
  external IBracketPairColorizationOptions? bracketPairColorization;

  /// Controls dropping into the editor from an external source.
  ///
  /// When enabled, this shows a preview of the drop location and triggers an
  /// `onDropIntoEditor` event.
  external IDropIntoEditorOptions? dropIntoEditor;

  /// Controls support for changing how content is pasted into the editor.
  external IPasteAsOptions? pasteAs;

  /// Controls whether the editor / terminal receives tabs or defers them to the
  /// workbench for navigation.
  external bool? tabFocusMode;

  /// Controls whether the accessibility hint should be provided to screen
  /// reader users when an inline completion is shown.
  external bool? inlineCompletionsAccessibilityVerbose;
}
extension type IDimension._(JSObject _) implements JSObject {
  external factory IDimension({num width, num height});

  external double width;

  external double height;
}
extension type IEditorConstructionOptions._(JSObject _)
    implements IEditorOptions {
  /// The initial editor dimension (to avoid measuring the container).
  external IDimension? dimension;

  /// Place overflow widgets inside an external DOM node.
  /// Defaults to an internal DOM node.
  external _i3.HTMLElement? overflowWidgetsDomNode;
}

/// Options which apply for all editors.
extension type IGlobalEditorOptions._(JSObject _) implements JSObject {
  /// The number of spaces a tab is equal to.
  /// This setting is overridden based on the file contents when
  /// `detectIndentation` is on.
  /// Defaults to 4.
  external double? tabSize;

  /// Insert spaces when pressing `Tab`.
  /// This setting is overridden based on the file contents when
  /// `detectIndentation` is on.
  /// Defaults to true.
  external bool? insertSpaces;

  /// Controls whether `tabSize` and `insertSpaces` will be automatically
  /// detected when a file is opened based on the file contents.
  /// Defaults to true.
  external bool? detectIndentation;

  /// Remove trailing auto inserted whitespace.
  /// Defaults to true.
  external bool? trimAutoWhitespace;

  /// Special handling for large files to disable certain memory intensive
  /// features.
  /// Defaults to true.
  external bool? largeFileOptimizations;

  /// Controls whether completions should be computed based on words in the
  /// document.
  /// Defaults to true.
  external AnonymousUnion_4962316? wordBasedSuggestions;

  /// Controls whether word based completions should be included from opened
  /// documents of the same language or any language.
  external bool? wordBasedSuggestionsOnlySameLanguage;

  /// Keep peek editors open even when double-clicking their content or when
  /// hitting `Escape`.
  /// Defaults to false.
  external bool? stablePeek;

  /// Lines above this length will not be tokenized for performance reasons.
  /// Defaults to 20000.
  external double? maxTokenizationLineLength;

  /// Theme to be used for rendering.
  /// The current out-of-the-box available themes are: 'vs' (default),
  /// 'vs-dark', 'hc-black', 'hc-light'.
  /// You can create custom themes via `monaco.editor.defineTheme`.
  /// To switch a theme, use `monaco.editor.setTheme`.
  /// **NOTE**: The theme might be overwritten if the OS is in high contrast
  /// mode, unless `autoDetectHighContrast` is set to false.
  external String? theme;

  /// If enabled, will automatically change to high contrast theme if the OS is
  /// using a high contrast theme.
  /// Defaults to true.
  external bool? autoDetectHighContrast;
}

/// The default end of line to use when instantiating models.
extension type const DefaultEndOfLine._(int _) {
  /// Use line feed (\n) as the end of line character.
  static const DefaultEndOfLine LF = DefaultEndOfLine._(1);

  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const DefaultEndOfLine CRLF = DefaultEndOfLine._(2);
}
extension type BracketPairColorizationOptions._(JSObject _)
    implements JSObject {
  external bool enabled;

  external bool independentColorPoolPerBracketType;
}
extension type TextModelResolvedOptions._(JSObject _) implements JSObject {
  external TextModelResolvedOptions();

  external double get tabSize;
  external double get indentSize;
  external bool get insertSpaces;
  external DefaultEndOfLine get defaultEOL;
  external bool get trimAutoWhitespace;
  external BracketPairColorizationOptions get bracketPairColorizationOptions;
}

/// Text snapshot that works like an iterator.
/// Will try to return chunks of roughly ~64KB size.
/// Will return null when finished.
extension type ITextSnapshot._(JSObject _) implements JSObject {
  external String? read();
}

/// End of line character preference.
extension type const EndOfLinePreference._(int _) {
  /// Use the end of line character identified in the text buffer.
  static const EndOfLinePreference TextDefined = EndOfLinePreference._(0);

  /// Use line feed (\n) as the end of line character.
  static const EndOfLinePreference LF = EndOfLinePreference._(1);

  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const EndOfLinePreference CRLF = EndOfLinePreference._(2);
}

/// End of line character preference.
extension type const EndOfLineSequence._(int _) {
  /// Use line feed (\n) as the end of line character.
  static const EndOfLineSequence LF = EndOfLineSequence._(0);

  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const EndOfLineSequence CRLF = EndOfLineSequence._(1);
}
extension type FindMatch._(JSObject _) implements JSObject {
  external FindMatch();

  external Range get range;
  external JSArray<JSString>? get matches;
}

/// Word inside a model.
extension type IWordAtPosition._(JSObject _) implements JSObject {
  /// The word.
  external String get word;

  /// The column where the word starts.
  external double get startColumn;

  /// The column where the word ends.
  external double get endColumn;
}

/// Describes the behavior of decorations when typing/editing near their
/// edges.
/// Note: Please do not edit the values, as they very carefully match
/// `DecorationRangeBehavior`
extension type const TrackedRangeStickiness._(int _) {
  static const TrackedRangeStickiness AlwaysGrowsWhenTypingAtEdges =
      TrackedRangeStickiness._(0);

  static const TrackedRangeStickiness NeverGrowsWhenTypingAtEdges =
      TrackedRangeStickiness._(1);

  static const TrackedRangeStickiness GrowsOnlyWhenTypingBefore =
      TrackedRangeStickiness._(2);

  static const TrackedRangeStickiness GrowsOnlyWhenTypingAfter =
      TrackedRangeStickiness._(3);
}
extension type ThemeColor._(JSObject _) implements JSObject {
  external String id;
}
extension type IDecorationOptions._(JSObject _) implements JSObject {
  /// CSS color to render.
  /// e.g.: rgba(100, 100, 100, 0.5) or a color from the color registry
  external AnonymousUnion_1194055 color;

  /// CSS color to render.
  /// e.g.: rgba(100, 100, 100, 0.5) or a color from the color registry
  external AnonymousUnion_1194055? darkColor;
}

/// Vertical Lane in the overview ruler of the editor.
extension type const OverviewRulerLane._(int _) {
  static const OverviewRulerLane Left = OverviewRulerLane._(1);

  static const OverviewRulerLane Center = OverviewRulerLane._(2);

  static const OverviewRulerLane Right = OverviewRulerLane._(4);

  static const OverviewRulerLane Full = OverviewRulerLane._(7);
}

/// Options for rendering a model decoration in the overview ruler.
extension type IModelDecorationOverviewRulerOptions._(JSObject _)
    implements IDecorationOptions {
  /// The position in the overview ruler.
  external OverviewRulerLane position;
}

/// Position in the minimap to render the decoration.
extension type const MinimapPosition._(int _) {
  static const MinimapPosition Inline = MinimapPosition._(1);

  static const MinimapPosition Gutter = MinimapPosition._(2);
}

/// Section header style.
extension type const MinimapSectionHeaderStyle._(int _) {
  static const MinimapSectionHeaderStyle Normal = MinimapSectionHeaderStyle._(
    1,
  );

  static const MinimapSectionHeaderStyle Underlined =
      MinimapSectionHeaderStyle._(2);
}

/// Options for rendering a model decoration in the minimap.
extension type IModelDecorationMinimapOptions._(JSObject _)
    implements IDecorationOptions {
  /// The position in the minimap.
  external MinimapPosition position;

  /// If the decoration is for a section header, which header style.
  external MinimapSectionHeaderStyle? sectionHeaderStyle;

  /// If the decoration is for a section header, the header text.
  external String? sectionHeaderText;
}

/// Vertical Lane in the glyph margin of the editor.
extension type const GlyphMarginLane._(int _) {
  static const GlyphMarginLane Left = GlyphMarginLane._(1);

  static const GlyphMarginLane Center = GlyphMarginLane._(2);

  static const GlyphMarginLane Right = GlyphMarginLane._(3);
}
extension type IModelDecorationGlyphMarginOptions._(JSObject _)
    implements JSObject {
  /// The position in the glyph margin.
  external GlyphMarginLane position;

  /// Whether the glyph margin lane in position should be rendered even
  /// outside of this decoration's range.
  external bool? persistLane;
}
extension type const InjectedTextCursorStops._(int _) {
  static const InjectedTextCursorStops Both = InjectedTextCursorStops._(0);

  static const InjectedTextCursorStops Right = InjectedTextCursorStops._(1);

  static const InjectedTextCursorStops Left = InjectedTextCursorStops._(2);

  static const InjectedTextCursorStops None = InjectedTextCursorStops._(3);
}

/// Configures text that is injected into the view without changing the
/// underlying document.
extension type InjectedTextOptions._(JSObject _) implements JSObject {
  /// Sets the text to inject. Must be a single line.
  external String get content;

  /// If set, the decoration will be rendered inline with the text with this CSS
  /// class name.
  external String? get inlineClassName;

  /// If there is an `inlineClassName` which affects letter spacing.
  external bool? get inlineClassNameAffectsLetterSpacing;

  /// This field allows to attach data to this injected text.
  /// The data can be read when injected texts at a given position are queried.
  external JSAny? get attachedData;

  /// Configures cursor stops around injected text.
  /// Defaults to InjectedTextCursorStops.Both.
  external InjectedTextCursorStops? get cursorStops;
}

/// Options for a model decoration.
extension type IModelDecorationOptions._(JSObject _) implements JSObject {
  /// Customize the growing behavior of the decoration when typing at the edges
  /// of the decoration.
  /// Defaults to TrackedRangeStickiness.AlwaysGrowsWhenTypingAtEdges
  external TrackedRangeStickiness? stickiness;

  /// CSS class name describing the decoration.
  external String? className;

  /// Indicates whether the decoration should span across the entire line when
  /// it continues onto the next line.
  external bool? shouldFillLineOnLineBreak;

  external String? blockClassName;

  /// Indicates if this block should be rendered after the last line.
  /// In this case, the range must be empty and set to the last line.
  external bool? blockIsAfterEnd;

  external bool? blockDoesNotCollapse;

  external _i4.JSTuple4<JSAny?, JSAny?, JSAny?, JSAny?>? blockPadding;

  /// Message to be rendered when hovering over the glyph margin decoration.
  external AnonymousUnion_1480064? glyphMarginHoverMessage;

  /// Array of MarkdownString to render as the decoration message.
  external AnonymousUnion_1480064? hoverMessage;

  /// Array of MarkdownString to render as the line number message.
  external AnonymousUnion_1480064? lineNumberHoverMessage;

  /// Should the decoration expand to encompass a whole line.
  external bool? isWholeLine;

  /// Always render the decoration (even when the range it encompasses is
  /// collapsed).
  external bool? showIfCollapsed;

  /// Specifies the stack order of a decoration.
  /// A decoration with greater stack order is always in front of a decoration
  /// with
  /// a lower stack order when the decorations are on the same line.
  external double? zIndex;

  /// If set, render this decoration in the overview ruler.
  external IModelDecorationOverviewRulerOptions? overviewRuler;

  /// If set, render this decoration in the minimap.
  external IModelDecorationMinimapOptions? minimap;

  /// If set, the decoration will be rendered in the glyph margin with this CSS
  /// class name.
  external String? glyphMarginClassName;

  /// If set and the decoration has glyphMarginClassName set, render this
  /// decoration
  /// with the specified IModelDecorationGlyphMarginOptions in the glyph margin.
  external IModelDecorationGlyphMarginOptions? glyphMargin;

  /// If set, the decoration will be rendered in the lines decorations with this
  /// CSS class name.
  external String? linesDecorationsClassName;

  /// Controls the tooltip text of the line decoration.
  external String? linesDecorationsTooltip;

  /// If set, the decoration will be rendered on the line number.
  external String? lineNumberClassName;

  /// If set, the decoration will be rendered in the lines decorations with this
  /// CSS class name, but only for the first line in case of line wrapping.
  external String? firstLineDecorationClassName;

  /// If set, the decoration will be rendered in the margin (covering its full
  /// width) with this CSS class name.
  external String? marginClassName;

  /// If set, the decoration will be rendered inline with the text with this CSS
  /// class name.
  /// Please use this only for CSS rules that must impact the text. For example,
  /// use `className`
  /// to have a background color decoration.
  external String? inlineClassName;

  /// If there is an `inlineClassName` which affects letter spacing.
  external bool? inlineClassNameAffectsLetterSpacing;

  /// If set, the decoration will be rendered before the text with this CSS
  /// class name.
  external String? beforeContentClassName;

  /// If set, the decoration will be rendered after the text with this CSS class
  /// name.
  external String? afterContentClassName;

  /// If set, text will be injected in the view after the range.
  external InjectedTextOptions? after;

  /// If set, text will be injected in the view before the range.
  external InjectedTextOptions? before;
}

/// New model decorations.
extension type IModelDeltaDecoration._(JSObject _) implements JSObject {
  /// Range that this decoration covers.
  external IRange range;

  /// Options associated with this decoration.
  external IModelDecorationOptions options;
}

/// A decoration in the model.
extension type IModelDecoration._(JSObject _) implements JSObject {
  /// Identifier for a decoration.
  external String get id;

  /// Identifier for a decoration's owner.
  external double get ownerId;

  /// Range that this decoration covers.
  external Range get range;

  /// Options associated with this decoration.
  external IModelDecorationOptions get options;
}
extension type ITextModelUpdateOptions._(JSObject _) implements JSObject {
  external double? tabSize;

  external bool? insertSpaces;

  external bool? trimAutoWhitespace;

  external BracketPairColorizationOptions? bracketColorizationOptions;
}

/// A selection in the editor.
/// The selection is a range that has an orientation.
extension type Selection._(JSObject _) implements Range {
  external Selection(
    num selectionStartLineNumber,
    num selectionStartColumn,
    num positionLineNumber,
    num positionColumn,
  );

  /// The line number on which the selection has started.
  external double get selectionStartLineNumber;

  /// The column on `selectionStartLineNumber` where the selection has started.
  external double get selectionStartColumn;

  /// The line number on which the selection has ended.
  external double get positionLineNumber;

  /// The column on `positionLineNumber` where the selection has ended.
  external double get positionColumn;

  /// Transform to a human-readable representation.
  @JS('toString')
  external String toString$();

  /// Test if equals other selection.
  external bool equalsSelection(ISelection other);

  /// Test if the two selections are equal.
  external static bool selectionsEqual(ISelection a, ISelection b);

  /// Get directions (LTR or RTL).
  external SelectionDirection getDirection();

  /// Create a new selection with a different `positionLineNumber` and
  /// `positionColumn`.
  @_i2.redeclare
  external Selection setEndPosition(num endLineNumber, num endColumn);

  /// Get the position at `positionLineNumber` and `positionColumn`.
  external Position getPosition();

  /// Get the position at the start of the selection.
  external Position getSelectionStart();

  /// Create a new selection with a different `selectionStartLineNumber` and
  /// `selectionStartColumn`.
  @_i2.redeclare
  external Selection setStartPosition(num startLineNumber, num startColumn);

  /// Create a `Selection` from one or two positions
  external static Selection fromPositions(IPosition start, [IPosition? end]);

  /// Creates a `Selection` from a range, given a direction.
  external static Selection fromRange(
    Range range,
    SelectionDirection direction,
  );

  /// Create a `Selection` from an `ISelection`.
  external static Selection liftSelection(ISelection sel);

  /// `a` equals `b`.
  external static bool selectionsArrEqual(
    JSArray<ISelection> a,
    JSArray<ISelection> b,
  );

  /// Test if `obj` is an `ISelection`.
  external static JSAny isISelection(JSAny? obj);

  /// Create with a direction.
  external static Selection createWithDirection(
    num startLineNumber,
    num startColumn,
    num endLineNumber,
    num endColumn,
    SelectionDirection direction,
  );
}

/// A single edit operation, that acts as a simple replace.
/// i.e. Replace text at `range` with `text` in model.
extension type ISingleEditOperation._(JSObject _) implements JSObject {
  /// The range to replace. This can be empty to emulate a simple insert.
  external IRange range;

  /// The text to replace with. This can be null to emulate a simple delete.
  external String? text;

  /// This indicates that this operation has "insert" semantics.
  /// i.e. forceMoveMarkers = true => if `range` is collapsed, all markers at
  /// the position will be moved.
  external bool? forceMoveMarkers;
}

/// A single edit operation, that has an identifier.
extension type IIdentifiedSingleEditOperation._(JSObject _)
    implements ISingleEditOperation {}
extension type IValidEditOperation._(JSObject _) implements JSObject {
  /// The range to replace. This can be empty to emulate a simple insert.
  external Range range;

  /// The text to replace with. This can be empty to emulate a simple delete.
  external String text;
}

/// A callback that can compute the cursor state after applying a series of
/// edit operations.
extension type ICursorStateComputer._(JSObject _) implements JSObject {
  external JSArray<Selection>? call(
    JSArray<IValidEditOperation> inverseEditOperations,
  );
}
extension type IModelContentChange._(JSObject _) implements JSObject {
  /// The range that got replaced.
  external IRange get range;

  /// The offset of the range that got replaced.
  external double get rangeOffset;

  /// The length of the range that got replaced.
  external double get rangeLength;

  /// The new text for the range.
  external String get text;
}

/// An event describing a change in the text of a model.
extension type IModelContentChangedEvent._(JSObject _) implements JSObject {
  /// The changes are ordered from the end of the document to the beginning, so
  /// they should be safe to apply in sequence.
  external JSArray<IModelContentChange> get changes;

  /// The (new) end-of-line character.
  external String get eol;

  /// The new version id the model has transitioned to.
  external double get versionId;

  /// Flag that indicates that this event was generated while undoing.
  external bool get isUndoing;

  /// Flag that indicates that this event was generated while redoing.
  external bool get isRedoing;

  /// Flag that indicates that all decorations were lost with this edit.
  /// The model has been reset to a new value.
  external bool get isFlush;

  /// Flag that indicates that this event describes an eol change.
  external bool get isEolChange;
}

/// An event describing that model decorations have changed.
extension type IModelDecorationsChangedEvent._(JSObject _) implements JSObject {
  external bool get affectsMinimap;
  external bool get affectsOverviewRuler;
  external bool get affectsGlyphMargin;
  external bool get affectsLineNumber;
}
extension type IModelOptionsChangedEvent._(JSObject _) implements JSObject {
  external bool get tabSize;
  external bool get indentSize;
  external bool get insertSpaces;
  external bool get trimAutoWhitespace;
}

/// An event describing that the current language associated with a model has
/// changed.
extension type IModelLanguageChangedEvent._(JSObject _) implements JSObject {
  /// Previous language
  external String get oldLanguage;

  /// New language
  external String get newLanguage;

  /// Source of the call that caused the event.
  external String get source;
}

/// An event describing that the language configuration associated with a
/// model has changed.
extension type IModelLanguageConfigurationChangedEvent._(JSObject _)
    implements JSObject {}

/// A model.
extension type ITextModel._(JSObject _) implements JSObject {
  /// Gets the resource associated with this editor model.
  external Uri get uri;

  /// A unique identifier associated with this model.
  external String get id;

  /// An event emitted when decorations of the model have changed.
  external IEvent<IModelDecorationsChangedEvent> get onDidChangeDecorations;

  /// An event emitted when the model options have changed.
  external IEvent<IModelOptionsChangedEvent> get onDidChangeOptions;

  /// An event emitted when the language associated with the model has changed.
  external IEvent<IModelLanguageChangedEvent> get onDidChangeLanguage;

  /// An event emitted when the language configuration associated with the model
  /// has changed.
  external IEvent<IModelLanguageConfigurationChangedEvent>
  get onDidChangeLanguageConfiguration;

  /// An event emitted when the model has been attached to the first editor or
  /// detached from the last editor.
  external IEvent<JSAny?> get onDidChangeAttached;

  /// An event emitted right before disposing the model.
  external IEvent<JSAny?> get onWillDispose;

  /// Get the resolved options for this model.
  external TextModelResolvedOptions getOptions();

  /// Get the current version id of the model.
  /// Anytime a change happens to the model (even undo/redo),
  /// the version id is incremented.
  external double getVersionId();

  /// Get the alternative version id of the model.
  /// This alternative version id is not always incremented,
  /// it will return the same values in the case of undo-redo.
  external double getAlternativeVersionId();

  /// Replace the entire text buffer value contained in this model.
  external JSAny? setValue(AnonymousUnion_8471410 newValue);

  /// Get the text stored in this model.
  /// - [eol]:  The end of line character preference. Defaults to
  ///   `EndOfLinePreference.TextDefined`.
  /// - [preserverBOM]:  Preserve a BOM character if it was detected when the
  ///   model was constructed.
  external String getValue([EndOfLinePreference? eol, bool? preserveBOM]);

  /// Get the text stored in this model.
  /// - [preserverBOM]:  Preserve a BOM character if it was detected when the
  ///   model was constructed.
  external ITextSnapshot createSnapshot([bool? preserveBOM]);

  /// Get the length of the text stored in this model.
  external double getValueLength([EndOfLinePreference? eol, bool? preserveBOM]);

  /// Get the text in a certain range.
  /// - [range]:  The range describing what text to get.
  /// - [eol]:  The end of line character preference. This will only be used for
  ///   multiline ranges. Defaults to `EndOfLinePreference.TextDefined`.
  external String getValueInRange(IRange range, [EndOfLinePreference? eol]);

  /// Get the length of text in a certain range.
  /// - [range]:  The range describing what text length to get.
  external double getValueLengthInRange(
    IRange range, [
    EndOfLinePreference? eol,
  ]);

  /// Get the character count of text in a certain range.
  /// - [range]:  The range describing what text length to get.
  external double getCharacterCountInRange(
    IRange range, [
    EndOfLinePreference? eol,
  ]);

  /// Get the number of lines in the model.
  external double getLineCount();

  /// Get the text for a certain line.
  external String getLineContent(num lineNumber);

  /// Get the text length for a certain line.
  external double getLineLength(num lineNumber);

  /// Get the text for all lines.
  external JSArray<JSString> getLinesContent();

  /// Get the end of line sequence predominantly used in the text buffer.
  external String getEOL();

  /// Get the end of line sequence predominantly used in the text buffer.
  external EndOfLineSequence getEndOfLineSequence();

  /// Get the minimum legal column for line at `lineNumber`
  external double getLineMinColumn(num lineNumber);

  /// Get the maximum legal column for line at `lineNumber`
  external double getLineMaxColumn(num lineNumber);

  /// Returns the column before the first non whitespace character for line at
  /// `lineNumber`.
  /// Returns 0 if line is empty or contains only whitespace.
  external double getLineFirstNonWhitespaceColumn(num lineNumber);

  /// Returns the column after the last non whitespace character for line at
  /// `lineNumber`.
  /// Returns 0 if line is empty or contains only whitespace.
  external double getLineLastNonWhitespaceColumn(num lineNumber);

  /// Create a valid position.
  external Position validatePosition(IPosition position);

  /// Advances the given position by the given offset (negative offsets are also
  /// accepted)
  /// and returns it as a new valid position.
  ///
  /// If the offset and position are such that their combination goes beyond the
  /// beginning or
  /// end of the model, throws an exception.
  ///
  /// If the offset is such that the new position would be in the middle of a
  /// multi-byte
  /// line terminator, throws an exception.
  external Position modifyPosition(IPosition position, num offset);

  /// Create a valid range.
  external Range validateRange(IRange range);

  /// Converts the position to a zero-based offset.
  ///
  /// The position will be [adjusted](#TextDocument.validatePosition).
  /// - [position]:  A position.
  external double getOffsetAt(IPosition position);

  /// Converts a zero-based offset to a position.
  /// - [offset]:  A zero-based offset.
  external Position getPositionAt(num offset);

  /// Get a range covering the entire model.
  external Range getFullModelRange();

  /// Returns if the model was disposed or not.
  external bool isDisposed();

  /// Search the model.
  /// - [searchString]:  The string used to search. If it is a regular
  ///   expression, set `isRegex` to true.
  /// - [searchOnlyEditableRange]:  Limit the searching to only search inside
  ///   the editable range of the model.
  /// - [isRegex]:  Used to indicate that `searchString` is a regular
  ///   expression.
  /// - [matchCase]:  Force the matching to match lower/upper case exactly.
  /// - [wordSeparators]:  Force the matching to match entire words only. Pass
  ///   null otherwise.
  /// - [captureMatches]:  The result will contain the captured groups.
  /// - [limitResultCount]:  Limit the number of results
  /// - [searchString]:  The string used to search. If it is a regular
  ///   expression, set `isRegex` to true.
  /// - [searchScope]:  Limit the searching to only search inside these ranges.
  /// - [isRegex]:  Used to indicate that `searchString` is a regular
  ///   expression.
  /// - [matchCase]:  Force the matching to match lower/upper case exactly.
  /// - [wordSeparators]:  Force the matching to match entire words only. Pass
  ///   null otherwise.
  /// - [captureMatches]:  The result will contain the captured groups.
  /// - [limitResultCount]:  Limit the number of results
  external JSArray<FindMatch> findMatches(
    String searchString,
    bool searchOnlyEditableRange,
    bool isRegex,
    bool matchCase,
    String? wordSeparators,
    bool captureMatches, [
    num? limitResultCount,
  ]);

  /// Search the model.
  /// - [searchString]:  The string used to search. If it is a regular
  ///   expression, set `isRegex` to true.
  /// - [searchOnlyEditableRange]:  Limit the searching to only search inside
  ///   the editable range of the model.
  /// - [isRegex]:  Used to indicate that `searchString` is a regular
  ///   expression.
  /// - [matchCase]:  Force the matching to match lower/upper case exactly.
  /// - [wordSeparators]:  Force the matching to match entire words only. Pass
  ///   null otherwise.
  /// - [captureMatches]:  The result will contain the captured groups.
  /// - [limitResultCount]:  Limit the number of results
  /// - [searchString]:  The string used to search. If it is a regular
  ///   expression, set `isRegex` to true.
  /// - [searchScope]:  Limit the searching to only search inside these ranges.
  /// - [isRegex]:  Used to indicate that `searchString` is a regular
  ///   expression.
  /// - [matchCase]:  Force the matching to match lower/upper case exactly.
  /// - [wordSeparators]:  Force the matching to match entire words only. Pass
  ///   null otherwise.
  /// - [captureMatches]:  The result will contain the captured groups.
  /// - [limitResultCount]:  Limit the number of results
  @JS('findMatches')
  external JSArray<FindMatch> findMatches$1(
    String searchString,
    AnonymousUnion_8236653 searchScope,
    bool isRegex,
    bool matchCase,
    String? wordSeparators,
    bool captureMatches, [
    num? limitResultCount,
  ]);

  /// Search the model for the next match. Loops to the beginning of the model
  /// if needed.
  /// - [searchString]:  The string used to search. If it is a regular
  ///   expression, set `isRegex` to true.
  /// - [searchStart]:  Start the searching at the specified position.
  /// - [isRegex]:  Used to indicate that `searchString` is a regular
  ///   expression.
  /// - [matchCase]:  Force the matching to match lower/upper case exactly.
  /// - [wordSeparators]:  Force the matching to match entire words only. Pass
  ///   null otherwise.
  /// - [captureMatches]:  The result will contain the captured groups.
  external FindMatch? findNextMatch(
    String searchString,
    IPosition searchStart,
    bool isRegex,
    bool matchCase,
    String? wordSeparators,
    bool captureMatches,
  );

  /// Search the model for the previous match. Loops to the end of the model if
  /// needed.
  /// - [searchString]:  The string used to search. If it is a regular
  ///   expression, set `isRegex` to true.
  /// - [searchStart]:  Start the searching at the specified position.
  /// - [isRegex]:  Used to indicate that `searchString` is a regular
  ///   expression.
  /// - [matchCase]:  Force the matching to match lower/upper case exactly.
  /// - [wordSeparators]:  Force the matching to match entire words only. Pass
  ///   null otherwise.
  /// - [captureMatches]:  The result will contain the captured groups.
  external FindMatch? findPreviousMatch(
    String searchString,
    IPosition searchStart,
    bool isRegex,
    bool matchCase,
    String? wordSeparators,
    bool captureMatches,
  );

  /// Get the language associated with this model.
  external String getLanguageId();

  /// Get the word under or besides `position`.
  /// - [position]:  The position to look for a word.
  external IWordAtPosition? getWordAtPosition(IPosition position);

  /// Get the word under or besides `position` trimmed to `position`.column
  /// - [position]:  The position to look for a word.
  external IWordAtPosition getWordUntilPosition(IPosition position);

  /// Perform a minimum amount of operations, in order to transform the
  /// decorations
  /// identified by `oldDecorations` to the decorations described by
  /// `newDecorations`
  /// and returns the new identifiers associated with the resulting decorations.
  /// - [oldDecorations]:  Array containing previous decorations identifiers.
  /// - [newDecorations]:  Array describing what decorations should result after
  ///   the call.
  /// - [ownerId]:  Identifies the editor id in which these decorations should
  ///   appear. If no `ownerId` is provided, the decorations will appear in all
  ///   editors that attach this model.
  external JSArray<JSString> deltaDecorations(
    JSArray<JSString> oldDecorations,
    JSArray<IModelDeltaDecoration> newDecorations, [
    num? ownerId,
  ]);

  /// Get the options associated with a decoration.
  /// - [id]:  The decoration id.
  external IModelDecorationOptions? getDecorationOptions(String id);

  /// Get the range associated with a decoration.
  /// - [id]:  The decoration id.
  external Range? getDecorationRange(String id);

  /// Gets all the decorations for the line `lineNumber` as an array.
  /// - [lineNumber]:  The line number
  /// - [ownerId]:  If set, it will ignore decorations belonging to other
  ///   owners.
  /// - [filterOutValidation]:  If set, it will ignore decorations specific to
  ///   validation (i.e. warnings, errors).
  external JSArray<IModelDecoration> getLineDecorations(
    num lineNumber, [
    num? ownerId,
    bool? filterOutValidation,
  ]);

  /// Gets all the decorations for the lines between `startLineNumber` and
  /// `endLineNumber` as an array.
  /// - [startLineNumber]:  The start line number
  /// - [endLineNumber]:  The end line number
  /// - [ownerId]:  If set, it will ignore decorations belonging to other
  ///   owners.
  /// - [filterOutValidation]:  If set, it will ignore decorations specific to
  ///   validation (i.e. warnings, errors).
  external JSArray<IModelDecoration> getLinesDecorations(
    num startLineNumber,
    num endLineNumber, [
    num? ownerId,
    bool? filterOutValidation,
  ]);

  /// Gets all the decorations in a range as an array. Only `startLineNumber`
  /// and `endLineNumber` from `range` are used for filtering.
  /// So for now it returns all the decorations on the same line as `range`.
  /// - [range]:  The range to search in
  /// - [ownerId]:  If set, it will ignore decorations belonging to other
  ///   owners.
  /// - [filterOutValidation]:  If set, it will ignore decorations specific to
  ///   validation (i.e. warnings, errors).
  /// - [onlyMinimapDecorations]:  If set, it will return only decorations that
  ///   render in the minimap.
  /// - [onlyMarginDecorations]:  If set, it will return only decorations that
  ///   render in the glyph margin.
  external JSArray<IModelDecoration> getDecorationsInRange(
    IRange range, [
    num? ownerId,
    bool? filterOutValidation,
    bool? onlyMinimapDecorations,
    bool? onlyMarginDecorations,
  ]);

  /// Gets all the decorations as an array.
  /// - [ownerId]:  If set, it will ignore decorations belonging to other
  ///   owners.
  /// - [filterOutValidation]:  If set, it will ignore decorations specific to
  ///   validation (i.e. warnings, errors).
  external JSArray<IModelDecoration> getAllDecorations([
    num? ownerId,
    bool? filterOutValidation,
  ]);

  /// Gets all decorations that render in the glyph margin as an array.
  /// - [ownerId]:  If set, it will ignore decorations belonging to other
  ///   owners.
  external JSArray<IModelDecoration> getAllMarginDecorations([num? ownerId]);

  /// Gets all the decorations that should be rendered in the overview ruler as
  /// an array.
  /// - [ownerId]:  If set, it will ignore decorations belonging to other
  ///   owners.
  /// - [filterOutValidation]:  If set, it will ignore decorations specific to
  ///   validation (i.e. warnings, errors).
  external JSArray<IModelDecoration> getOverviewRulerDecorations([
    num? ownerId,
    bool? filterOutValidation,
  ]);

  /// Gets all the decorations that contain injected text.
  /// - [ownerId]:  If set, it will ignore decorations belonging to other
  ///   owners.
  external JSArray<IModelDecoration> getInjectedTextDecorations([num? ownerId]);

  /// Normalize a string containing whitespace according to indentation rules
  /// (converts to spaces or to tabs).
  external String normalizeIndentation(String str);

  /// Change the options of this model.
  external JSAny? updateOptions(ITextModelUpdateOptions newOpts);

  /// Detect the indentation options for this model from its content.
  external JSAny? detectIndentation(
    bool defaultInsertSpaces,
    num defaultTabSize,
  );

  /// Close the current undo-redo element.
  /// This offers a way to create an undo/redo stop point.
  external JSAny? pushStackElement();

  /// Open the current undo-redo element.
  /// This offers a way to remove the current undo/redo stop point.
  external JSAny? popStackElement();

  /// Push edit operations, basically editing the model. This is the preferred
  /// way
  /// of editing the model. The edit operations will land on the undo stack.
  /// - [beforeCursorState]:  The cursor state before the edit operations. This
  ///   cursor state will be returned when `undo` or `redo` are invoked.
  /// - [editOperations]:  The edit operations.
  /// - [cursorStateComputer]:  A callback that can compute the resulting
  ///   cursors state after the edit operations have been executed.
  external JSArray<Selection>? pushEditOperations(
    JSArray<Selection>? beforeCursorState,
    JSArray<IIdentifiedSingleEditOperation> editOperations,
    ICursorStateComputer cursorStateComputer,
  );

  /// Change the end of line sequence. This is the preferred way of
  /// changing the eol sequence. This will land on the undo stack.
  external JSAny? pushEOL(EndOfLineSequence eol);

  /// Edit the model without adding the edits to the undo stack.
  /// This can have dire consequences on the undo stack! See
  /// - [operations]:  The edit operations.
  external JSAny? applyEdits(
    JSArray<IIdentifiedSingleEditOperation> operations,
  );

  /// Edit the model without adding the edits to the undo stack.
  /// This can have dire consequences on the undo stack! See
  /// - [operations]:  The edit operations.
  @JS('applyEdits')
  external JSAny? applyEdits$1(
    JSArray<IIdentifiedSingleEditOperation> operations,
    bool computeUndoEdits,
  );

  /// Edit the model without adding the edits to the undo stack.
  /// This can have dire consequences on the undo stack! See
  /// - [operations]:  The edit operations.
  @JS('applyEdits')
  external JSArray<IValidEditOperation> applyEdits$2(
    JSArray<IIdentifiedSingleEditOperation> operations,
    bool computeUndoEdits,
  );

  /// Change the end of line sequence without recording in the undo stack.
  /// This can have dire consequences on the undo stack! See
  external JSAny? setEOL(EndOfLineSequence eol);

  /// An event emitted when the contents of the model have changed.
  external IDisposable onDidChangeContent(JSFunction listener);

  /// Destroy this model.
  external JSAny? dispose();

  /// Returns if this model is attached to an editor or not.
  external bool isAttachedToEditor();
}

/// The options to create an editor.
extension type IStandaloneEditorConstructionOptions._(JSObject _)
    implements IEditorConstructionOptions, IGlobalEditorOptions {
  external factory IStandaloneEditorConstructionOptions({
    ITextModel? model,
    String? value,
    String? language,
    String? theme,
    bool? autoDetectHighContrast,
    String? accessibilityHelpUrl,
    _i3.HTMLElement? ariaContainerElement,
    IEditorMinimapOptions? minimap,
    AnonymousUnion_2810996? wordWrap,
    IEditorScrollbarOptions? scrollbar,
    ISuggestOptions? suggest,
    bool? contextmenu,
    bool? mouseWheelZoom,
    bool? quickSuggestions,
    num? quickSuggestionsDelay,
    bool? parameterHints,
    bool? formatOnType,
    bool? formatOnPaste,
    bool? suggestOnTriggerCharacters,
    bool? acceptSuggestionOnEnter,
    bool? acceptSuggestionOnCommitCharacter,
    bool? snippetSuggestions,
    bool? wordBasedSuggestions,
    String? suggestSelection,
    String? tabCompletion,
    bool? tabFocusMode,
    bool? suggestFontSizeAdjustments,
    num? suggestLineHeightAdjustments,
    bool? selectionHighlight,
    bool? occurrencesHighlight,
    bool? codeLens,
    bool? folding,
    bool? foldingHighlight,
    bool? showFoldingControls,
    num? foldingStrategy,
    bool? renderWhitespace,
    String? renderControlCharacters,
    bool? renderIndentGuides,
    bool? highlightActiveIndentGuide,
    bool? renderLineHighlightOnlyWhenFocus,
    String? cursorStyle,
    bool? hideCursorInOverviewRuler,
    bool? automaticLayout,
    num? fontSize,
    String? fontFamily,
    num? lineHeight,
    String? fontWeight,
    String? fontLigatures,
    num? letterSpacing,
    bool? scrollBeyondLastLine,
    IDimension? dimension,
    bool? useShadowDOM,
  });

  /// The initial model associated with this code editor.
  external ITextModel? model;

  /// The initial value of the auto created model in the editor.
  /// To not automatically create a model, use `model: null`.
  external String? value;

  /// The initial language of the auto created model in the editor.
  /// To not automatically create a model, use `model: null`.
  external String? language;

  /// Initial theme to be used for rendering.
  /// The current out-of-the-box available themes are: 'vs' (default),
  /// 'vs-dark', 'hc-black', 'hc-light.
  /// You can create custom themes via `monaco.editor.defineTheme`.
  /// To switch a theme, use `monaco.editor.setTheme`.
  /// **NOTE**: The theme might be overwritten if the OS is in high contrast
  /// mode, unless `autoDetectHighContrast` is set to false.
  external String? theme;

  /// If enabled, will automatically change to high contrast theme if the OS is
  /// using a high contrast theme.
  /// Defaults to true.
  external bool? autoDetectHighContrast;

  /// An URL to open when Ctrl+H (Windows and Linux) or Cmd+H (OSX) is pressed
  /// in
  /// the accessibility help dialog in the editor.
  ///
  /// Defaults to "https://go.microsoft.com/fwlink/?linkid=852450"
  external String? accessibilityHelpUrl;

  /// Container element to use for ARIA messages.
  /// Defaults to document.body.
  external _i3.HTMLElement? ariaContainerElement;
}
extension type IEditorOverrideServices._(JSObject _) implements JSObject {
  external JSAny? operator [](String index);
}
extension type ILocalizedString._(JSObject _) implements JSObject {
  external String original;

  external String value;
}
extension type ICommandMetadata._(JSObject _) implements JSObject {
  external AnonymousUnion_1761706 get description;
}
extension type IEditorAction._(JSObject _) implements JSObject {
  external String get id;
  external String get label;
  external String get alias;
  external ICommandMetadata? get metadata;
  external bool isSupported();
  external JSPromise<JSAny?> run([JSAny? args]);
}

/// A (serializable) state of the cursors.
extension type ICursorState._(JSObject _) implements JSObject {
  external bool inSelectionMode;

  external IPosition selectionStart;

  external IPosition position;
}

/// A (serializable) state of the view.
extension type IViewState._(JSObject _) implements JSObject {
  /// written by previous versions
  external double? scrollTop;

  /// written by previous versions
  external double? scrollTopWithoutViewZones;

  external double scrollLeft;

  external IPosition firstPosition;

  external double firstPositionDeltaTop;
}

/// A (serializable) state of the code editor.
extension type ICodeEditorViewState._(JSObject _) implements JSObject {
  external JSArray<ICursorState> cursorState;

  external IViewState viewState;

  external AnonymousType_2245370 contributionsState;
}

/// (Serializable) View state for the diff editor.
extension type IDiffEditorViewState._(JSObject _) implements JSObject {
  external ICodeEditorViewState? original;

  external ICodeEditorViewState? modified;

  external JSAny? modelState;
}

/// An editor view state.
typedef IEditorViewState = AnonymousUnion_9768228;
extension type const ScrollType._(int _) {
  static const ScrollType Smooth = ScrollType._(0);

  static const ScrollType Immediate = ScrollType._(1);
}

/// A model for the diff editor.
extension type IDiffEditorModel._(JSObject _) implements JSObject {
  /// Original model.
  external ITextModel original;

  /// Modified model.
  external ITextModel modified;
}
extension type IDiffEditorViewModel._(JSObject _) implements IDisposable {
  external IDiffEditorModel get model;
  external JSPromise<JSAny?> waitForDiff();
}
typedef IEditorModel = AnonymousUnion_5377231;

/// A collection of decorations
extension type IEditorDecorationsCollection._(JSObject _) implements JSObject {
  /// An event emitted when decorations change in the editor,
  /// but the change is not caused by us setting or clearing the collection.
  external IEvent<IModelDecorationsChangedEvent> onDidChange;

  /// Get the decorations count.
  external double length;

  /// Get the range for a decoration.
  external Range? getRange(num index);

  /// Get all ranges for decorations.
  external JSArray<Range> getRanges();

  /// Determine if a decoration is in this collection.
  external bool has(IModelDecoration decoration);

  /// Replace all previous decorations with `newDecorations`.
  @JS('set')
  external JSArray<JSString> set$(
    JSArray<IModelDeltaDecoration> newDecorations,
  );

  /// Append `newDecorations` to this collection.
  external JSArray<JSString> append(
    JSArray<IModelDeltaDecoration> newDecorations,
  );

  /// Remove all previous decorations.
  external JSAny? clear();
}

/// An editor.
extension type IEditor._(JSObject _) implements JSObject {
  /// An event emitted when the editor has been disposed.
  external IDisposable onDidDispose(_AnonymousFunction_9788823 listener);

  /// Dispose the editor.
  external JSAny? dispose();

  /// Get a unique id for this editor instance.
  external String getId();

  /// Get the editor type. Please see `EditorType`.
  /// This is to avoid an instanceof check
  external String getEditorType();

  /// Update the editor's options after the editor has been created.
  external JSAny? updateOptions(IEditorOptions newOptions);

  /// Instructs the editor to remeasure its container. This method should
  /// be called when the container of the editor gets resized.
  ///
  /// If a dimension is passed in, the passed in value will be used.
  ///
  /// By default, this will also render the editor immediately.
  /// If you prefer to delay rendering to the next animation frame, use
  /// postponeRendering == true.
  external JSAny? layout([IDimension? dimension, bool? postponeRendering]);

  /// Brings browser focus to the editor text
  external JSAny? focus();

  /// Returns true if the text inside this editor is focused (i.e. cursor is
  /// blinking).
  external bool hasTextFocus();

  /// Returns all actions associated with this editor.
  external JSArray<IEditorAction> getSupportedActions();

  /// Saves current view state of the editor in a serializable object.
  external IEditorViewState? saveViewState();

  /// Restores the view state of the editor from a serializable object generated
  /// by `saveViewState`.
  external JSAny? restoreViewState(IEditorViewState? state);

  /// Given a position, returns a column number that takes tab-widths into
  /// account.
  external double getVisibleColumnFromPosition(IPosition position);

  /// Returns the primary position of the cursor.
  external Position? getPosition();

  /// Set the primary position of the cursor. This will remove any secondary
  /// cursors.
  /// - [position]:  New primary cursor's position
  /// - [source]:  Source of the call that caused the position
  external JSAny? setPosition(IPosition position, [String? source]);

  /// Scroll vertically as necessary and reveal a line.
  external JSAny? revealLine(num lineNumber, [ScrollType? scrollType]);

  /// Scroll vertically as necessary and reveal a line centered vertically.
  external JSAny? revealLineInCenter(num lineNumber, [ScrollType? scrollType]);

  /// Scroll vertically as necessary and reveal a line centered vertically only
  /// if it lies outside the viewport.
  external JSAny? revealLineInCenterIfOutsideViewport(
    num lineNumber, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically as necessary and reveal a line close to the top of the
  /// viewport,
  /// optimized for viewing a code definition.
  external JSAny? revealLineNearTop(num lineNumber, [ScrollType? scrollType]);

  /// Scroll vertically or horizontally as necessary and reveal a position.
  external JSAny? revealPosition(IPosition position, [ScrollType? scrollType]);

  /// Scroll vertically or horizontally as necessary and reveal a position
  /// centered vertically.
  external JSAny? revealPositionInCenter(
    IPosition position, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically or horizontally as necessary and reveal a position
  /// centered vertically only if it lies outside the viewport.
  external JSAny? revealPositionInCenterIfOutsideViewport(
    IPosition position, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically or horizontally as necessary and reveal a position close
  /// to the top of the viewport,
  /// optimized for viewing a code definition.
  external JSAny? revealPositionNearTop(
    IPosition position, [
    ScrollType? scrollType,
  ]);

  /// Returns the primary selection of the editor.
  external Selection? getSelection();

  /// Returns all the selections of the editor.
  external JSArray<Selection>? getSelections();

  /// Set the primary selection of the editor. This will remove any secondary
  /// cursors.
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  external JSAny? setSelection(IRange selection, [String? source]);

  /// Set the primary selection of the editor. This will remove any secondary
  /// cursors.
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  @JS('setSelection')
  external JSAny? setSelection$1(Range selection, [String? source]);

  /// Set the primary selection of the editor. This will remove any secondary
  /// cursors.
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  @JS('setSelection')
  external JSAny? setSelection$2(ISelection selection, [String? source]);

  /// Set the primary selection of the editor. This will remove any secondary
  /// cursors.
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  /// - [selection]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  @JS('setSelection')
  external JSAny? setSelection$3(Selection selection, [String? source]);

  /// Set the selections for all the cursors of the editor.
  /// Cursors will be removed or added, as necessary.
  /// - [selections]:  The new selection
  /// - [source]:  Source of the call that caused the selection
  external JSAny? setSelections(
    JSArray<ISelection> selections, [
    String? source,
  ]);

  /// Scroll vertically as necessary and reveal lines.
  external JSAny? revealLines(
    num startLineNumber,
    num endLineNumber, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically as necessary and reveal lines centered vertically.
  external JSAny? revealLinesInCenter(
    num lineNumber,
    num endLineNumber, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically as necessary and reveal lines centered vertically only
  /// if it lies outside the viewport.
  external JSAny? revealLinesInCenterIfOutsideViewport(
    num lineNumber,
    num endLineNumber, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically as necessary and reveal lines close to the top of the
  /// viewport,
  /// optimized for viewing a code definition.
  external JSAny? revealLinesNearTop(
    num lineNumber,
    num endLineNumber, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically or horizontally as necessary and reveal a range.
  external JSAny? revealRange(IRange range, [ScrollType? scrollType]);

  /// Scroll vertically or horizontally as necessary and reveal a range centered
  /// vertically.
  external JSAny? revealRangeInCenter(IRange range, [ScrollType? scrollType]);

  /// Scroll vertically or horizontally as necessary and reveal a range at the
  /// top of the viewport.
  external JSAny? revealRangeAtTop(IRange range, [ScrollType? scrollType]);

  /// Scroll vertically or horizontally as necessary and reveal a range centered
  /// vertically only if it lies outside the viewport.
  external JSAny? revealRangeInCenterIfOutsideViewport(
    IRange range, [
    ScrollType? scrollType,
  ]);

  /// Scroll vertically or horizontally as necessary and reveal a range close to
  /// the top of the viewport,
  /// optimized for viewing a code definition.
  external JSAny? revealRangeNearTop(IRange range, [ScrollType? scrollType]);

  /// Scroll vertically or horizontally as necessary and reveal a range close to
  /// the top of the viewport,
  /// optimized for viewing a code definition. Only if it lies outside the
  /// viewport.
  external JSAny? revealRangeNearTopIfOutsideViewport(
    IRange range, [
    ScrollType? scrollType,
  ]);

  /// Directly trigger a handler or an editor action.
  /// - [source]:  The source of the call.
  /// - [handlerId]:  The id of the handler or the id of a contribution.
  /// - [payload]:  Extra data to be sent to the handler.
  external JSAny? trigger(String? source, String handlerId, JSAny? payload);

  /// Gets the current model attached to this editor.
  external IEditorModel? getModel();

  /// Sets the current model attached to this editor.
  /// If the previous model was created by the editor via the value key in the
  /// options
  /// literal object, it will be destroyed. Otherwise, if the previous model was
  /// set
  /// via setModel, or the model key in the options literal object, the previous
  /// model
  /// will not be destroyed.
  /// It is safe to call setModel(null) to simply detach the current model from
  /// the editor.
  external JSAny? setModel(IEditorModel? model);

  /// Create a collection of decorations. All decorations added through this
  /// collection
  /// will get the ownerId of the editor (meaning they will not show up in other
  /// editors).
  /// These decorations will be automatically cleared when the editor's model
  /// changes.
  external IEditorDecorationsCollection createDecorationsCollection([
    JSArray<IModelDeltaDecoration?>? decorations,
  ]);
}
extension type const EditorOption._(int _) {
  static const EditorOption acceptSuggestionOnCommitCharacter = EditorOption._(
    0,
  );

  static const EditorOption acceptSuggestionOnEnter = EditorOption._(1);

  static const EditorOption accessibilitySupport = EditorOption._(2);

  static const EditorOption accessibilityPageSize = EditorOption._(3);

  static const EditorOption ariaLabel = EditorOption._(4);

  static const EditorOption ariaRequired = EditorOption._(5);

  static const EditorOption autoClosingBrackets = EditorOption._(6);

  static const EditorOption autoClosingComments = EditorOption._(7);

  static const EditorOption screenReaderAnnounceInlineSuggestion =
      EditorOption._(8);

  static const EditorOption autoClosingDelete = EditorOption._(9);

  static const EditorOption autoClosingOvertype = EditorOption._(10);

  static const EditorOption autoClosingQuotes = EditorOption._(11);

  static const EditorOption autoIndent = EditorOption._(12);

  static const EditorOption automaticLayout = EditorOption._(13);

  static const EditorOption autoSurround = EditorOption._(14);

  static const EditorOption bracketPairColorization = EditorOption._(15);

  static const EditorOption guides = EditorOption._(16);

  static const EditorOption codeLens = EditorOption._(17);

  static const EditorOption codeLensFontFamily = EditorOption._(18);

  static const EditorOption codeLensFontSize = EditorOption._(19);

  static const EditorOption colorDecorators = EditorOption._(20);

  static const EditorOption colorDecoratorsLimit = EditorOption._(21);

  static const EditorOption columnSelection = EditorOption._(22);

  static const EditorOption comments = EditorOption._(23);

  static const EditorOption contextmenu = EditorOption._(24);

  static const EditorOption copyWithSyntaxHighlighting = EditorOption._(25);

  static const EditorOption cursorBlinking = EditorOption._(26);

  static const EditorOption cursorSmoothCaretAnimation = EditorOption._(27);

  static const EditorOption cursorStyle = EditorOption._(28);

  static const EditorOption cursorSurroundingLines = EditorOption._(29);

  static const EditorOption cursorSurroundingLinesStyle = EditorOption._(30);

  static const EditorOption cursorWidth = EditorOption._(31);

  static const EditorOption disableLayerHinting = EditorOption._(32);

  static const EditorOption disableMonospaceOptimizations = EditorOption._(33);

  static const EditorOption domReadOnly = EditorOption._(34);

  static const EditorOption dragAndDrop = EditorOption._(35);

  static const EditorOption dropIntoEditor = EditorOption._(36);

  static const EditorOption emptySelectionClipboard = EditorOption._(37);

  static const EditorOption experimentalWhitespaceRendering = EditorOption._(
    38,
  );

  static const EditorOption extraEditorClassName = EditorOption._(39);

  static const EditorOption fastScrollSensitivity = EditorOption._(40);

  static const EditorOption find = EditorOption._(41);

  static const EditorOption fixedOverflowWidgets = EditorOption._(42);

  static const EditorOption folding = EditorOption._(43);

  static const EditorOption foldingStrategy = EditorOption._(44);

  static const EditorOption foldingHighlight = EditorOption._(45);

  static const EditorOption foldingImportsByDefault = EditorOption._(46);

  static const EditorOption foldingMaximumRegions = EditorOption._(47);

  static const EditorOption unfoldOnClickAfterEndOfLine = EditorOption._(48);

  static const EditorOption fontFamily = EditorOption._(49);

  static const EditorOption fontInfo = EditorOption._(50);

  static const EditorOption fontLigatures = EditorOption._(51);

  static const EditorOption fontSize = EditorOption._(52);

  static const EditorOption fontWeight = EditorOption._(53);

  static const EditorOption fontVariations = EditorOption._(54);

  static const EditorOption formatOnPaste = EditorOption._(55);

  static const EditorOption formatOnType = EditorOption._(56);

  static const EditorOption glyphMargin = EditorOption._(57);

  static const EditorOption gotoLocation = EditorOption._(58);

  static const EditorOption hideCursorInOverviewRuler = EditorOption._(59);

  static const EditorOption hover = EditorOption._(60);

  static const EditorOption inDiffEditor = EditorOption._(61);

  static const EditorOption inlineSuggest = EditorOption._(62);

  static const EditorOption inlineEdit = EditorOption._(63);

  static const EditorOption letterSpacing = EditorOption._(64);

  static const EditorOption lightbulb = EditorOption._(65);

  static const EditorOption lineDecorationsWidth = EditorOption._(66);

  static const EditorOption lineHeight = EditorOption._(67);

  static const EditorOption lineNumbers = EditorOption._(68);

  static const EditorOption lineNumbersMinChars = EditorOption._(69);

  static const EditorOption linkedEditing = EditorOption._(70);

  static const EditorOption links = EditorOption._(71);

  static const EditorOption matchBrackets = EditorOption._(72);

  static const EditorOption minimap = EditorOption._(73);

  static const EditorOption mouseStyle = EditorOption._(74);

  static const EditorOption mouseWheelScrollSensitivity = EditorOption._(75);

  static const EditorOption mouseWheelZoom = EditorOption._(76);

  static const EditorOption multiCursorMergeOverlapping = EditorOption._(77);

  static const EditorOption multiCursorModifier = EditorOption._(78);

  static const EditorOption multiCursorPaste = EditorOption._(79);

  static const EditorOption multiCursorLimit = EditorOption._(80);

  static const EditorOption occurrencesHighlight = EditorOption._(81);

  static const EditorOption overviewRulerBorder = EditorOption._(82);

  static const EditorOption overviewRulerLanes = EditorOption._(83);

  static const EditorOption padding = EditorOption._(84);

  static const EditorOption pasteAs = EditorOption._(85);

  static const EditorOption parameterHints = EditorOption._(86);

  static const EditorOption peekWidgetDefaultFocus = EditorOption._(87);

  static const EditorOption placeholder = EditorOption._(88);

  static const EditorOption definitionLinkOpensInPeek = EditorOption._(89);

  static const EditorOption quickSuggestions = EditorOption._(90);

  static const EditorOption quickSuggestionsDelay = EditorOption._(91);

  static const EditorOption readOnly = EditorOption._(92);

  static const EditorOption readOnlyMessage = EditorOption._(93);

  static const EditorOption renameOnType = EditorOption._(94);

  static const EditorOption renderControlCharacters = EditorOption._(95);

  static const EditorOption renderFinalNewline = EditorOption._(96);

  static const EditorOption renderLineHighlight = EditorOption._(97);

  static const EditorOption renderLineHighlightOnlyWhenFocus = EditorOption._(
    98,
  );

  static const EditorOption renderValidationDecorations = EditorOption._(99);

  static const EditorOption renderWhitespace = EditorOption._(100);

  static const EditorOption revealHorizontalRightPadding = EditorOption._(101);

  static const EditorOption roundedSelection = EditorOption._(102);

  static const EditorOption rulers = EditorOption._(103);

  static const EditorOption scrollbar = EditorOption._(104);

  static const EditorOption scrollBeyondLastColumn = EditorOption._(105);

  static const EditorOption scrollBeyondLastLine = EditorOption._(106);

  static const EditorOption scrollPredominantAxis = EditorOption._(107);

  static const EditorOption selectionClipboard = EditorOption._(108);

  static const EditorOption selectionHighlight = EditorOption._(109);

  static const EditorOption selectOnLineNumbers = EditorOption._(110);

  static const EditorOption showFoldingControls = EditorOption._(111);

  static const EditorOption showUnused = EditorOption._(112);

  static const EditorOption snippetSuggestions = EditorOption._(113);

  static const EditorOption smartSelect = EditorOption._(114);

  static const EditorOption smoothScrolling = EditorOption._(115);

  static const EditorOption stickyScroll = EditorOption._(116);

  static const EditorOption stickyTabStops = EditorOption._(117);

  static const EditorOption stopRenderingLineAfter = EditorOption._(118);

  static const EditorOption suggest = EditorOption._(119);

  static const EditorOption suggestFontSize = EditorOption._(120);

  static const EditorOption suggestLineHeight = EditorOption._(121);

  static const EditorOption suggestOnTriggerCharacters = EditorOption._(122);

  static const EditorOption suggestSelection = EditorOption._(123);

  static const EditorOption tabCompletion = EditorOption._(124);

  static const EditorOption tabIndex = EditorOption._(125);

  static const EditorOption unicodeHighlighting = EditorOption._(126);

  static const EditorOption unusualLineTerminators = EditorOption._(127);

  static const EditorOption useShadowDOM = EditorOption._(128);

  static const EditorOption useTabStops = EditorOption._(129);

  static const EditorOption wordBreak = EditorOption._(130);

  static const EditorOption wordSegmenterLocales = EditorOption._(131);

  static const EditorOption wordSeparators = EditorOption._(132);

  static const EditorOption wordWrap = EditorOption._(133);

  static const EditorOption wordWrapBreakAfterCharacters = EditorOption._(134);

  static const EditorOption wordWrapBreakBeforeCharacters = EditorOption._(135);

  static const EditorOption wordWrapColumn = EditorOption._(136);

  static const EditorOption wordWrapOverride1 = EditorOption._(137);

  static const EditorOption wordWrapOverride2 = EditorOption._(138);

  static const EditorOption wrappingIndent = EditorOption._(139);

  static const EditorOption wrappingStrategy = EditorOption._(140);

  static const EditorOption showDeprecated = EditorOption._(141);

  static const EditorOption inlayHints = EditorOption._(142);

  static const EditorOption editorClassName = EditorOption._(143);

  static const EditorOption pixelRatio = EditorOption._(144);

  static const EditorOption tabFocusMode = EditorOption._(145);

  static const EditorOption layoutInfo = EditorOption._(146);

  static const EditorOption wrappingInfo = EditorOption._(147);

  static const EditorOption defaultColorDecorators = EditorOption._(148);

  static const EditorOption colorDecoratorsActivatedOn = EditorOption._(149);

  static const EditorOption inlineCompletionsAccessibilityVerbose =
      EditorOption._(150);
}

/// An event describing that the configuration of the editor has changed.
extension type ConfigurationChangedEvent._(JSObject _) implements JSObject {
  external ConfigurationChangedEvent();

  external bool hasChanged(EditorOption id);
}

/// Describes the reason the cursor has changed its position.
extension type const CursorChangeReason._(int _) {
  /// Unknown or not set.
  static const CursorChangeReason NotSet = CursorChangeReason._(0);

  /// A `model.setValue()` was called.
  static const CursorChangeReason ContentFlush = CursorChangeReason._(1);

  /// The `model` has been changed outside of this cursor and the cursor
  /// recovers its position from associated markers.
  static const CursorChangeReason RecoverFromMarkers = CursorChangeReason._(2);

  /// There was an explicit user gesture.
  static const CursorChangeReason Explicit = CursorChangeReason._(3);

  /// There was a Paste.
  static const CursorChangeReason Paste = CursorChangeReason._(4);

  /// There was an Undo.
  static const CursorChangeReason Undo = CursorChangeReason._(5);

  /// There was a Redo.
  static const CursorChangeReason Redo = CursorChangeReason._(6);
}

/// An event describing that the cursor position has changed.
extension type ICursorPositionChangedEvent._(JSObject _) implements JSObject {
  /// Primary cursor's position.
  external Position get position;

  /// Secondary cursors' position.
  external JSArray<Position> get secondaryPositions;

  /// Reason.
  external CursorChangeReason get reason;

  /// Source of the call that caused the event.
  external String get source;
}

/// An event describing that the cursor selection has changed.
extension type ICursorSelectionChangedEvent._(JSObject _) implements JSObject {
  /// The primary selection.
  external Selection get selection;

  /// The secondary selections.
  external JSArray<Selection> get secondarySelections;

  /// The model version id.
  external double get modelVersionId;

  /// The old selections.
  external JSArray<Selection>? get oldSelections;

  /// The model version id the that `oldSelections` refer to.
  external double get oldModelVersionId;

  /// Source of the call that caused the event.
  external String get source;

  /// Reason.
  external CursorChangeReason get reason;
}

/// An event describing that an editor has had its model reset (i.e.
/// `editor.setModel()`).
extension type IModelChangedEvent._(JSObject _) implements JSObject {
  /// The `uri` of the previous model or null.
  external Uri? get oldModelUrl;

  /// The `uri` of the new model or null.
  external Uri? get newModelUrl;
}

/// A paste event originating from the editor.
extension type IPasteEvent._(JSObject _) implements JSObject {
  external Range get range;
  external String? get languageId;
  external _i3.ClipboardEvent? get clipboardEvent;
}
extension type IMouseEvent._(JSObject _) implements JSObject {
  external _i3.MouseEvent get browserEvent;
  external bool get leftButton;
  external bool get middleButton;
  external bool get rightButton;
  external double get buttons;
  external _i3.HTMLElement get target;
  external double get detail;
  external double get posx;
  external double get posy;
  external bool get ctrlKey;
  external bool get shiftKey;
  external bool get altKey;
  external bool get metaKey;
  external double get timestamp;
  external JSAny? preventDefault();
  external JSAny? stopPropagation();
}
extension type IBaseMouseTarget._(JSObject _) implements JSObject {
  /// The target element
  external _i3.HTMLElement? get element;

  /// The 'approximate' editor position
  external Position? get position;

  /// Desired mouse column (e.g. when position.column gets clamped to text
  /// length -- clicking after text on a line).
  external double get mouseColumn;

  /// The 'approximate' editor range
  external Range? get range;
}
extension type IMouseTargetUnknown._(JSObject _) implements IBaseMouseTarget {
  external int get type;
}
extension type IMouseTargetTextarea._(JSObject _) implements IBaseMouseTarget {
  external int get type;

  /// The 'approximate' editor position
  @_i2.redeclare
  external JSAny get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external JSAny get range;
}
extension type IMouseTargetMarginData._(JSObject _) implements JSObject {
  external bool get isAfterLines;
  external double get glyphMarginLeft;
  external double get glyphMarginWidth;
  external GlyphMarginLane? get glyphMarginLane;
  external double get lineNumbersWidth;
  external double get offsetX;
}
extension type IMouseTargetMargin._(JSObject _) implements IBaseMouseTarget {
  /// The 'approximate' editor position
  @_i2.redeclare
  external Position get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external Range get range;
  external IMouseTargetMarginData get detail;
}
extension type IMouseTargetViewZoneData._(JSObject _) implements JSObject {
  external String get viewZoneId;
  external Position? get positionBefore;
  external Position? get positionAfter;
  external Position get position;
  external double get afterLineNumber;
}
extension type IMouseTargetViewZone._(JSObject _) implements IBaseMouseTarget {
  /// The 'approximate' editor position
  @_i2.redeclare
  external Position get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external Range get range;
  external IMouseTargetViewZoneData get detail;
}
extension type IMouseTargetContentTextData._(JSObject _) implements JSObject {
  external bool get mightBeForeignElement;
}
extension type IMouseTargetContentText._(JSObject _)
    implements IBaseMouseTarget {
  external int get type;

  /// The 'approximate' editor position
  @_i2.redeclare
  external Position get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external Range get range;
  external IMouseTargetContentTextData get detail;
}
extension type IMouseTargetContentEmptyData._(JSObject _) implements JSObject {
  external bool get isAfterLines;
  external double? get horizontalDistanceToText;
}
extension type IMouseTargetContentEmpty._(JSObject _)
    implements IBaseMouseTarget {
  external int get type;

  /// The 'approximate' editor position
  @_i2.redeclare
  external Position get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external Range get range;
  external IMouseTargetContentEmptyData get detail;
}
extension type IMouseTargetContentWidget._(JSObject _)
    implements IBaseMouseTarget {
  external int get type;

  /// The 'approximate' editor position
  @_i2.redeclare
  external JSAny get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external JSAny get range;
  external String get detail;
}
extension type IMouseTargetOverlayWidget._(JSObject _)
    implements IBaseMouseTarget {
  external int get type;

  /// The 'approximate' editor position
  @_i2.redeclare
  external JSAny get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external JSAny get range;
  external String get detail;
}
extension type IMouseTargetScrollbar._(JSObject _) implements IBaseMouseTarget {
  external int get type;

  /// The 'approximate' editor position
  @_i2.redeclare
  external Position get position;

  /// The 'approximate' editor range
  @_i2.redeclare
  external Range get range;
}
extension type IMouseTargetOverviewRuler._(JSObject _)
    implements IBaseMouseTarget {
  external int get type;
}
extension type IMouseTargetOutsideEditor._(JSObject _)
    implements IBaseMouseTarget {
  external int get type;
  external AnonymousUnion_9797102 get outsidePosition;
  external double get outsideDistance;
}

/// Target hit with the mouse in the editor.
typedef IMouseTarget = AnonymousUnion_2870280;

/// A mouse event originating from the editor.
extension type IEditorMouseEvent._(JSObject _) implements JSObject {
  external IMouseEvent get event;
  external IMouseTarget get target;
}
extension type IPartialEditorMouseEvent._(JSObject _) implements JSObject {
  external IMouseEvent get event;
  external IMouseTarget? get target;
}
extension type IKeyboardEvent._(JSObject _) implements JSObject {
  external _i3.KeyboardEvent get browserEvent;
  external _i3.HTMLElement get target;
  external bool get ctrlKey;
  external bool get shiftKey;
  external bool get altKey;
  external bool get metaKey;
  external bool get altGraphKey;
  external KeyCode get keyCode;
  external String get code;
  external bool equals(num keybinding);
  external JSAny? preventDefault();
  external JSAny? stopPropagation();
}
extension type const RenderMinimap._(int _) {
  static const RenderMinimap None = RenderMinimap._(0);

  static const RenderMinimap Text = RenderMinimap._(1);

  static const RenderMinimap Blocks = RenderMinimap._(2);
}

/// The internal layout details of the editor.
extension type EditorMinimapLayoutInfo._(JSObject _) implements JSObject {
  external RenderMinimap get renderMinimap;
  external double get minimapLeft;
  external double get minimapWidth;
  external bool get minimapHeightIsEditorHeight;
  external bool get minimapIsSampling;
  external double get minimapScale;
  external double get minimapLineHeight;
  external double get minimapCanvasInnerWidth;
  external double get minimapCanvasInnerHeight;
  external double get minimapCanvasOuterWidth;
  external double get minimapCanvasOuterHeight;
}

/// A description for the overview ruler position.
extension type OverviewRulerPosition._(JSObject _) implements JSObject {
  /// Width of the overview ruler
  external double get width;

  /// Height of the overview ruler
  external double get height;

  /// Top position for the overview ruler
  external double get top;

  /// Right position for the overview ruler
  external double get right;
}

/// The internal layout details of the editor.
extension type EditorLayoutInfo._(JSObject _) implements JSObject {
  /// Full editor width.
  external double get width;

  /// Full editor height.
  external double get height;

  /// Left position for the glyph margin.
  external double get glyphMarginLeft;

  /// The width of the glyph margin.
  external double get glyphMarginWidth;

  /// The number of decoration lanes to render in the glyph margin.
  external double get glyphMarginDecorationLaneCount;

  /// Left position for the line numbers.
  external double get lineNumbersLeft;

  /// The width of the line numbers.
  external double get lineNumbersWidth;

  /// Left position for the line decorations.
  external double get decorationsLeft;

  /// The width of the line decorations.
  external double get decorationsWidth;

  /// Left position for the content (actual text)
  external double get contentLeft;

  /// The width of the content (actual text)
  external double get contentWidth;

  /// Layout information for the minimap
  external EditorMinimapLayoutInfo get minimap;

  /// The number of columns (of typical characters) fitting on a viewport line.
  external double get viewportColumn;
  external bool get isWordWrapMinified;
  external bool get isViewportWrapping;
  external double get wrappingColumn;

  /// The width of the vertical scrollbar.
  external double get verticalScrollbarWidth;

  /// The height of the horizontal scrollbar.
  external double get horizontalScrollbarHeight;

  /// The position of the overview ruler.
  external OverviewRulerPosition get overviewRuler;
}
extension type IContentSizeChangedEvent._(JSObject _) implements JSObject {
  external double get contentWidth;
  external double get contentHeight;
  external bool get contentWidthChanged;
  external bool get contentHeightChanged;
}
extension type IScrollEvent._(JSObject _) implements JSObject {
  external double get scrollTop;
  external double get scrollLeft;
  external double get scrollWidth;
  external double get scrollHeight;
  external bool get scrollTopChanged;
  external bool get scrollLeftChanged;
  external bool get scrollWidthChanged;
  external bool get scrollHeightChanged;
}

/// An editor contribution that gets created every time a new editor gets
/// created and gets disposed when the editor gets disposed.
extension type IEditorContribution._(JSObject _) implements JSObject {
  /// Dispose this contribution.
  external JSAny? dispose();

  /// Store view state.
  external JSFunction? get saveViewState;

  /// Restore view state.
  external JSFunction? get restoreViewState;
}
extension type ApplyUpdateResult<T extends JSAny?>._(JSObject _)
    implements JSObject {
  external ApplyUpdateResult(T newValue, bool didChange);

  external T get newValue;
  external bool get didChange;
}
extension type IEditorOption<K extends JSNumber, V extends JSAny?>._(JSObject _)
    implements JSObject {
  external V defaultValue;

  external K get id;
  external String get name;

  /// Might modify `value`.
  external ApplyUpdateResult<V> applyUpdate(V? value, V update);
}

/// All computed editor options.
extension type IComputedEditorOptions._(JSObject _) implements JSObject {}
extension type INewScrollPosition._(JSObject _) implements JSObject {
  external double? scrollLeft;

  external double? scrollTop;
}

/// A builder and helper for edit operations for a command.
extension type IEditOperationBuilder._(JSObject _) implements JSObject {
  /// Add a new edit operation (a replace operation).
  /// - [range]:  The range to replace (delete). May be empty to represent a
  ///   simple insert.
  /// - [text]:  The text to replace with. May be null to represent a simple
  ///   delete.
  external JSAny? addEditOperation(
    IRange range,
    String? text, [
    bool? forceMoveMarkers,
  ]);

  /// Add a new edit operation (a replace operation).
  /// The inverse edits will be accessible in
  /// `ICursorStateComputerData.getInverseEditOperations()`
  /// - [range]:  The range to replace (delete). May be empty to represent a
  ///   simple insert.
  /// - [text]:  The text to replace with. May be null to represent a simple
  ///   delete.
  external JSAny? addTrackedEditOperation(
    IRange range,
    String? text, [
    bool? forceMoveMarkers,
  ]);

  /// Track `selection` when applying edit operations.
  /// A best effort will be made to not grow/expand the selection.
  /// An empty selection will clamp to a nearby character.
  /// - [selection]:  The selection to track.
  /// - [trackPreviousOnEmpty]:  If set, and the selection is empty, indicates
  ///   whether the selection
  /// should clamp to the previous or the next character.
  external String trackSelection(
    Selection selection, [
    bool? trackPreviousOnEmpty,
  ]);
}

/// A helper for computing cursor state after a command.
extension type ICursorStateComputerData._(JSObject _) implements JSObject {
  /// Get the inverse edit operations of the added edit operations.
  external JSArray<IValidEditOperation> getInverseEditOperations();

  /// Get a previously tracked selection.
  /// - [id]:  The unique identifier returned by `trackSelection`.
  external Selection getTrackedSelection(String id);
}

/// A command that modifies text / cursor state on a model.
extension type ICommand._(JSObject _) implements JSObject {
  /// Get the edit operations needed to execute this command.
  /// - [model]:  The model the command will execute on.
  /// - [builder]:  A helper to collect the needed edit operations and to track
  ///   selections.
  external JSAny? getEditOperations(
    ITextModel model,
    IEditOperationBuilder builder,
  );

  /// Compute the cursor state after the edit operations were applied.
  /// - [model]:  The model the command has executed on.
  /// - [helper]:  A helper to get inverse edit operations and to get previously
  ///   tracked selections.
  external Selection computeCursorState(
    ITextModel model,
    ICursorStateComputerData helper,
  );
}

/// A positioning preference for rendering content widgets.
extension type const ContentWidgetPositionPreference._(int _) {
  /// Place the content widget exactly at a position
  static const ContentWidgetPositionPreference EXACT =
      ContentWidgetPositionPreference._(0);

  /// Place the content widget above a position
  static const ContentWidgetPositionPreference ABOVE =
      ContentWidgetPositionPreference._(1);

  /// Place the content widget below a position
  static const ContentWidgetPositionPreference BELOW =
      ContentWidgetPositionPreference._(2);
}
extension type const PositionAffinity._(int _) {
  /// Prefers the left most position.
  static const PositionAffinity Left = PositionAffinity._(0);

  /// Prefers the right most position.
  static const PositionAffinity Right = PositionAffinity._(1);

  /// No preference.
  static const PositionAffinity None = PositionAffinity._(2);

  /// If the given position is on injected text, prefers the position left of
  /// it.
  static const PositionAffinity LeftOfInjectedText = PositionAffinity._(3);

  /// If the given position is on injected text, prefers the position right of
  /// it.
  static const PositionAffinity RightOfInjectedText = PositionAffinity._(4);
}

/// A position for rendering content widgets.
extension type IContentWidgetPosition._(JSObject _) implements JSObject {
  /// Desired position which serves as an anchor for placing the content widget.
  /// The widget will be placed above, at, or below the specified position,
  /// based on the
  /// provided preference. The widget will always touch this position.
  ///
  /// Given sufficient horizontal space, the widget will be placed to the right
  /// of the
  /// passed in position. This can be tweaked by providing a
  /// `secondaryPosition`.
  external IPosition? position;

  /// Optionally, a secondary position can be provided to further define the
  /// placing of
  /// the content widget. The secondary position must have the same line number
  /// as the
  /// primary position. If possible, the widget will be placed such that it also
  /// touches
  /// the secondary position.
  external IPosition? secondaryPosition;

  /// Placement preference for position, in order of preference.
  external JSArray<JSNumber> preference;

  /// Placement preference when multiple view positions refer to the same
  /// (model) position.
  /// This plays a role when injected text is involved.
  external PositionAffinity? positionAffinity;
}

/// A content widget renders inline with the text and can be easily placed
/// 'near' an editor position.
extension type IContentWidget._(JSObject _) implements JSObject {
  /// Render this content widget in a location where it could overflow the
  /// editor's view dom node.
  external bool? allowEditorOverflow;

  /// Call preventDefault() on mousedown events that target the content widget.
  external bool? suppressMouseDown;

  /// Get a unique identifier of the content widget.
  external String getId();

  /// Get the dom node of the content widget.
  external _i3.HTMLElement getDomNode();

  /// Get the placement of the content widget.
  /// If null is returned, the content widget will be placed off screen.
  external IContentWidgetPosition? getPosition();

  /// Optional function that is invoked before rendering
  /// the content widget. If a dimension is returned the editor will
  /// attempt to use it.
  external JSFunction? get beforeRender;

  /// Optional function that is invoked after rendering the content
  /// widget. Is being invoked with the selected position preference
  /// or `null` if not rendered.
  external JSFunction? get afterRender;
}

/// A positioning preference for rendering overlay widgets.
extension type const OverlayWidgetPositionPreference._(int _) {
  /// Position the overlay widget in the top right corner
  static const OverlayWidgetPositionPreference TOP_RIGHT_CORNER =
      OverlayWidgetPositionPreference._(0);

  /// Position the overlay widget in the bottom right corner
  static const OverlayWidgetPositionPreference BOTTOM_RIGHT_CORNER =
      OverlayWidgetPositionPreference._(1);

  /// Position the overlay widget in the top center
  static const OverlayWidgetPositionPreference TOP_CENTER =
      OverlayWidgetPositionPreference._(2);
}

/// Represents editor-relative coordinates of an overlay widget.
extension type IOverlayWidgetPositionCoordinates._(JSObject _)
    implements JSObject {
  /// The top position for the overlay widget, relative to the editor.
  external double top;

  /// The left position for the overlay widget, relative to the editor.
  external double left;
}

/// A position for rendering overlay widgets.
extension type IOverlayWidgetPosition._(JSObject _) implements JSObject {
  /// The position preference for the overlay widget.
  external AnonymousUnion_1292433 preference;

  /// When set, stacks with other overlay widgets with the same preference,
  /// in an order determined by the ordinal value.
  external double? stackOridinal;
}

/// An overlay widgets renders on top of the text.
extension type IOverlayWidget._(JSObject _) implements JSObject {
  /// Event fired when the widget layout changes.
  external IEvent<JSAny?>? onDidLayout;

  /// Render this overlay widget in a location where it could overflow the
  /// editor's view dom node.
  external bool? allowEditorOverflow;

  /// Get a unique identifier of the overlay widget.
  external String getId();

  /// Get the dom node of the overlay widget.
  external _i3.HTMLElement getDomNode();

  /// Get the placement of the overlay widget.
  /// If null is returned, the overlay widget is responsible to place itself.
  external IOverlayWidgetPosition? getPosition();

  /// The editor will ensure that the scroll width is >= than this value.
  external JSFunction? get getMinContentWidthInPx;
}

/// A position for rendering glyph margin widgets.
extension type IGlyphMarginWidgetPosition._(JSObject _) implements JSObject {
  /// The glyph margin lane where the widget should be shown.
  external GlyphMarginLane lane;

  /// The priority order of the widget, used for determining which widget
  /// to render when there are multiple.
  external double zIndex;

  /// The editor range that this widget applies to.
  external IRange range;
}

/// A glyph margin widget renders in the editor glyph margin.
extension type IGlyphMarginWidget._(JSObject _) implements JSObject {
  /// Get a unique identifier of the glyph widget.
  external String getId();

  /// Get the dom node of the glyph widget.
  external _i3.HTMLElement getDomNode();

  /// Get the placement of the glyph widget.
  external IGlyphMarginWidgetPosition getPosition();
}

/// A view zone is a full horizontal rectangle that 'pushes' text down.
/// The editor reserves space for view zones when rendering.
extension type IViewZone._(JSObject _) implements JSObject {
  /// The line number after which this zone should appear.
  /// Use 0 to place a view zone before the first line number.
  external double afterLineNumber;

  /// The column after which this zone should appear.
  /// If not set, the maxLineColumn of `afterLineNumber` will be used.
  /// This is relevant for wrapped lines.
  external double? afterColumn;

  /// If the `afterColumn` has multiple view columns, the affinity specifies
  /// which one to use. Defaults to `none`.
  external PositionAffinity? afterColumnAffinity;

  /// Render the zone even when its line is hidden.
  external bool? showInHiddenAreas;

  /// Tiebreaker that is used when multiple view zones want to be after the same
  /// line.
  /// Defaults to `afterColumn` otherwise 10000;
  external double? ordinal;

  /// Suppress mouse down events.
  /// If set, the editor will attach a mouse down listener to the view zone and
  /// .preventDefault on it.
  /// Defaults to false
  external bool? suppressMouseDown;

  /// The height in lines of the view zone.
  /// If specified, `heightInPx` will be used instead of this.
  /// If neither `heightInPx` nor `heightInLines` is specified, a default of
  /// `heightInLines` = 1 will be chosen.
  external double? heightInLines;

  /// The height in px of the view zone.
  /// If this is set, the editor will give preference to it rather than
  /// `heightInLines` above.
  /// If neither `heightInPx` nor `heightInLines` is specified, a default of
  /// `heightInLines` = 1 will be chosen.
  external double? heightInPx;

  /// The minimum width in px of the view zone.
  /// If this is set, the editor will ensure that the scroll width is >= than
  /// this value.
  external double? minWidthInPx;

  /// The dom node of the view zone
  external _i3.HTMLElement domNode;

  /// An optional dom node for the view zone that will be placed in the margin
  /// area.
  external _i3.HTMLElement? marginDomNode;

  /// Callback which gives the relative top of the view zone as it appears
  /// (taking scrolling into account).
  external _AnonymousFunction_3765586? onDomNodeTop;

  /// Callback which gives the height in pixels of the view zone.
  external _AnonymousFunction_9273974? onComputedHeight;
}

/// An accessor that allows for zones to be added or removed.
extension type IViewZoneChangeAccessor._(JSObject _) implements JSObject {
  /// Create a new view zone.
  /// - [zone]:  Zone to create
  external String addZone(IViewZone zone);

  /// Remove a zone
  /// - [id]:  A unique identifier to the view zone, as returned by the
  ///   `addZone` call.
  external JSAny? removeZone(String id);

  /// Change a zone's position.
  /// The editor will rescan the `afterLineNumber` and `afterColumn` properties
  /// of a view zone.
  external JSAny? layoutZone(String id);
}

/// A rich code editor.
extension type ICodeEditor._(JSObject _) implements IEditor {
  /// An event emitted when the content of the current model has changed.
  external IEvent<IModelContentChangedEvent> get onDidChangeModelContent;

  /// An event emitted when the language of the current model has changed.
  external IEvent<IModelLanguageChangedEvent> get onDidChangeModelLanguage;

  /// An event emitted when the language configuration of the current model has
  /// changed.
  external IEvent<IModelLanguageConfigurationChangedEvent>
  get onDidChangeModelLanguageConfiguration;

  /// An event emitted when the options of the current model has changed.
  external IEvent<IModelOptionsChangedEvent> get onDidChangeModelOptions;

  /// An event emitted when the configuration of the editor has changed. (e.g.
  /// `editor.updateOptions()`)
  external IEvent<ConfigurationChangedEvent> get onDidChangeConfiguration;

  /// An event emitted when the cursor position has changed.
  external IEvent<ICursorPositionChangedEvent> get onDidChangeCursorPosition;

  /// An event emitted when the cursor selection has changed.
  external IEvent<ICursorSelectionChangedEvent> get onDidChangeCursorSelection;

  /// An event emitted when the model of this editor is about to change (e.g.
  /// from `editor.setModel()`).
  external IEvent<IModelChangedEvent> get onWillChangeModel;

  /// An event emitted when the model of this editor has changed (e.g.
  /// `editor.setModel()`).
  external IEvent<IModelChangedEvent> get onDidChangeModel;

  /// An event emitted when the decorations of the current model have changed.
  external IEvent<IModelDecorationsChangedEvent>
  get onDidChangeModelDecorations;

  /// An event emitted when the text inside this editor gained focus (i.e.
  /// cursor starts blinking).
  external IEvent<JSAny?> get onDidFocusEditorText;

  /// An event emitted when the text inside this editor lost focus (i.e. cursor
  /// stops blinking).
  external IEvent<JSAny?> get onDidBlurEditorText;

  /// An event emitted when the text inside this editor or an editor widget
  /// gained focus.
  external IEvent<JSAny?> get onDidFocusEditorWidget;

  /// An event emitted when the text inside this editor or an editor widget lost
  /// focus.
  external IEvent<JSAny?> get onDidBlurEditorWidget;

  /// An event emitted after composition has started.
  external IEvent<JSAny?> get onDidCompositionStart;

  /// An event emitted after composition has ended.
  external IEvent<JSAny?> get onDidCompositionEnd;

  /// An event emitted when editing failed because the editor is read-only.
  external IEvent<JSAny?> get onDidAttemptReadOnlyEdit;

  /// An event emitted when users paste text in the editor.
  external IEvent<IPasteEvent> get onDidPaste;

  /// An event emitted on a "mouseup".
  external IEvent<IEditorMouseEvent> get onMouseUp;

  /// An event emitted on a "mousedown".
  external IEvent<IEditorMouseEvent> get onMouseDown;

  /// An event emitted on a "contextmenu".
  external IEvent<IEditorMouseEvent> get onContextMenu;

  /// An event emitted on a "mousemove".
  external IEvent<IEditorMouseEvent> get onMouseMove;

  /// An event emitted on a "mouseleave".
  external IEvent<IPartialEditorMouseEvent> get onMouseLeave;

  /// An event emitted on a "keyup".
  external IEvent<IKeyboardEvent> get onKeyUp;

  /// An event emitted on a "keydown".
  external IEvent<IKeyboardEvent> get onKeyDown;

  /// An event emitted when the layout of the editor has changed.
  external IEvent<EditorLayoutInfo> get onDidLayoutChange;

  /// An event emitted when the content width or content height in the editor
  /// has changed.
  external IEvent<IContentSizeChangedEvent> get onDidContentSizeChange;

  /// An event emitted when the scroll in the editor has changed.
  external IEvent<IScrollEvent> get onDidScrollChange;

  /// An event emitted when hidden areas change in the editor (e.g. due to
  /// folding).
  external IEvent<JSAny?> get onDidChangeHiddenAreas;

  /// Some editor operations fire multiple events at once.
  /// To allow users to react to multiple events fired by a single operation,
  /// the editor fires a begin update before the operation and an end update
  /// after the operation.
  /// Whenever the editor fires `onBeginUpdate`, it will also fire `onEndUpdate`
  /// once the operation finishes.
  /// Note that not all operations are bracketed by `onBeginUpdate` and
  /// `onEndUpdate`.
  external IEvent<JSAny?> get onBeginUpdate;

  /// Fires after the editor completes the operation it fired `onBeginUpdate`
  /// for.
  external IEvent<JSAny?> get onEndUpdate;

  /// Saves current view state of the editor in a serializable object.
  @_i2.redeclare
  external ICodeEditorViewState? saveViewState();

  /// Restores the view state of the editor from a serializable object generated
  /// by `saveViewState`.
  @_i2.redeclare
  external JSAny? restoreViewState(ICodeEditorViewState? state);

  /// Returns true if the text inside this editor or an editor widget has focus.
  external bool hasWidgetFocus();

  /// Get a contribution of this editor.
  external T? getContribution<T extends IEditorContribution>(String id);

  /// Type the getModel() of IEditor.
  @_i2.redeclare
  external ITextModel? getModel();

  /// Sets the current model attached to this editor.
  /// If the previous model was created by the editor via the value key in the
  /// options
  /// literal object, it will be destroyed. Otherwise, if the previous model was
  /// set
  /// via setModel, or the model key in the options literal object, the previous
  /// model
  /// will not be destroyed.
  /// It is safe to call setModel(null) to simply detach the current model from
  /// the editor.
  @_i2.redeclare
  external JSAny? setModel(ITextModel? model);

  /// Gets all the editor computed options.
  external IComputedEditorOptions getOptions();

  /// Returns the editor's configuration (without any validation or defaults).
  external IEditorOptions getRawOptions();

  /// Get value of the current model attached to this editor.
  external String getValue([AnonymousType_1105536? options]);

  /// Set the value of the current model attached to this editor.
  external JSAny? setValue(String newValue);

  /// Get the width of the editor's content.
  /// This is information that is "erased" when computing `scrollWidth =
  /// Math.max(contentWidth, width)`
  external double getContentWidth();

  /// Get the scrollWidth of the editor's viewport.
  external double getScrollWidth();

  /// Get the scrollLeft of the editor's viewport.
  external double getScrollLeft();

  /// Get the height of the editor's content.
  /// This is information that is "erased" when computing `scrollHeight =
  /// Math.max(contentHeight, height)`
  external double getContentHeight();

  /// Get the scrollHeight of the editor's viewport.
  external double getScrollHeight();

  /// Get the scrollTop of the editor's viewport.
  external double getScrollTop();

  /// Change the scrollLeft of the editor's viewport.
  external JSAny? setScrollLeft(num newScrollLeft, [ScrollType? scrollType]);

  /// Change the scrollTop of the editor's viewport.
  external JSAny? setScrollTop(num newScrollTop, [ScrollType? scrollType]);

  /// Change the scroll position of the editor's viewport.
  external JSAny? setScrollPosition(
    INewScrollPosition position, [
    ScrollType? scrollType,
  ]);

  /// Check if the editor is currently scrolling towards a different scroll
  /// position.
  external bool hasPendingScrollAnimation();

  /// Get an action that is a contribution to this editor.
  external IEditorAction? getAction(String id);

  /// Execute a command on the editor.
  /// The edits will land on the undo-redo stack, but no "undo stop" will be
  /// pushed.
  /// - [source]:  The source of the call.
  /// - [command]:  The command to execute
  external JSAny? executeCommand(String? source, ICommand command);

  /// Create an "undo stop" in the undo-redo stack.
  external bool pushUndoStop();

  /// Remove the "undo stop" in the undo-redo stack.
  external bool popUndoStop();

  /// Execute edits on the editor.
  /// The edits will land on the undo-redo stack, but no "undo stop" will be
  /// pushed.
  /// - [source]:  The source of the call.
  /// - [edits]:  The edits to execute.
  /// - [endCursorState]:  Cursor state after the edits were applied.
  external bool executeEdits(
    String? source,
    JSArray<IIdentifiedSingleEditOperation> edits, [
    AnonymousUnion_4186185? endCursorState,
  ]);

  /// Execute multiple (concomitant) commands on the editor.
  /// - [source]:  The source of the call.
  /// - [command]:  The commands to execute
  external JSAny? executeCommands(String? source, JSArray<ICommand?> commands);

  /// Get all the decorations on a line (filtering out decorations from other
  /// editors).
  external JSArray<IModelDecoration>? getLineDecorations(num lineNumber);

  /// Get all the decorations for a range (filtering out decorations from other
  /// editors).
  external JSArray<IModelDecoration>? getDecorationsInRange(Range range);

  /// All decorations added through this call will get the ownerId of this
  /// editor.
  @Deprecated('Use `createDecorationsCollection`')
  external JSArray<JSString> deltaDecorations(
    JSArray<JSString> oldDecorations,
    JSArray<IModelDeltaDecoration> newDecorations,
  );

  /// Remove previously added decorations.
  external JSAny? removeDecorations(JSArray<JSString> decorationIds);

  /// Get the layout info for the editor.
  external EditorLayoutInfo getLayoutInfo();

  /// Returns the ranges that are currently visible.
  /// Does not account for horizontal scrolling.
  external JSArray<Range> getVisibleRanges();

  /// Get the vertical position (top offset) for the line's top w.r.t. to the
  /// first line.
  external double getTopForLineNumber(num lineNumber, [bool? includeViewZones]);

  /// Get the vertical position (top offset) for the line's bottom w.r.t. to the
  /// first line.
  external double getBottomForLineNumber(num lineNumber);

  /// Get the vertical position (top offset) for the position w.r.t. to the
  /// first line.
  external double getTopForPosition(num lineNumber, num column);

  /// Write the screen reader content to be the current selection
  external JSAny? writeScreenReaderContent(String reason);

  /// Returns the editor's container dom node
  external _i3.HTMLElement getContainerDomNode();

  /// Returns the editor's dom node
  external _i3.HTMLElement? getDomNode();

  /// Add a content widget. Widgets must have unique ids, otherwise they will be
  /// overwritten.
  external JSAny? addContentWidget(IContentWidget widget);

  /// Layout/Reposition a content widget. This is a ping to the editor to call
  /// widget.getPosition()
  /// and update appropriately.
  external JSAny? layoutContentWidget(IContentWidget widget);

  /// Remove a content widget.
  external JSAny? removeContentWidget(IContentWidget widget);

  /// Add an overlay widget. Widgets must have unique ids, otherwise they will
  /// be overwritten.
  external JSAny? addOverlayWidget(IOverlayWidget widget);

  /// Layout/Reposition an overlay widget. This is a ping to the editor to call
  /// widget.getPosition()
  /// and update appropriately.
  external JSAny? layoutOverlayWidget(IOverlayWidget widget);

  /// Remove an overlay widget.
  external JSAny? removeOverlayWidget(IOverlayWidget widget);

  /// Add a glyph margin widget. Widgets must have unique ids, otherwise they
  /// will be overwritten.
  external JSAny? addGlyphMarginWidget(IGlyphMarginWidget widget);

  /// Layout/Reposition a glyph margin widget. This is a ping to the editor to
  /// call widget.getPosition()
  /// and update appropriately.
  external JSAny? layoutGlyphMarginWidget(IGlyphMarginWidget widget);

  /// Remove a glyph margin widget.
  external JSAny? removeGlyphMarginWidget(IGlyphMarginWidget widget);

  /// Change the view zones. View zones are lost when a new model is attached to
  /// the editor.
  external JSAny? changeViewZones(_AnonymousFunction_3726976 callback);

  /// Get the horizontal position (left offset) for the column w.r.t to the
  /// beginning of the line.
  /// This method works only if the line `lineNumber` is currently rendered (in
  /// the editor's viewport).
  /// Use this method with caution.
  external double getOffsetForColumn(num lineNumber, num column);

  /// Force an editor render now.
  external JSAny? render([bool? forceRedraw]);

  /// Get the hit test target at coordinates `clientX` and `clientY`.
  /// The coordinates are relative to the top-left of the viewport.
  ///
  /// Returns Hit test target or null if the coordinates fall outside the editor
  /// or the editor has no model.
  external IMouseTarget? getTargetAtClientPoint(num clientX, num clientY);

  /// Get the visible position for `position`.
  /// The result position takes scrolling into account and is relative to the
  /// top left corner of the editor.
  /// Explanation 1: the results of this method will change for the same
  /// `position` if the user scrolls the editor.
  /// Explanation 2: the results of this method will not change if the container
  /// of the editor gets repositioned.
  /// Warning: the results of this method are inaccurate for positions that are
  /// outside the current editor viewport.
  external AnonymousType_1340361 getScrolledVisiblePosition(IPosition position);

  /// Apply the same font settings as the editor to `target`.
  external JSAny? applyFontInfo(_i3.HTMLElement target);
  external JSAny? setBanner(_i3.HTMLElement? bannerDomNode, num height);

  /// Is called when the model has been set, view state was restored and options
  /// are updated.
  /// This is the best place to compute data for the viewport (such as tokens).
  external JSFunction? get handleInitialized;
}
extension type ICommandHandler._(JSObject _) implements JSObject {
  external JSAny? call(
    JSArray<JSAny?> args, [
    JSArray<JSAny?> args2,
    JSArray<JSAny?> args3,
    JSArray<JSAny?> args4,
    JSArray<JSAny?> args5,
    JSArray<JSAny?> args6,
    JSArray<JSAny?> args7,
    JSArray<JSAny?> args8,
  ]);
}
typedef ContextKeyValue = AnonymousUnion_1977706;
extension type IContextKey<T extends AnonymousUnion_1977706>._(JSObject _)
    implements JSObject {
  @JS('set')
  external JSAny? set$(T value);
  external JSAny? reset();
  @JS('get')
  external T? get$();
}

/// Description of an action contribution
extension type IActionDescriptor._(JSObject _) implements JSObject {
  /// An unique identifier of the contributed action.
  external String id;

  /// A label of the action that will be presented to the user.
  external String label;

  /// Precondition rule. The value should be a
  /// [context key expression](https://code.visualstudio.com/docs/getstarted/keybindings#_when-clause-contexts).
  external String? precondition;

  /// An array of keybindings for the action.
  external JSArray<JSNumber?>? keybindings;

  /// The keybinding rule (condition on top of precondition).
  external String? keybindingContext;

  /// Control if the action should show up in the context menu and where.
  /// The context menu of the editor has these default:
  /// navigation - The navigation group comes first in all cases.
  /// 1_modification - This group comes next and contains commands that modify
  /// your code.
  /// 9_cutcopypaste - The last default group with the basic editing commands.
  /// You can also create your own group.
  /// Defaults to null (don't show in context menu).
  external String? contextMenuGroupId;

  /// Control the order in the context menu group.
  external double? contextMenuOrder;

  /// Method that will be executed when the action is triggered.
  /// - [editor]:  The editor instance is passed in as a convenience
  external AnonymousUnion_1480743 run(
    ICodeEditor editor,
    JSArray<JSAny?> args, [
    JSArray<JSAny?> args2,
    JSArray<JSAny?> args3,
    JSArray<JSAny?> args4,
    JSArray<JSAny?> args5,
    JSArray<JSAny?> args6,
    JSArray<JSAny?> args7,
    JSArray<JSAny?> args8,
  ]);
}
extension type IStandaloneCodeEditor._(JSObject _) implements ICodeEditor {
  /// Update the editor's options after the editor has been created.
  @_i2.redeclare
  external JSAny? updateOptions(AnonymousIntersection_1108773 newOptions);
  external String? addCommand(
    num keybinding,
    ICommandHandler handler, [
    String? context,
  ]);
  external IContextKey<T> createContextKey<T extends AnonymousUnion_1977706>(
    String key,
    T defaultValue,
  );
  external IDisposable addAction(IActionDescriptor descriptor);
}

/// A change
extension type IChange._(JSObject _) implements JSObject {
  external double get originalStartLineNumber;
  external double get originalEndLineNumber;
  external double get modifiedStartLineNumber;
  external double get modifiedEndLineNumber;
}

/// A character level change.
extension type ICharChange._(JSObject _) implements IChange {
  external double get originalStartColumn;
  external double get originalEndColumn;
  external double get modifiedStartColumn;
  external double get modifiedEndColumn;
}

/// A line change
extension type ILineChange._(JSObject _) implements IChange {
  external JSArray<ICharChange>? get charChanges;
}
extension type IDiffEditorBaseOptions._(JSObject _) implements JSObject {
  /// Allow the user to resize the diff editor split view.
  /// Defaults to true.
  external bool? enableSplitViewResizing;

  /// The default ratio when rendering side-by-side editors.
  /// Must be a number between 0 and 1, min sizes apply.
  /// Defaults to 0.5
  external double? splitViewDefaultRatio;

  /// Render the differences in two side-by-side editors.
  /// Defaults to true.
  external bool? renderSideBySide;

  /// When `renderSideBySide` is enabled, `useInlineViewWhenSpaceIsLimited` is
  /// set,
  /// and the diff editor has a width less than
  /// `renderSideBySideInlineBreakpoint`, the inline view is used.
  external double? renderSideBySideInlineBreakpoint;

  /// When `renderSideBySide` is enabled, `useInlineViewWhenSpaceIsLimited` is
  /// set,
  /// and the diff editor has a width less than
  /// `renderSideBySideInlineBreakpoint`, the inline view is used.
  external bool? useInlineViewWhenSpaceIsLimited;

  /// If set, the diff editor is optimized for small views.
  /// Defaults to `false`.
  external bool? compactMode;

  /// Timeout in milliseconds after which diff computation is cancelled.
  /// Defaults to 5000.
  external double? maxComputationTime;

  /// Maximum supported file size in MB.
  /// Defaults to 50.
  external double? maxFileSize;

  /// Compute the diff by ignoring leading/trailing whitespace
  /// Defaults to true.
  external bool? ignoreTrimWhitespace;

  /// Render +/- indicators for added/deleted changes.
  /// Defaults to true.
  external bool? renderIndicators;

  /// Shows icons in the glyph margin to revert changes.
  /// Default to true.
  external bool? renderMarginRevertIcon;

  /// Indicates if the gutter menu should be rendered.
  external bool? renderGutterMenu;

  /// Original model should be editable?
  /// Defaults to false.
  external bool? originalEditable;

  /// Should the diff editor enable code lens?
  /// Defaults to false.
  external bool? diffCodeLens;

  /// Is the diff editor should render overview ruler
  /// Defaults to true
  external bool? renderOverviewRuler;

  /// Control the wrapping of the diff editor.
  external AnonymousUnion_1569193? diffWordWrap;

  /// Diff Algorithm
  external AnonymousUnion_5232810? diffAlgorithm;

  /// Whether the diff editor aria label should be verbose.
  external bool? accessibilityVerbose;

  external AnonymousType_3503859? experimental;

  /// Is the diff editor inside another editor
  /// Defaults to false
  external bool? isInEmbeddedEditor;

  /// If the diff editor should only show the difference review mode.
  external bool? onlyShowAccessibleDiffViewer;

  external AnonymousType_1028919? hideUnchangedRegions;
}

/// Configuration options for the diff editor.
extension type IDiffEditorOptions._(JSObject _)
    implements IEditorOptions, IDiffEditorBaseOptions {}

/// A rich diff editor.
extension type IDiffEditor._(JSObject _) implements IEditor {
  /// An event emitted when the diff information computed by this diff editor
  /// has been updated.
  external IEvent<JSAny?> get onDidUpdateDiff;

  /// An event emitted when the diff model is changed (i.e. the diff editor
  /// shows new content).
  external IEvent<JSAny?> get onDidChangeModel;
  external _i3.HTMLElement getContainerDomNode();

  /// Saves current view state of the editor in a serializable object.
  @_i2.redeclare
  external IDiffEditorViewState? saveViewState();

  /// Restores the view state of the editor from a serializable object generated
  /// by `saveViewState`.
  @_i2.redeclare
  external JSAny? restoreViewState(IDiffEditorViewState? state);

  /// Type the getModel() of IEditor.
  @_i2.redeclare
  external IDiffEditorModel? getModel();
  external IDiffEditorViewModel createViewModel(IDiffEditorModel model);

  /// Sets the current model attached to this editor.
  /// If the previous model was created by the editor via the value key in the
  /// options
  /// literal object, it will be destroyed. Otherwise, if the previous model was
  /// set
  /// via setModel, or the model key in the options literal object, the previous
  /// model
  /// will not be destroyed.
  /// It is safe to call setModel(null) to simply detach the current model from
  /// the editor.
  @_i2.redeclare
  external JSAny? setModel(AnonymousUnion_1651566 model);

  /// Get the `original` editor.
  external ICodeEditor getOriginalEditor();

  /// Get the `modified` editor.
  external ICodeEditor getModifiedEditor();

  /// Get the computed diff information.
  external JSArray<ILineChange>? getLineChanges();

  /// Update the editor's options after the editor has been created.
  @_i2.redeclare
  external JSAny? updateOptions(IDiffEditorOptions newOptions);

  /// Jumps to the next or previous diff.
  external JSAny? goToDiff(AnonymousUnion_5800417 target);

  /// Scrolls to the first diff.
  /// (Waits until the diff computation finished.)
  external JSAny? revealFirstDiff();
  external JSAny? accessibleDiffViewerNext();
  external JSAny? accessibleDiffViewerPrev();
  external JSAny? handleInitialized();
}
extension type IDiffEditorConstructionOptions._(JSObject _)
    implements IDiffEditorOptions, IEditorConstructionOptions {
  /// Place overflow widgets inside an external DOM node.
  /// Defaults to an internal DOM node.
  external _i3.HTMLElement? overflowWidgetsDomNode;

  /// Aria label for original editor.
  external String? originalAriaLabel;

  /// Aria label for modified editor.
  external String? modifiedAriaLabel;
}

/// The options to create a diff editor.
extension type IStandaloneDiffEditorConstructionOptions._(JSObject _)
    implements IDiffEditorConstructionOptions {
  /// Initial theme to be used for rendering.
  /// The current out-of-the-box available themes are: 'vs' (default),
  /// 'vs-dark', 'hc-black', 'hc-light.
  /// You can create custom themes via `monaco.editor.defineTheme`.
  /// To switch a theme, use `monaco.editor.setTheme`.
  /// **NOTE**: The theme might be overwritten if the OS is in high contrast
  /// mode, unless `autoDetectHighContrast` is set to false.
  external String? theme;

  /// If enabled, will automatically change to high contrast theme if the OS is
  /// using a high contrast theme.
  /// Defaults to true.
  external bool? autoDetectHighContrast;
}
extension type IStandaloneDiffEditor._(JSObject _) implements IDiffEditor {
  external String? addCommand(
    num keybinding,
    ICommandHandler handler, [
    String? context,
  ]);
  external IContextKey<T> createContextKey<T extends AnonymousUnion_1977706>(
    String key,
    T defaultValue,
  );
  external IDisposable addAction(IActionDescriptor descriptor);

  /// Get the `original` editor.
  @_i2.redeclare
  external IStandaloneCodeEditor getOriginalEditor();

  /// Get the `modified` editor.
  @_i2.redeclare
  external IStandaloneCodeEditor getModifiedEditor();
}

/// Description of a command contribution
extension type ICommandDescriptor._(JSObject _) implements JSObject {
  /// An unique identifier of the contributed command.
  external String id;

  /// Callback that will be executed when the command is triggered.
  external ICommandHandler run;
}

/// A keybinding rule.
extension type IKeybindingRule._(JSObject _) implements JSObject {
  external double keybinding;

  external String? command;

  external JSAny? commandArgs;

  external String? when;
}
extension type const MarkerSeverity._(int _) {
  static const MarkerSeverity Hint = MarkerSeverity._(1);

  static const MarkerSeverity Info = MarkerSeverity._(2);

  static const MarkerSeverity Warning = MarkerSeverity._(4);

  static const MarkerSeverity Error = MarkerSeverity._(8);
}
extension type IRelatedInformation._(JSObject _) implements JSObject {
  external Uri resource;

  external String message;

  external double startLineNumber;

  external double startColumn;

  external double endLineNumber;

  external double endColumn;
}
extension type const MarkerTag._(int _) {
  static const MarkerTag Unnecessary = MarkerTag._(1);

  static const MarkerTag Deprecated = MarkerTag._(2);
}

/// A structure defining a problem/warning/etc.
extension type IMarkerData._(JSObject _) implements JSObject {
  external AnonymousUnion_6455845? code;

  external MarkerSeverity severity;

  external String message;

  external String? source;

  external double startLineNumber;

  external double startColumn;

  external double endLineNumber;

  external double endColumn;

  external double? modelVersionId;

  external JSArray<IRelatedInformation?>? relatedInformation;

  external JSArray<JSNumber?>? tags;
}
extension type IMarker._(JSObject _) implements JSObject {
  external String owner;

  external Uri resource;

  external MarkerSeverity severity;

  external AnonymousUnion_6455845? code;

  external String message;

  external String? source;

  external double startLineNumber;

  external double startColumn;

  external double endLineNumber;

  external double endColumn;

  external double? modelVersionId;

  external JSArray<IRelatedInformation?>? relatedInformation;

  external JSArray<JSNumber?>? tags;
}
extension type IWebWorkerOptions._(JSObject _) implements JSObject {
  /// The AMD moduleId to load.
  /// It should export a function `create` that should return the exported
  /// proxy.
  external String moduleId;

  /// The data to send over when calling create on the module.
  external JSAny? createData;

  /// A label to be used to identify the web worker for debugging purposes.
  external String? label;

  /// An object that can be used by the web worker to make calls back to the
  /// main thread.
  external JSAny? host;

  /// Keep idle models.
  /// Defaults to false, which means that idle models will stop syncing after a
  /// while.
  external bool? keepIdleModels;
}

/// A web worker that can provide a proxy to an arbitrary file.
extension type MonacoWebWorker<T extends JSAny?>._(JSObject _)
    implements JSObject {
  /// Terminate the web worker, thus invalidating the returned proxy.
  external JSAny? dispose();

  /// Get a proxy to the arbitrary loaded code.
  external JSPromise<T> getProxy();

  /// Synchronize (send) the models at `resources` to the web worker,
  /// making them available in the monaco.worker.getMirrorModels().
  external JSPromise<T> withSyncedResources(JSArray<Uri> resources);
}
extension type IColorizerOptions._(JSObject _) implements JSObject {
  external double? tabSize;
}
extension type IColorizerElementOptions._(JSObject _)
    implements IColorizerOptions {
  external String? theme;

  external String? mimeType;
}
extension type Token._(JSObject _) implements JSObject {
  external Token(num offset, String type, String language);

  external double get offset;
  external String get type;
  external String get language;
  @JS('toString')
  external String toString$();
}
extension type ITokenThemeRule._(JSObject _) implements JSObject {
  external String token;

  external String? foreground;

  external String? background;

  external String? fontStyle;
}
typedef IColors = AnonymousType_5247951;
extension type IStandaloneThemeData._(JSObject _) implements JSObject {
  external String base;

  external bool inherit;

  external JSArray<ITokenThemeRule> rules;

  external JSArray<JSString?>? encodedTokensColors;

  external IColors colors;
}
extension type ILinkOpener._(JSObject _) implements JSObject {
  external AnonymousUnion_1465962 open(Uri resource);
}

/// Represents an object that can handle editor open operations (e.g. when "go
/// to definition" is called
/// with a resource other than the current model).
extension type ICodeEditorOpener._(JSObject _) implements JSObject {
  /// Callback that is invoked when a resource other than the current model
  /// should be opened (e.g. when "go to definition" is called).
  /// The callback should return `true` if the request was handled and `false`
  /// otherwise.
  /// - [source]:  The code editor instance that initiated the request.
  /// - [resource]:  The Uri of the resource that should be opened.
  /// - [selectionOrPosition]:  An optional position or selection inside the
  ///   model corresponding to `resource` that can be used to set the cursor.
  external AnonymousUnion_1465962 openCodeEditor(
    ICodeEditor source,
    Uri resource, [
    AnonymousUnion_7564194? selectionOrPosition,
  ]);
}
extension type const RenderLineNumbersType._(int _) {
  static const RenderLineNumbersType Off = RenderLineNumbersType._(0);

  static const RenderLineNumbersType On = RenderLineNumbersType._(1);

  static const RenderLineNumbersType Relative = RenderLineNumbersType._(2);

  static const RenderLineNumbersType Interval = RenderLineNumbersType._(3);

  static const RenderLineNumbersType Custom = RenderLineNumbersType._(4);
}
extension type const ScrollbarVisibility._(int _) {
  static const ScrollbarVisibility Auto = ScrollbarVisibility._(1);

  static const ScrollbarVisibility Hidden = ScrollbarVisibility._(2);

  static const ScrollbarVisibility Visible = ScrollbarVisibility._(3);
}
extension type const AccessibilitySupport._(int _) {
  /// This should be the browser case where it is not known if a screen reader
  /// is attached or no.
  static const AccessibilitySupport Unknown = AccessibilitySupport._(0);

  static const AccessibilitySupport Disabled = AccessibilitySupport._(1);

  static const AccessibilitySupport Enabled = AccessibilitySupport._(2);
}

/// Configuration options for auto indentation in the editor
extension type const EditorAutoIndentStrategy._(int _) {
  static const EditorAutoIndentStrategy None = EditorAutoIndentStrategy._(0);

  static const EditorAutoIndentStrategy Keep = EditorAutoIndentStrategy._(1);

  static const EditorAutoIndentStrategy Brackets = EditorAutoIndentStrategy._(
    2,
  );

  static const EditorAutoIndentStrategy Advanced = EditorAutoIndentStrategy._(
    3,
  );

  static const EditorAutoIndentStrategy Full = EditorAutoIndentStrategy._(4);
}

/// The kind of animation in which the editor's cursor should be rendered.
extension type const TextEditorCursorBlinkingStyle._(int _) {
  /// Hidden
  static const TextEditorCursorBlinkingStyle Hidden =
      TextEditorCursorBlinkingStyle._(0);

  /// Blinking
  static const TextEditorCursorBlinkingStyle Blink =
      TextEditorCursorBlinkingStyle._(1);

  /// Blinking with smooth fading
  static const TextEditorCursorBlinkingStyle Smooth =
      TextEditorCursorBlinkingStyle._(2);

  /// Blinking with prolonged filled state and smooth fading
  static const TextEditorCursorBlinkingStyle Phase =
      TextEditorCursorBlinkingStyle._(3);

  /// Expand collapse animation on the y axis
  static const TextEditorCursorBlinkingStyle Expand =
      TextEditorCursorBlinkingStyle._(4);

  /// No-Blinking
  static const TextEditorCursorBlinkingStyle Solid =
      TextEditorCursorBlinkingStyle._(5);
}

/// The style in which the editor's cursor should be rendered.
extension type const TextEditorCursorStyle._(int _) {
  /// As a vertical line (sitting between two characters).
  static const TextEditorCursorStyle Line = TextEditorCursorStyle._(1);

  /// As a block (sitting on top of a character).
  static const TextEditorCursorStyle Block = TextEditorCursorStyle._(2);

  /// As a horizontal line (sitting under a character).
  static const TextEditorCursorStyle Underline = TextEditorCursorStyle._(3);

  /// As a thin vertical line (sitting between two characters).
  static const TextEditorCursorStyle LineThin = TextEditorCursorStyle._(4);

  /// As an outlined block (sitting on top of a character).
  static const TextEditorCursorStyle BlockOutline = TextEditorCursorStyle._(5);

  /// As a thin horizontal line (sitting under a character).
  static const TextEditorCursorStyle UnderlineThin = TextEditorCursorStyle._(6);
}
extension type BareFontInfo._(JSObject _) implements JSObject {
  external BareFontInfo();

  external double get pixelRatio;
  external String get fontFamily;
  external String get fontWeight;
  external double get fontSize;
  external String get fontFeatureSettings;
  external String get fontVariationSettings;
  external double get lineHeight;
  external double get letterSpacing;
}
extension type FontInfo._(JSObject _) implements BareFontInfo {
  external FontInfo();

  external double get version;
  external bool get isTrusted;
  external bool get isMonospace;
  external double get typicalHalfwidthCharacterWidth;
  external double get typicalFullwidthCharacterWidth;
  external bool get canUseHalfwidthRightwardsArrow;
  external double get spaceWidth;
  external double get middotWidth;
  external double get wsmiddotWidth;
  external double get maxDigitWidth;
}
extension type InternalEditorRenderLineNumbersOptions._(JSObject _)
    implements JSObject {
  external RenderLineNumbersType get renderType;
}
extension type InternalQuickSuggestionsOptions._(JSObject _)
    implements JSObject {
  external QuickSuggestionsValue get other;
  external QuickSuggestionsValue get comments;
  external QuickSuggestionsValue get strings;
}
extension type InternalEditorScrollbarOptions._(JSObject _)
    implements JSObject {
  external double get arrowSize;
  external ScrollbarVisibility get vertical;
  external ScrollbarVisibility get horizontal;
  external bool get useShadows;
  external bool get verticalHasArrows;
  external bool get horizontalHasArrows;
  external bool get handleMouseWheel;
  external bool get alwaysConsumeMouseWheel;
  external double get horizontalScrollbarSize;
  external double get horizontalSliderSize;
  external double get verticalScrollbarSize;
  external double get verticalSliderSize;
  external bool get scrollByPage;
  external bool get ignoreHorizontalScrollbarInContentHeight;
}
extension type EditorWrappingInfo._(JSObject _) implements JSObject {
  external bool get isDominatedByLongLines;
  external bool get isWordWrapMinified;
  external bool get isViewportWrapping;
  external double get wrappingColumn;
}

/// Describes how to indent wrapped lines.
extension type const WrappingIndent._(int _) {
  /// No indentation => wrapped lines begin at column 1.
  static const WrappingIndent None = WrappingIndent._(0);

  /// Same => wrapped lines get the same indentation as the parent.
  static const WrappingIndent Same = WrappingIndent._(1);

  /// Indent => wrapped lines get +1 indentation toward the parent.
  static const WrappingIndent Indent = WrappingIndent._(2);

  /// DeepIndent => wrapped lines get +2 indentation toward the parent.
  static const WrappingIndent DeepIndent = WrappingIndent._(3);
}
extension type IEditorZoom._(JSObject _) implements JSObject {
  external IEvent<JSNumber> onDidChangeZoomLevel;

  external double getZoomLevel();
  external JSAny? setZoomLevel(num zoomLevel);
}
extension type ILanguageExtensionPoint._(JSObject _) implements JSObject {
  external factory ILanguageExtensionPoint._create({
    required String id,
    JSArray<JSString?>? extensions,
    JSArray<JSString?>? filenames,
    JSArray<JSString?>? filenamePatterns,
    String? firstLine,
    JSArray<JSString?>? aliases,
    JSArray<JSString?>? mimetypes,
    Uri? configuration,
  });

  factory ILanguageExtensionPoint({
    required String id,
    List<String>? extensions,
    List<String>? filenames,
    List<String>? filenamePatterns,
    String? firstLine,
    List<String>? aliases,
    List<String>? mimetypes,
    Uri? configuration,
  }) => ILanguageExtensionPoint._create(
    id: id,
    extensions: extensions?.map((e) => e.toJS).toList().toJS,
    filenames: filenames?.map((e) => e.toJS).toList().toJS,
    filenamePatterns: filenamePatterns?.map((e) => e.toJS).toList().toJS,
    firstLine: firstLine,
    aliases: aliases?.map((e) => e.toJS).toList().toJS,
    mimetypes: mimetypes?.map((e) => e.toJS).toList().toJS,
    configuration: configuration,
  );

  external String id;

  external JSArray<JSString?>? extensions;

  external JSArray<JSString?>? filenames;

  external JSArray<JSString?>? filenamePatterns;

  external String? firstLine;

  external JSArray<JSString?>? aliases;

  external JSArray<JSString?>? mimetypes;

  external Uri? configuration;
}

/// A tuple of two characters, like a pair of
/// opening and closing brackets.
typedef CharacterPair = _i4.JSTuple2<JSString, JSString>;

/// Describes how comments for a language work.
extension type CommentRule._(JSObject _) implements JSObject {
  /// The line comment token, like `// this is a comment`
  external String? lineComment;

  /// The block comment character pair, like `/* block comment *&#47;`
  external CharacterPair? blockComment;
}

/// Describes indentation rules for a language.
extension type IndentationRule._(JSObject _) implements JSObject {
  /// If a line matches this pattern, then all the lines after it should be
  /// unindented once (until another rule matches).
  external RegExp decreaseIndentPattern;

  /// If a line matches this pattern, then all the lines after it should be
  /// indented once (until another rule matches).
  external RegExp increaseIndentPattern;

  /// If a line matches this pattern, then **only the next line** after it
  /// should be indented once.
  external RegExp? indentNextLinePattern;

  /// If a line matches this pattern, then its indentation should not be changed
  /// and it should not be evaluated against the other rules.
  external RegExp? unIndentedLinePattern;
}

/// Describes what to do with the indentation when pressing Enter.
extension type const IndentAction._(int _) {
  /// Insert new line and copy the previous line's indentation.
  static const IndentAction None = IndentAction._(0);

  /// Insert new line and indent once (relative to the previous line's
  /// indentation).
  static const IndentAction Indent = IndentAction._(1);

  /// Insert two new lines:
  ///  - the first one indented which will hold the cursor
  ///  - the second one at the same indentation level
  static const IndentAction IndentOutdent = IndentAction._(2);

  /// Insert new line and outdent once (relative to the previous line's
  /// indentation).
  static const IndentAction Outdent = IndentAction._(3);
}

/// Describes what to do when pressing Enter.
extension type EnterAction._(JSObject _) implements JSObject {
  /// Describe what to do with the indentation.
  external IndentAction indentAction;

  /// Describes text to be appended after the new line and after the
  /// indentation.
  external String? appendText;

  /// Describes the number of characters to remove from the new line's
  /// indentation.
  external double? removeText;
}

/// Describes a rule to be evaluated when pressing Enter.
extension type OnEnterRule._(JSObject _) implements JSObject {
  /// This rule will only execute if the text before the cursor matches this
  /// regular expression.
  external RegExp beforeText;

  /// This rule will only execute if the text after the cursor matches this
  /// regular expression.
  external RegExp? afterText;

  /// This rule will only execute if the text above the this line matches this
  /// regular expression.
  external RegExp? previousLineText;

  /// The action to execute.
  external EnterAction action;
}
extension type IAutoClosingPair._(JSObject _) implements JSObject {
  external String open;

  external String close;
}
extension type IAutoClosingPairConditional._(JSObject _)
    implements IAutoClosingPair {
  external JSArray<JSString?>? notIn;
}

/// Describes language specific folding markers such as '#region' and
/// '#endregion'.
/// The start and end regexes will be tested against the contents of all lines
/// and must be designed efficiently:
/// - the regex should start with '^'
/// - regexp flags (i, g) are ignored
extension type FoldingMarkers._(JSObject _) implements JSObject {
  external RegExp start;

  external RegExp end;
}

/// Describes folding rules for a language.
extension type FoldingRules._(JSObject _) implements JSObject {
  /// Used by the indentation based strategy to decide whether empty lines
  /// belong to the previous or the next block.
  /// A language adheres to the off-side rule if blocks in that language are
  /// expressed by their indentation.
  /// See [wikipedia](https://en.wikipedia.org/wiki/Off-side_rule) for more
  /// information.
  /// If not set, `false` is used and empty lines belong to the previous block.
  external bool? offSide;

  /// Region markers used by the language.
  external FoldingMarkers? markers;
}

/// Definition of documentation comments (e.g. Javadoc/JSdoc)
extension type IDocComment._(JSObject _) implements JSObject {
  /// The string that starts a doc comment (e.g. '/**')
  external String open;

  /// The string that appears on the last line and closes the doc comment (e.g.
  /// ' * /').
  external String? close;
}

/// The language configuration interface defines the contract between
/// extensions and
/// various editor features, like automatic bracket insertion, automatic
/// indentation etc.
extension type LanguageConfiguration._(JSObject _) implements JSObject {
  /// The language's comment settings.
  external CommentRule? comments;

  /// The language's brackets.
  /// This configuration implicitly affects pressing Enter around these
  /// brackets.
  external JSArray<CharacterPair?>? brackets;

  /// The language's word definition.
  /// If the language supports Unicode identifiers (e.g. JavaScript), it is
  /// preferable
  /// to provide a word definition that uses exclusion of known separators.
  /// e.g.: A regex that matches anything except known separators (and dot is
  /// allowed to occur in a floating point number):
  /// /(-?\d*\.\d\w*)|([^\`\~\!\@\#\%\^\&\*\(\)\-\=\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g
  external RegExp? wordPattern;

  /// The language's indentation settings.
  external IndentationRule? indentationRules;

  /// The language's rules to be evaluated when pressing Enter.
  external JSArray<OnEnterRule?>? onEnterRules;

  /// The language's auto closing pairs. The 'close' character is automatically
  /// inserted with the
  /// 'open' character is typed. If not set, the configured brackets will be
  /// used.
  external JSArray<IAutoClosingPairConditional?>? autoClosingPairs;

  /// The language's surrounding pairs. When the 'open' character is typed on a
  /// selection, the
  /// selected string is surrounded by the open and close characters. If not
  /// set, the autoclosing pairs
  /// settings will be used.
  external JSArray<IAutoClosingPair?>? surroundingPairs;

  /// Defines a list of bracket pairs that are colorized depending on their
  /// nesting level.
  /// If not set, the configured brackets will be used.
  external JSArray<CharacterPair?>? colorizedBracketPairs;

  /// Defines what characters must be after the cursor for bracket or quote
  /// autoclosing to occur when using the \'languageDefined\' autoclosing
  /// setting.
  ///
  /// This is typically the set of characters which can not start an expression,
  /// such as whitespace, closing brackets, non-unary operators, etc.
  external String? autoCloseBefore;

  /// The language's folding rules.
  external FoldingRules? folding;
}

/// The state of the tokenizer between two lines.
/// It is useful to store flags such as in multiline comment, etc.
/// The model will clone the previous line's state and pass it in to tokenize
/// the next line.
extension type IState._(JSObject _) implements JSObject {
  external IState clone();
  external bool equals(IState other);
}

/// A token.
extension type IToken._(JSObject _) implements JSObject {
  external double startIndex;

  external String scopes;
}

/// The result of a line tokenization.
extension type ILineTokens._(JSObject _) implements JSObject {
  /// The list of tokens on the line.
  external JSArray<IToken> tokens;

  /// The tokenization end state.
  /// A pointer will be held to this and the object should not be modified by
  /// the tokenizer after the pointer is returned.
  external IState endState;
}

/// A "manual" provider of tokens.
extension type TokensProvider._(JSObject _) implements JSObject {
  /// The initial state of a language. Will be the state passed in to tokenize
  /// the first line.
  external IState getInitialState();

  /// Tokenize a line given the state at the beginning of the line.
  external ILineTokens tokenize(String line, IState state);
}

/// The result of a line tokenization.
extension type IEncodedLineTokens._(JSObject _) implements JSObject {
  /// The tokens on the line in a binary, encoded format. Each token occupies
  /// two array indices. For token i:
  ///  - at offset 2*i => startIndex
  ///  - at offset 2*i + 1 => metadata
  /// Meta data is in binary format:
  /// - -------------------------------------------
  /// 3322 2222 2222 1111 1111 1100 0000 0000
  /// 1098 7654 3210 9876 5432 1098 7654 3210
  /// - -------------------------------------------
  /// bbbb bbbb bfff ffff ffFF FFTT LLLL LLLL
  /// - -------------------------------------------
  ///  - L = EncodedLanguageId (8 bits): Use `getEncodedLanguageId` to get the encoded ID of a language.
  ///  - T = StandardTokenType (2 bits): Other = 0, Comment = 1, String = 2, RegEx = 3.
  ///  - F = FontStyle (4 bits): None = 0, Italic = 1, Bold = 2, Underline = 4, Strikethrough = 8.
  ///  - f = foreground ColorId (9 bits)
  ///  - b = background ColorId (9 bits)
  ///  - The color value for each colorId is defined in IStandaloneThemeData.customTokenColors:
  /// e.g. colorId = 1 is stored in IStandaloneThemeData.customTokenColors[1].
  /// Color id = 0 means no color,
  /// id = 1 is for the default foreground color, id = 2 for the default
  /// background.
  external JSUint32Array tokens;

  /// The tokenization end state.
  /// A pointer will be held to this and the object should not be modified by
  /// the tokenizer after the pointer is returned.
  external IState endState;
}

/// A "manual" provider of tokens, returning tokens in a binary form.
extension type EncodedTokensProvider._(JSObject _) implements JSObject {
  /// The initial state of a language. Will be the state passed in to tokenize
  /// the first line.
  external IState getInitialState();

  /// Tokenize a line given the state at the beginning of the line.
  external IEncodedLineTokens tokenizeEncoded(String line, IState state);

  /// Tokenize a line given the state at the beginning of the line.
  external JSFunction? get tokenize;
}

/// An action is either an array of actions...
/// ... or a case statement with guards...
/// ... or a basic action with a token value.
typedef IShortMonarchLanguageAction = String;
extension type IExpandedMonarchLanguageAction._(JSObject _)
    implements JSObject {
  /// array of actions for each parenthesized match group
  external JSArray<JSAny?>? group;

  /// map from string to ILanguageAction
  external Object? cases;

  /// token class (ie. css class) (or "@brackets" or "@rematch")
  external String? token;

  /// the next state to push, or "@push", "@pop", "@popall"
  external String? next;

  /// switch to this state
  external String? switchTo;

  /// go back n characters in the stream
  external double? goBack;

  external String? bracket;

  /// switch to embedded language (using the mimetype) or get out using "@pop"
  external String? nextEmbedded;

  /// log a message to the browser console window
  external String? log;
}
typedef IMonarchLanguageAction = String;

extension type IExpandedMonarchLanguageRule._(JSObject _) implements JSObject {
  external factory IExpandedMonarchLanguageRule._create({
    AnonymousUnion_1023627? regex,
    IMonarchLanguageAction? action,
    String? include,
  });

  factory IExpandedMonarchLanguageRule({
    String? regex,
    IMonarchLanguageAction? action,
    String? include,
  }) => IExpandedMonarchLanguageRule._create(
    regex: regex == null ? null : AnonymousUnion_1023627._(regex.toJS),
    action: action,
    include: include,
  );

  /// match tokens
  external AnonymousUnion_1023627? regex;

  /// action to take on match
  external IMonarchLanguageAction? action;

  /// or an include rule. include all rules from the included state
  external String? include;
}
typedef IMonarchLanguageRule = String;

/// This interface can be shortened as an array, ie.
/// ['{','}','delimiter.curly']
extension type IMonarchLanguageBracket._(JSObject _) implements JSObject {
  external factory IMonarchLanguageBracket({
    required String open,
    required String close,
    required String token,
  });

  /// open bracket
  external String open;

  /// closing bracket
  external String close;

  /// token class
  external String token;
}

/// A Monarch language definition
extension type IMonarchLanguage._(JSObject _) implements JSObject {
  external factory IMonarchLanguage._create({
    JSObject tokenizer,
    bool? ignoreCase,
    bool? unicode,
    String? defaultToken,
    JSArray<IMonarchLanguageBracket?>? brackets,
    String? start,
    String? tokenPostfix,
    bool? includeLF,
  });

  factory IMonarchLanguage({
    required Map<String, List<IExpandedMonarchLanguageRule>> tokenizer,
    bool? ignoreCase,
    bool? unicode,
    String? defaultToken,
    List<IMonarchLanguageBracket?>? brackets,
    String? start,
    String? tokenPostfix,
    bool? includeLF,
  }) => IMonarchLanguage._create(
    tokenizer:
        tokenizer.map((key, value) {
              return MapEntry(key.toJS, value.toJS);
            }).jsify()!
            as JSObject,
    ignoreCase: ignoreCase,
    unicode: unicode,
    defaultToken: defaultToken,
    brackets: brackets?.toJS,
    start: start,
    tokenPostfix: tokenPostfix,
    includeLF: includeLF,
  );

  external JSObject tokenizer;

  /// is the language case insensitive?
  external bool? ignoreCase;

  /// is the language unicode-aware? (i.e., /\u{1D306}/)
  external bool? unicode;

  /// if no match in the tokenizer assign this token class (default 'source')
  external String? defaultToken;

  /// for example [['{','}','delimiter.curly']]
  external JSArray<IMonarchLanguageBracket?>? brackets;

  /// start symbol in the tokenizer (by default the first entry is used)
  external String? start;

  /// attach this to every token class (by default '.' + name)
  external String? tokenPostfix;

  /// include line feeds (in the form of a \n character) at the end of lines
  /// Defaults to false
  external bool? includeLF;

  external JSAny? operator [](String key);
}

/// A provider result represents the values a provider, like the
/// HoverProvider,
/// may return. For once this is the actual result type `T`, like `Hover`, or
/// a thenable that resolves
/// to that type `T`. In addition, `null` and `undefined` can be returned -
/// either directly or from a
/// thenable.
typedef ProviderResult<T extends JSAny?> = JSAny?;

/// A factory for token providers.
extension type TokensProviderFactory._(JSObject _) implements JSObject {
  external ProviderResult<TokensProvider> create();
}
extension type IRelativePattern._(JSObject _) implements JSObject {
  /// A base file path to which this pattern will be matched against relatively.
  external String get base;

  /// A file glob pattern like `*.{ts,js}` that will be matched on file paths
  /// relative to the base path.
  ///
  /// Example: Given a base of `/home/work/folder` and a file path of
  /// `/home/work/folder/index.js`,
  /// the file glob pattern will match on `index.js`.
  external String get pattern;
}
extension type LanguageFilter._(JSObject _) implements JSObject {
  external String? get language;
  external String? get scheme;
  external AnonymousUnion_1421519? get pattern;
  external String? get notebookType;

  /// This provider is implemented in the UI thread.
  external bool? get hasAccessToAllModels;
  external bool? get exclusive;

  /// This provider comes from a builtin extension.
  external bool? get isBuiltin;
}
typedef LanguageSelector = AnonymousUnion_7270688;

/// Value-object that contains additional information when
/// requesting references.
extension type ReferenceContext._(JSObject _) implements JSObject {
  /// Include the declaration of the current symbol.
  external bool includeDeclaration;
}

/// Represents a location inside a resource, such as a line
/// inside a text file.
extension type Location._(JSObject _) implements JSObject {
  /// The resource identifier of this location.
  external Uri uri;

  /// The document range of this locations.
  external IRange range;
}

/// The reference provider interface defines the contract between extensions
/// and
/// the
/// [find references](https://code.visualstudio.com/docs/editor/editingevolved#_peek)-feature.
extension type ReferenceProvider._(JSObject _) implements JSObject {
  /// Provide a set of project-wide references for the given position and
  /// document.
  external ProviderResult<JSArray<Location>> provideReferences(
    ITextModel model,
    Position position,
    ReferenceContext context,
    CancellationToken token,
  );
}
extension type TextEdit._(JSObject _) implements JSObject {
  external IRange range;

  external String text;

  external EndOfLineSequence? eol;
}
extension type WorkspaceEditMetadata._(JSObject _) implements JSObject {
  external bool needsConfirmation;

  external String label;

  external String? description;
}
extension type IWorkspaceTextEdit._(JSObject _) implements JSObject {
  external Uri resource;

  external AnonymousIntersection_1612513 textEdit;

  external double? versionId;

  external WorkspaceEditMetadata? metadata;
}
extension type WorkspaceFileEditOptions._(JSObject _) implements JSObject {
  external bool? overwrite;

  external bool? ignoreIfNotExists;

  external bool? ignoreIfExists;

  external bool? recursive;

  external bool? copy;

  external bool? folder;

  external bool? skipTrashBin;

  external double? maxSize;
}
extension type IWorkspaceFileEdit._(JSObject _) implements JSObject {
  external Uri? oldResource;

  external Uri? newResource;

  external WorkspaceFileEditOptions? options;

  external WorkspaceEditMetadata? metadata;
}
extension type WorkspaceEdit._(JSObject _) implements JSObject {
  external JSArray<IWorkspaceTextEdit> edits;
}
extension type Rejection._(JSObject _) implements JSObject {
  external String? rejectReason;
}
extension type RenameLocation._(JSObject _) implements JSObject {
  external IRange range;

  external String text;
}
extension type RenameProvider._(JSObject _) implements JSObject {
  external JSFunction? get resolveRenameLocation;
}
extension type const NewSymbolNameTriggerKind._(int _) {
  static const NewSymbolNameTriggerKind Invoke = NewSymbolNameTriggerKind._(0);

  static const NewSymbolNameTriggerKind Automatic = NewSymbolNameTriggerKind._(
    1,
  );
}
extension type const NewSymbolNameTag._(int _) {
  static const NewSymbolNameTag AIGenerated = NewSymbolNameTag._(1);
}
extension type NewSymbolName._(JSObject _) implements JSObject {
  external String get newSymbolName;
  external JSArray<JSNumber?>? get tags;
}
extension type NewSymbolNamesProvider._(JSObject _) implements JSObject {
  external JSPromise<JSBoolean?>? supportsAutomaticNewSymbolNamesTriggerKind;

  external ProviderResult<JSArray<NewSymbolName>> provideNewSymbolNames(
    ITextModel model,
    IRange range,
    NewSymbolNameTriggerKind triggerKind,
    CancellationToken token,
  );
}
extension type const SignatureHelpTriggerKind._(int _) {
  static const SignatureHelpTriggerKind Invoke = SignatureHelpTriggerKind._(1);

  static const SignatureHelpTriggerKind TriggerCharacter =
      SignatureHelpTriggerKind._(2);

  static const SignatureHelpTriggerKind ContentChange =
      SignatureHelpTriggerKind._(3);
}

/// Represents a parameter of a callable-signature. A parameter can
/// have a label and a doc-comment.
extension type ParameterInformation._(JSObject _) implements JSObject {
  /// The label of this signature. Will be shown in
  /// the UI.
  external AnonymousUnion_1311135 label;

  /// The human-readable doc-comment of this signature. Will be shown
  /// in the UI but can be omitted.
  external AnonymousUnion_1021609? documentation;
}

/// Represents the signature of something callable. A signature
/// can have a label, like a function-name, a doc-comment, and
/// a set of parameters.
extension type SignatureInformation._(JSObject _) implements JSObject {
  /// The label of this signature. Will be shown in
  /// the UI.
  external String label;

  /// The human-readable doc-comment of this signature. Will be shown
  /// in the UI but can be omitted.
  external AnonymousUnion_1021609? documentation;

  /// The parameters of this signature.
  external JSArray<ParameterInformation> parameters;

  /// Index of the active parameter.
  ///
  /// If provided, this is used in place of `SignatureHelp.activeSignature`.
  external double? activeParameter;
}

/// Signature help represents the signature of something
/// callable. There can be multiple signatures but only one
/// active and only one active parameter.
extension type SignatureHelp._(JSObject _) implements JSObject {
  /// One or more signatures.
  external JSArray<SignatureInformation> signatures;

  /// The active signature.
  external double activeSignature;

  /// The active parameter of the active signature.
  external double activeParameter;
}
extension type SignatureHelpContext._(JSObject _) implements JSObject {
  external SignatureHelpTriggerKind get triggerKind;
  external String? get triggerCharacter;
  external bool get isRetrigger;
  external SignatureHelp? get activeSignatureHelp;
}
extension type SignatureHelpResult._(JSObject _) implements IDisposable {
  external SignatureHelp value;
}

/// The signature help provider interface defines the contract between
/// extensions and
/// the
/// [parameter hints](https://code.visualstudio.com/docs/editor/intellisense)-feature.
extension type SignatureHelpProvider._(JSObject _) implements JSObject {
  external ReadonlyArray<JSString?>? get signatureHelpTriggerCharacters;
  external ReadonlyArray<JSString?>? get signatureHelpRetriggerCharacters;

  /// Provide help for the signature at the given position and document.
  external ProviderResult<SignatureHelpResult> provideSignatureHelp(
    ITextModel model,
    Position position,
    CancellationToken token,
    SignatureHelpContext context,
  );
}
extension type HoverVerbosityRequest<THover extends JSAny?>._(JSObject _)
    implements JSObject {
  /// The delta by which to increase/decrease the hover verbosity level
  external double verbosityDelta;

  /// The previous hover for the same position
  external THover previousHover;
}
extension type HoverContext<THover extends JSAny?>._(JSObject _)
    implements JSObject {
  /// Hover verbosity request
  external HoverVerbosityRequest<THover?>? verbosityRequest;
}

extension type Hover._(JSObject _) implements JSObject {
  external factory Hover._create({
    required JSArray<IMarkdownString> contents,
    IRange? range,
  });

  factory Hover({required List<IMarkdownString> contents, IRange? range}) =>
      Hover._create(contents: contents.toJS, range: range);

  /// The contents of this hover.
  /// This is a markdown string or a list of markdown strings.
  external JSArray<IMarkdownString> contents;

  /// The range to which this hover applies. When missing, the
  /// editor will use the range at the current position or the
  /// current position itself.
  external IRange? range;
}

/// The hover provider interface defines the contract between extensions and
/// the
/// [hover](https://code.visualstudio.com/docs/editor/intellisense)-feature.
extension type HoverProvider._(JSObject _) implements JSObject {
  external factory HoverProvider({JSFunction provideHover});

  /// Provide a hover for the given position, context and document. Multiple
  /// hovers at the same
  /// position will be merged by the editor. A hover can have a range which
  /// defaults
  /// to the word range at the position when omitted.
  external Hover? provideHover(
    ITextModel model,
    Position position,
    CancellationToken token, [
    HoverContext<Hover?>? context,
  ]);
}

/// A symbol kind.
extension type const SymbolKind._(int _) {
  static const SymbolKind File = SymbolKind._(0);

  static const SymbolKind Module = SymbolKind._(1);

  static const SymbolKind Namespace = SymbolKind._(2);

  static const SymbolKind Package = SymbolKind._(3);

  static const SymbolKind Class = SymbolKind._(4);

  static const SymbolKind Method = SymbolKind._(5);

  static const SymbolKind Property = SymbolKind._(6);

  static const SymbolKind Field = SymbolKind._(7);

  static const SymbolKind Constructor = SymbolKind._(8);

  static const SymbolKind Enum = SymbolKind._(9);

  static const SymbolKind Interface = SymbolKind._(10);

  static const SymbolKind Function$ = SymbolKind._(11);

  static const SymbolKind Variable = SymbolKind._(12);

  static const SymbolKind Constant = SymbolKind._(13);

  static const SymbolKind String = SymbolKind._(14);

  static const SymbolKind Number = SymbolKind._(15);

  static const SymbolKind Boolean = SymbolKind._(16);

  static const SymbolKind Array = SymbolKind._(17);

  static const SymbolKind Object = SymbolKind._(18);

  static const SymbolKind Key = SymbolKind._(19);

  static const SymbolKind Null = SymbolKind._(20);

  static const SymbolKind EnumMember = SymbolKind._(21);

  static const SymbolKind Struct = SymbolKind._(22);

  static const SymbolKind Event = SymbolKind._(23);

  static const SymbolKind Operator = SymbolKind._(24);

  static const SymbolKind TypeParameter = SymbolKind._(25);
}
extension type const SymbolTag._(int _) {
  static const SymbolTag Deprecated = SymbolTag._(1);
}
extension type DocumentSymbol._(JSObject _) implements JSObject {
  external String name;

  external String detail;

  external SymbolKind kind;

  external ReadonlyArray<JSNumber> tags;

  external String? containerName;

  external IRange range;

  external IRange selectionRange;

  external JSArray<JSAny?>? children;
}

/// The document symbol provider interface defines the contract between
/// extensions and
/// the
/// [go to symbol](https://code.visualstudio.com/docs/editor/editingevolved#_go-to-symbol)-feature.
extension type DocumentSymbolProvider._(JSObject _) implements JSObject {
  external String? displayName;

  /// Provide symbol information for the given document.
  external ProviderResult<JSArray<DocumentSymbol>> provideDocumentSymbols(
    ITextModel model,
    CancellationToken token,
  );
}

/// A document highlight kind.
extension type const DocumentHighlightKind._(int _) {
  /// A textual occurrence.
  static const DocumentHighlightKind Text = DocumentHighlightKind._(0);

  /// Read-access of a symbol, like reading a variable.
  static const DocumentHighlightKind Read = DocumentHighlightKind._(1);

  /// Write-access of a symbol, like writing to a variable.
  static const DocumentHighlightKind Write = DocumentHighlightKind._(2);
}

/// A document highlight is a range inside a text document which deserves
/// special attention. Usually a document highlight is visualized by changing
/// the background color of its range.
extension type DocumentHighlight._(JSObject _) implements JSObject {
  /// The range this highlight applies to.
  external IRange range;

  /// The highlight kind, default is DocumentHighlightKind.Texttext.
  external DocumentHighlightKind? kind;
}

/// The document highlight provider interface defines the contract between
/// extensions and
/// the word-highlight-feature.
extension type DocumentHighlightProvider._(JSObject _) implements JSObject {
  /// Provide a set of document highlights, like all occurrences of a variable
  /// or
  /// all exit-points of a function.
  external ProviderResult<JSArray<DocumentHighlight>> provideDocumentHighlights(
    ITextModel model,
    Position position,
    CancellationToken token,
  );
}

/// Represents a list of ranges that can be edited together along with a word
/// pattern to describe valid contents.
extension type LinkedEditingRanges._(JSObject _) implements JSObject {
  /// A list of ranges that can be edited together. The ranges must have
  /// identical length and text content. The ranges cannot overlap
  external JSArray<IRange> ranges;

  /// An optional word pattern that describes valid contents for the given
  /// ranges.
  /// If no pattern is provided, the language configuration's word pattern will
  /// be used.
  external RegExp? wordPattern;
}

/// The linked editing range provider interface defines the contract between
/// extensions and
/// the linked editing feature.
extension type LinkedEditingRangeProvider._(JSObject _) implements JSObject {
  /// Provide a list of ranges that can be edited together.
  external ProviderResult<LinkedEditingRanges> provideLinkedEditingRanges(
    ITextModel model,
    Position position,
    CancellationToken token,
  );
}
extension type LocationLink._(JSObject _) implements JSObject {
  /// A range to select where this link originates from.
  external IRange? originSelectionRange;

  /// The target uri this link points to.
  external Uri uri;

  /// The full range this link points to.
  external IRange range;

  /// A range to select this link points to. Must be contained
  /// in `LocationLink.range`.
  external IRange? targetSelectionRange;
}
typedef Definition = AnonymousUnion_1319147;

extension type Command._(JSObject _) implements JSObject {
  external String id;

  external String title;

  external String? tooltip;

  external JSArray<JSAny?>? arguments;
}
extension type CodeLens._(JSObject _) implements JSObject {
  external IRange range;

  external String? id;

  external Command? command;
}
extension type CodeLensList._(JSObject _) implements JSObject {
  external JSArray<CodeLens> lenses;

  external JSAny? dispose();
}
extension type CodeLensProvider._(JSObject _) implements JSObject {
  external IEvent<JSAny?>? onDidChange;

  external ProviderResult<CodeLensList> provideCodeLenses(
    ITextModel model,
    CancellationToken token,
  );
  external JSFunction? get resolveCodeLens;
}
extension type const CodeActionTriggerType._(int _) {
  static const CodeActionTriggerType Invoke = CodeActionTriggerType._(1);

  static const CodeActionTriggerType Auto = CodeActionTriggerType._(2);
}

/// Contains additional diagnostic information about the context in which
/// a [code action](#CodeActionProvider.provideCodeActions) is run.
extension type CodeActionContext._(JSObject _) implements JSObject {
  /// An array of diagnostics.
  external JSArray<IMarkerData> get markers;

  /// Requested kind of actions to return.
  external String? get only;

  /// The reason why code actions were requested.
  external CodeActionTriggerType get trigger;
}
extension type CodeAction._(JSObject _) implements JSObject {
  external String title;

  external Command? command;

  external WorkspaceEdit? edit;

  external JSArray<IMarkerData?>? diagnostics;

  external String? kind;

  external bool? isPreferred;

  external bool? isAI;

  external String? disabled;

  external JSArray<IRange?>? ranges;
}
extension type CodeActionList._(JSObject _) implements IDisposable {
  external ReadonlyArray<CodeAction> get actions;
}

/// The code action interface defines the contract between extensions and
/// the
/// [light bulb](https://code.visualstudio.com/docs/editor/editingevolved#_code-action)
/// feature.
extension type CodeActionProvider._(JSObject _) implements JSObject {
  /// Provide commands for the given document and range.
  external ProviderResult<CodeActionList> provideCodeActions(
    ITextModel model,
    Range range,
    CodeActionContext context,
    CancellationToken token,
  );

  /// Given a code action fill in the edit. Will only invoked when missing.
  external JSFunction? get resolveCodeAction;
}

/// Metadata about the type of code actions that a CodeActionProvider
/// provides.
extension type CodeActionProviderMetadata._(JSObject _) implements JSObject {
  /// List of code action kinds that a CodeActionProvider may return.
  ///
  /// This list is used to determine if a given `CodeActionProvider` should be
  /// invoked or not.
  /// To avoid unnecessary computation, every `CodeActionProvider` should list
  /// use `providedCodeActionKinds`. The
  /// list of kinds may either be generic, such as `["quickfix", "refactor",
  /// "source"]`, or list out every kind provided,
  /// such as `["quickfix.removeLine", "source.fixAll" ...]`.
  external JSArray<JSString?>? get providedCodeActionKinds;
}

/// Interface used to format a model
extension type FormattingOptions._(JSObject _) implements JSObject {
  /// Size of a tab in spaces.
  external double tabSize;

  /// Prefer spaces over tabs.
  external bool insertSpaces;
}

/// The document formatting provider interface defines the contract between
/// extensions and
/// the formatting-feature.
extension type DocumentFormattingEditProvider._(JSObject _)
    implements JSObject {
  external String? get displayName;

  /// Provide formatting edits for a whole document.
  external ProviderResult<JSArray<TextEdit>> provideDocumentFormattingEdits(
    ITextModel model,
    FormattingOptions options,
    CancellationToken token,
  );
}

/// The document formatting provider interface defines the contract between
/// extensions and
/// the formatting-feature.
extension type DocumentRangeFormattingEditProvider._(JSObject _)
    implements JSObject {
  external String? get displayName;

  /// Provide formatting edits for a range in a document.
  ///
  /// The given range is a hint and providers can decide to format a smaller
  /// or larger range. Often this is done by adjusting the start and end
  /// of the range to full syntax nodes.
  external ProviderResult<JSArray<TextEdit>>
  provideDocumentRangeFormattingEdits(
    ITextModel model,
    Range range,
    FormattingOptions options,
    CancellationToken token,
  );
  external JSFunction? get provideDocumentRangesFormattingEdits;
}

/// The document formatting provider interface defines the contract between
/// extensions and
/// the formatting-feature.
extension type OnTypeFormattingEditProvider._(JSObject _) implements JSObject {
  external JSArray<JSString> autoFormatTriggerCharacters;

  /// Provide formatting edits after a character has been typed.
  ///
  /// The given position and character should hint to the provider
  /// what range the position to expand to, like find the matching `{`
  /// when `}` has been entered.
  external ProviderResult<JSArray<TextEdit>> provideOnTypeFormattingEdits(
    ITextModel model,
    Position position,
    String ch,
    FormattingOptions options,
    CancellationToken token,
  );
}

/// A link inside the editor.
extension type ILink._(JSObject _) implements JSObject {
  external IRange range;

  external AnonymousUnion_1486863? url;

  external String? tooltip;
}
extension type ILinksList._(JSObject _) implements JSObject {
  external JSArray<ILink> links;

  external JSFunction? get dispose;
}

/// A provider of links.
extension type LinkProvider._(JSObject _) implements JSObject {
  external _AnonymousFunction_6172145? resolveLink;

  external ProviderResult<ILinksList> provideLinks(
    ITextModel model,
    CancellationToken token,
  );
}

/// How a suggest provider was triggered.
extension type const CompletionTriggerKind._(int _) {
  static const CompletionTriggerKind Invoke = CompletionTriggerKind._(0);

  static const CompletionTriggerKind TriggerCharacter = CompletionTriggerKind._(
    1,
  );

  static const CompletionTriggerKind TriggerForIncompleteCompletions =
      CompletionTriggerKind._(2);
}

/// Contains additional information about the context in which
/// CompletionItemProvider.provideCompletionItemscompletion provider is
/// triggered.
extension type CompletionContext._(JSObject _) implements JSObject {
  /// How the completion was triggered.
  external CompletionTriggerKind triggerKind;

  /// Character that triggered the completion item provider.
  ///
  /// `undefined` if provider was not triggered by a character.
  external String? triggerCharacter;
}
extension type CompletionItemLabel._(JSObject _) implements JSObject {
  external String label;

  external String? detail;

  external String? description;
}
extension type const CompletionItemKind._(int _) {
  static const CompletionItemKind Method = CompletionItemKind._(0);

  static const CompletionItemKind Function$ = CompletionItemKind._(1);

  static const CompletionItemKind Constructor = CompletionItemKind._(2);

  static const CompletionItemKind Field = CompletionItemKind._(3);

  static const CompletionItemKind Variable = CompletionItemKind._(4);

  static const CompletionItemKind Class = CompletionItemKind._(5);

  static const CompletionItemKind Struct = CompletionItemKind._(6);

  static const CompletionItemKind Interface = CompletionItemKind._(7);

  static const CompletionItemKind Module = CompletionItemKind._(8);

  static const CompletionItemKind Property = CompletionItemKind._(9);

  static const CompletionItemKind Event = CompletionItemKind._(10);

  static const CompletionItemKind Operator = CompletionItemKind._(11);

  static const CompletionItemKind Unit = CompletionItemKind._(12);

  static const CompletionItemKind Value = CompletionItemKind._(13);

  static const CompletionItemKind Constant = CompletionItemKind._(14);

  static const CompletionItemKind Enum = CompletionItemKind._(15);

  static const CompletionItemKind EnumMember = CompletionItemKind._(16);

  static const CompletionItemKind Keyword = CompletionItemKind._(17);

  static const CompletionItemKind Text = CompletionItemKind._(18);

  static const CompletionItemKind Color = CompletionItemKind._(19);

  static const CompletionItemKind File = CompletionItemKind._(20);

  static const CompletionItemKind Reference = CompletionItemKind._(21);

  static const CompletionItemKind Customcolor = CompletionItemKind._(22);

  static const CompletionItemKind Folder = CompletionItemKind._(23);

  static const CompletionItemKind TypeParameter = CompletionItemKind._(24);

  static const CompletionItemKind User = CompletionItemKind._(25);

  static const CompletionItemKind Issue = CompletionItemKind._(26);

  static const CompletionItemKind Snippet = CompletionItemKind._(27);
}
extension type const CompletionItemTag._(int _) {
  static const CompletionItemTag Deprecated = CompletionItemTag._(1);
}
extension type const CompletionItemInsertTextRule._(int _) {
  static const CompletionItemInsertTextRule None =
      CompletionItemInsertTextRule._(0);

  /// Adjust whitespace/indentation of multiline insert texts to
  /// match the current line indentation.
  static const CompletionItemInsertTextRule KeepWhitespace =
      CompletionItemInsertTextRule._(1);

  /// `insertText` is a snippet.
  static const CompletionItemInsertTextRule InsertAsSnippet =
      CompletionItemInsertTextRule._(4);
}
extension type CompletionItemRanges._(JSObject _) implements JSObject {
  external IRange insert;

  external IRange replace;
}

/// A completion item represents a text snippet that is
/// proposed to complete text that is being typed.
extension type CompletionItem._(JSObject _) implements JSObject {
  external factory CompletionItem({
    required String label,
    required CompletionItemKind kind,
    ReadonlyArray<JSNumber?>? tags,
    String? detail,
    String? documentation,
    String? sortText,
    String? filterText,
    bool? preselect,
    required String insertText,
    CompletionItemInsertTextRule? insertTextRules,
    JSArray<ISingleEditOperation?>? additionalTextEdits,
    Command? command,
    IRange? range,
  });

  /// The label of this completion item. By default
  /// this is also the text that is inserted when selecting
  /// this completion.
  external AnonymousUnion_2303113 label;

  /// The kind of this completion item. Based on the kind
  /// an icon is chosen by the editor.
  external CompletionItemKind kind;

  /// A modifier to the `kind` which affect how the item
  /// is rendered, e.g. Deprecated is rendered with a strikeout
  external ReadonlyArray<JSNumber?>? tags;

  /// A human-readable string with additional information
  /// about this item, like type or symbol information.
  external String? detail;

  /// A human-readable string that represents a doc-comment.
  external AnonymousUnion_1021609? documentation;

  /// A string that should be used when comparing this item
  /// with other items. When `falsy` the CompletionItem.labellabel
  /// is used.
  external String? sortText;

  /// A string that should be used when filtering a set of
  /// completion items. When `falsy` the CompletionItem.labellabel
  /// is used.
  external String? filterText;

  /// Select this item when showing. *Note* that only one completion item can be
  /// selected and
  /// that the editor decides which item that is. The rule is that the *first*
  /// item of those
  /// that match best is selected.
  external bool? preselect;

  /// A string or snippet that should be inserted in a document when selecting
  /// this completion.
  external String insertText;

  /// Additional rules (as bitmask) that should be applied when inserting
  /// this completion.
  external CompletionItemInsertTextRule? insertTextRules;

  /// A range of text that should be replaced by this completion item.
  ///
  /// Defaults to a range from the start of the
  /// TextDocument.getWordRangeAtPosition current word to the
  /// current position.
  ///
  /// *Note:* The range must be a Range.isSingleLine single line and it must
  /// Range.contains contain the position at which completion has been
  /// CompletionItemProvider.provideCompletionItemsrequested.
  external AnonymousUnion_3663630 range;

  /// An optional set of characters that when pressed while this completion is
  /// active will accept it first and
  /// then type that character. *Note* that all commit characters should have
  /// `length=1` and that superfluous
  /// characters will be ignored.
  external JSArray<JSString?>? commitCharacters;

  /// An optional array of additional text edits that are applied when
  /// selecting this completion. Edits must not overlap with the main edit
  /// nor with themselves.
  external JSArray<ISingleEditOperation?>? additionalTextEdits;

  /// A command that should be run upon acceptance of this item.
  external Command? command;
}
extension type CompletionList._(JSObject _) implements JSObject {
  external factory CompletionList._create({
    required JSArray<CompletionItem> suggestions,
    bool? incomplete,
    JSFunction? dispose,
  });

  factory CompletionList({
    required List<CompletionItem> suggestions,
    bool? incomplete,
    JSFunction? dispose,
  }) => CompletionList._create(
    suggestions: suggestions.toJS,
    incomplete: incomplete,
    dispose: dispose,
  );

  external JSArray<CompletionItem> suggestions;

  external bool? incomplete;

  external JSFunction? get dispose;
}

@JSExport()
class DartCompletionItemProvider {
  DartCompletionItemProvider({
    required List<String> triggerCharacters,
    required CompletionList Function(
      ITextModel model,
      Position position,
      CompletionContext context,
      CancellationToken token,
    )
    provideCompletionItems,
  }) : triggerCharacters = triggerCharacters.map((e) => e.toJS).toList().toJS,
       _provideCompletionItems = provideCompletionItems;

  final JSArray<JSString> triggerCharacters;
  final CompletionList Function(
    ITextModel model,
    Position position,
    CompletionContext context,
    CancellationToken token,
  )
  _provideCompletionItems;

  CompletionList provideCompletionItems(
    ITextModel model,
    Position position,
    CompletionContext context,
    CancellationToken token,
  ) {
    return _provideCompletionItems(model, position, context, token);
  }
}

@JSExport()
class DartHoverProvider {
  DartHoverProvider({
    required Hover? Function(
      ITextModel model,
      Position position,
      CancellationToken token,
    )
    provideHover,
  }) : _provideHover = provideHover;

  final Hover? Function(
    ITextModel model,
    Position position,
    CancellationToken token,
  )
  _provideHover;

  Hover? provideHover(
    ITextModel model,
    Position position,
    CancellationToken token,
  ) {
    return _provideHover(model, position, token);
  }
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
extension type CompletionItemProvider._(JSObject _) implements JSObject {
  external factory CompletionItemProvider({
    JSArray<JSString?>? triggerCharacters,
    JSFunction provideCompletionItems,
    JSFunction? resolveCompletionItem,
  });

  external JSArray<JSString?>? triggerCharacters;

  /// Provide completion items for the given position and document.
  external ProviderResult<CompletionList> provideCompletionItems(
    ITextModel model,
    Position position,
    CompletionContext context,
    CancellationToken token,
  );

  /// Given a completion item fill in more data, like
  /// CompletionItem.documentationdoc-comment
  /// or CompletionItem.detaildetails.
  ///
  /// The editor will only resolve a completion item once.
  external JSFunction? get resolveCompletionItem;
}

/// A color in RGBA format.
extension type IColor._(JSObject _) implements JSObject {
  /// The red component in the range [0-1].
  external double get red;

  /// The green component in the range [0-1].
  external double get green;

  /// The primary component in the range [0-1].
  external double get primary;

  /// The alpha component in the range [0-1].
  external double get alpha;
}

/// A color range is a range in a text model which represents a color.
extension type IColorInformation._(JSObject _) implements JSObject {
  /// The range within the model.
  external IRange range;

  /// The color represented in this range.
  external IColor color;
}

/// String representations for a color
extension type IColorPresentation._(JSObject _) implements JSObject {
  /// The label of this color presentation. It will be shown on the color
  /// picker header. By default this is also the text that is inserted when
  /// selecting
  /// this color presentation.
  external String label;

  /// An TextEditedit which is applied to a document when selecting
  /// this presentation for the color.
  external TextEdit? textEdit;

  /// An optional array of additional TextEdittext edits that are applied when
  /// selecting this color presentation.
  external JSArray<TextEdit?>? additionalTextEdits;
}

/// A provider of colors for editor models.
extension type DocumentColorProvider._(JSObject _) implements JSObject {
  /// Provides the color ranges for a specific model.
  external ProviderResult<JSArray<IColorInformation>> provideDocumentColors(
    ITextModel model,
    CancellationToken token,
  );

  /// Provide the string representations for a color.
  external ProviderResult<JSArray<IColorPresentation>>
  provideColorPresentations(
    ITextModel model,
    IColorInformation colorInfo,
    CancellationToken token,
  );
}
extension type FoldingContext._(JSObject _) implements JSObject {}
extension type FoldingRangeKind._(JSObject _) implements JSObject {
  external FoldingRangeKind(String value);

  external String value;

  /// Kind for folding range representing a comment. The value of the kind is
  /// 'comment'.
  external static FoldingRangeKind get Comment;

  /// Kind for folding range representing a import. The value of the kind is
  /// 'imports'.
  external static FoldingRangeKind get Imports;

  /// Kind for folding range representing regions (for example marked by
  /// `#region`, `#endregion`).
  /// The value of the kind is 'region'.
  external static FoldingRangeKind get Region;

  /// Returns a FoldingRangeKind for the given value.
  /// - [value]:  of the kind.
  external static FoldingRangeKind fromValue(String value);
}
extension type FoldingRange._(JSObject _) implements JSObject {
  /// The one-based start line of the range to fold. The folded area starts
  /// after the line's last character.
  external double start;

  /// The one-based end line of the range to fold. The folded area ends with the
  /// line's last character.
  external double end;

  /// Describes the FoldingRangeKindKind of the folding range such as
  /// FoldingRangeKind.CommentComment or
  /// FoldingRangeKind.RegionRegion. The kind is used to categorize folding
  /// ranges and used by commands
  /// like 'Fold all comments'. See
  /// FoldingRangeKind for an enumeration of standardized kinds.
  external FoldingRangeKind? kind;
}

/// A provider of folding ranges for editor models.
extension type FoldingRangeProvider._(JSObject _) implements JSObject {
  /// An optional event to signal that the folding ranges from this provider
  /// have changed.
  external IEvent<JSAny?>? onDidChange;

  /// Provides the folding ranges for a specific model.
  external ProviderResult<JSArray<FoldingRange>> provideFoldingRanges(
    ITextModel model,
    FoldingContext context,
    CancellationToken token,
  );
}

/// The definition provider interface defines the contract between extensions
/// and
/// the
/// [go to definition](https://code.visualstudio.com/docs/editor/editingevolved#_go-to-definition)
/// and peek definition features.
extension type DeclarationProvider._(JSObject _) implements JSObject {}
extension type SelectionRange._(JSObject _) implements JSObject {
  external IRange range;
}
extension type SelectionRangeProvider._(JSObject _) implements JSObject {
  /// Provide ranges that should be selected from the given position.
  external ProviderResult<JSArray<JSArray<SelectionRange>>>
  provideSelectionRanges(
    ITextModel model,
    JSArray<Position> positions,
    CancellationToken token,
  );
}
extension type SemanticTokensLegend._(JSObject _) implements JSObject {
  external JSArray<JSString> get tokenTypes;
  external JSArray<JSString> get tokenModifiers;
}
extension type SemanticTokens._(JSObject _) implements JSObject {
  external String? get resultId;
  external JSUint32Array get data;
}
extension type SemanticTokensEdit._(JSObject _) implements JSObject {
  external double get start;
  external double get deleteCount;
  external JSUint32Array? get data;
}
extension type SemanticTokensEdits._(JSObject _) implements JSObject {
  external String? get resultId;
  external JSArray<SemanticTokensEdit> get edits;
}
extension type DocumentSemanticTokensProvider._(JSObject _)
    implements JSObject {
  external IEvent<JSAny?>? onDidChange;

  external SemanticTokensLegend getLegend();

  external JSAny? releaseDocumentSemanticTokens(String? resultId);
}
extension type DocumentRangeSemanticTokensProvider._(JSObject _)
    implements JSObject {
  external SemanticTokensLegend getLegend();
  external ProviderResult<SemanticTokens> provideDocumentRangeSemanticTokens(
    ITextModel model,
    Range range,
    CancellationToken token,
  );
}
extension type InlineCompletion._(JSObject _) implements JSObject {
  /// The text to insert.
  /// If the text contains a line break, the range must end at the end of a
  /// line.
  /// If existing text should be replaced, the existing text must be a prefix of
  /// the text to insert.
  ///
  /// The text can also be a snippet. In that case, a preview with default
  /// parameters is shown.
  /// When accepting the suggestion, the full snippet is inserted.
  external AnonymousUnion_6358053 get insertText;

  /// A text that is used to decide if this inline completion should be shown.
  /// An inline completion is shown if the text to replace is a subword of the
  /// filter text.
  external String? get filterText;

  /// An optional array of additional text edits that are applied when
  /// selecting this completion. Edits must not overlap with the main edit
  /// nor with themselves.
  external JSArray<ISingleEditOperation?>? get additionalTextEdits;

  /// The range to replace.
  /// Must begin and end on the same line.
  external IRange? get range;
  external Command? get command;

  /// If set to `true`, unopened closing brackets are removed and unclosed
  /// opening brackets are closed.
  /// Defaults to `false`.
  external bool? get completeBracketPairs;
}
extension type InlineCompletions<TItem extends InlineCompletion>._(JSObject _)
    implements JSObject {
  external JSArray<TItem> get items;

  /// A list of commands associated with the inline completions of this list.
  external JSArray<Command?>? get commands;
  external bool? get suppressSuggestions;

  /// When set and the user types a suggestion without derivating from it, the
  /// inline suggestion is not updated.
  external bool? get enableForwardStability;
}

/// How an InlineCompletionsProviderinline completion provider was triggered.
extension type const InlineCompletionTriggerKind._(int _) {
  /// Completion was triggered automatically while editing.
  /// It is sufficient to return a single completion item in this case.
  static const InlineCompletionTriggerKind Automatic =
      InlineCompletionTriggerKind._(0);

  /// Completion was triggered explicitly by a user gesture.
  /// Return multiple completion items to enable cycling through them.
  static const InlineCompletionTriggerKind Explicit =
      InlineCompletionTriggerKind._(1);
}
extension type SelectedSuggestionInfo._(JSObject _) implements JSObject {
  external SelectedSuggestionInfo(
    IRange range,
    String text,
    CompletionItemKind completionKind,
    bool isSnippetText,
  );

  external IRange get range;
  external String get text;
  external CompletionItemKind get completionKind;
  external bool get isSnippetText;
  external bool equals(SelectedSuggestionInfo other);
}
extension type InlineCompletionContext._(JSObject _) implements JSObject {
  /// How the completion was triggered.
  external InlineCompletionTriggerKind get triggerKind;
  external SelectedSuggestionInfo? get selectedSuggestionInfo;
}

/// How a partial acceptance was triggered.
extension type const PartialAcceptTriggerKind._(int _) {
  static const PartialAcceptTriggerKind Word = PartialAcceptTriggerKind._(0);

  static const PartialAcceptTriggerKind Line = PartialAcceptTriggerKind._(1);

  static const PartialAcceptTriggerKind Suggest = PartialAcceptTriggerKind._(2);
}

/// Info provided on partial acceptance.
extension type PartialAcceptInfo._(JSObject _) implements JSObject {
  external PartialAcceptTriggerKind kind;
}
typedef InlineCompletionProviderGroupId = String;
extension type InlineCompletionsProvider<T extends InlineCompletions>._(
  JSObject _
)
    implements JSObject {
  /// Only used for yieldsToGroupIds.
  /// Multiple providers can have the same group id.
  external InlineCompletionProviderGroupId? groupId;

  /// Returns a list of preferred provider groupIds.
  /// The current provider is only requested for completions if no provider with
  /// a preferred group id returned a result.
  external JSArray<JSString?>? yieldsToGroupIds;

  external ProviderResult<T> provideInlineCompletions(
    ITextModel model,
    Position position,
    InlineCompletionContext context,
    CancellationToken token,
  );

  /// Will be called when an item is shown.
  /// - [updatedInsertText]:  Is useful to understand bracket completion.
  external JSFunction? get handleItemDidShow;

  /// Will be called when an item is partially accepted.
  external JSFunction? get handlePartialAccept;

  /// Will be called when a completions list is no longer in use and can be
  /// garbage-collected.
  external JSAny? freeInlineCompletions(T completions);
  @JS('toString')
  external JSFunction? get toString$;
}
extension type IInlineEdit._(JSObject _) implements JSObject {
  external String text;

  external IRange range;

  external Command? accepted;

  external Command? rejected;
}
extension type const InlineEditTriggerKind._(int _) {
  static const InlineEditTriggerKind Invoke = InlineEditTriggerKind._(0);

  static const InlineEditTriggerKind Automatic = InlineEditTriggerKind._(1);
}
extension type IInlineEditContext._(JSObject _) implements JSObject {
  external InlineEditTriggerKind triggerKind;
}
extension type InlineEditProvider<T extends IInlineEdit>._(JSObject _)
    implements JSObject {
  external ProviderResult<T> provideInlineEdit(
    ITextModel model,
    IInlineEditContext context,
    CancellationToken token,
  );
  external JSAny? freeInlineEdit(T edit);
}
extension type InlayHintLabelPart._(JSObject _) implements JSObject {
  external String label;

  external AnonymousUnion_1021609? tooltip;

  external Command? command;

  external Location? location;
}
extension type const InlayHintKind._(int _) {
  static const InlayHintKind Type = InlayHintKind._(1);

  static const InlayHintKind Parameter = InlayHintKind._(2);
}
extension type InlayHint._(JSObject _) implements JSObject {
  external AnonymousUnion_8724622 label;

  external AnonymousUnion_1021609? tooltip;

  external JSArray<TextEdit?>? textEdits;

  external IPosition position;

  external InlayHintKind? kind;

  external bool? paddingLeft;

  external bool? paddingRight;
}
extension type InlayHintList._(JSObject _) implements JSObject {
  external JSArray<InlayHint> hints;

  external JSAny? dispose();
}
extension type InlayHintsProvider._(JSObject _) implements JSObject {
  external String? displayName;

  external IEvent<JSAny?>? onDidChangeInlayHints;

  external ProviderResult<InlayHintList> provideInlayHints(
    ITextModel model,
    Range range,
    CancellationToken token,
  );
  external JSFunction? get resolveInlayHint;
}
extension type DocumentContextItem._(JSObject _) implements JSObject {
  external Uri get uri;
  external double get version;
  external JSArray<IRange> get ranges;
}
extension type MappedEditsContext._(JSObject _) implements JSObject {
  /// The outer array is sorted by priority - from highest to lowest. The inner
  /// arrays contain elements of the same priority.
  external JSArray<JSArray<DocumentContextItem>> documents;
}
typedef MarkupKind = AnonymousUnion_1214657;
extension type MarkupContent._(JSObject _) implements JSObject {
  external MarkupKind kind;

  external String value;
}
typedef EntryStatus = AnonymousUnion_3249694;
extension type IReference._(JSObject _) implements JSObject {
  external String name;

  external String url;
}
extension type IValueData._(JSObject _) implements JSObject {
  external String name;

  external AnonymousUnion_9963490? description;

  external JSArray<JSString?>? browsers;

  external EntryStatus? status;

  external JSArray<IReference?>? references;
}
extension type IPropertyData._(JSObject _) implements JSObject {
  external String name;

  external AnonymousUnion_9963490? description;

  external JSArray<JSString?>? browsers;

  external JSArray<JSString?>? restrictions;

  external EntryStatus? status;

  external String? syntax;

  external JSArray<IValueData?>? values;

  external JSArray<IReference?>? references;

  external double? relevance;
}
extension type IAtDirectiveData._(JSObject _) implements JSObject {
  external String name;

  external AnonymousUnion_9963490? description;

  external JSArray<JSString?>? browsers;

  external EntryStatus? status;

  external JSArray<IReference?>? references;
}
extension type IPseudoClassData._(JSObject _) implements JSObject {
  external String name;

  external AnonymousUnion_9963490? description;

  external JSArray<JSString?>? browsers;

  external EntryStatus? status;

  external JSArray<IReference?>? references;
}
extension type IPseudoElementData._(JSObject _) implements JSObject {
  external String name;

  external AnonymousUnion_9963490? description;

  external JSArray<JSString?>? browsers;

  external EntryStatus? status;

  external JSArray<IReference?>? references;
}

/// Custom CSS properties, at-directives, pseudoClasses and pseudoElements
/// https://github.com/microsoft/vscode-css-languageservice/blob/main/docs/customData.md
extension type CSSDataV1._(JSObject _) implements JSObject {
  external JSArray<IPropertyData?>? properties;

  external JSArray<IAtDirectiveData?>? atDirectives;

  external JSArray<IPseudoClassData?>? pseudoClasses;

  external JSArray<IPseudoElementData?>? pseudoElements;
}
extension type CSSDataConfiguration._(JSObject _) implements JSObject {
  /// Defines whether the standard CSS properties, at-directives, pseudoClasses
  /// and pseudoElements are shown.
  external bool? useDefaultDataProvider;

  /// Provides a set of custom data providers.
  external AnonymousType_2581160? dataProviders;
}
extension type CSSFormatConfiguration._(JSObject _) implements JSObject {
  /// separate selectors with newline (e.g. "a,\nbr" or "a, br"): Default: true
  external bool? newlineBetweenSelectors;

  /// add a new line after every css rule: Default: true
  external bool? newlineBetweenRules;

  /// ensure space around selector separators:  '>', '+', '~' (e.g. "a>b" -> "a
  /// > b"): Default: false
  external bool? spaceAroundSelectorSeparator;

  /// put braces on the same line as rules (`collapse`), or put braces on own
  /// line, Allman / ANSI style (`expand`). Default `collapse`
  external AnonymousUnion_1283868? braceStyle;

  /// whether existing line breaks before elements should be preserved. Default:
  /// true
  external bool? preserveNewLines;

  /// maximum number of line breaks to be preserved in one chunk. Default:
  /// unlimited
  external double? maxPreserveNewLines;
}
extension type ModeConfiguration._(JSObject _) implements JSObject {
  /// Defines whether the built-in completionItemProvider is enabled.
  external bool? get completionItems;

  /// Defines whether the built-in hoverProvider is enabled.
  external bool? get hovers;

  /// Defines whether the built-in documentSymbolProvider is enabled.
  external bool? get documentSymbols;

  /// Defines whether the built-in definitions provider is enabled.
  external bool? get definitions;

  /// Defines whether the built-in references provider is enabled.
  external bool? get references;

  /// Defines whether the built-in references provider is enabled.
  external bool? get documentHighlights;

  /// Defines whether the built-in rename provider is enabled.
  external bool? get rename;

  /// Defines whether the built-in color provider is enabled.
  external bool? get colors;

  /// Defines whether the built-in foldingRange provider is enabled.
  external bool? get foldingRanges;

  /// Defines whether the built-in diagnostic provider is enabled.
  external bool? get diagnostics;

  /// Defines whether the built-in selection range provider is enabled.
  external bool? get selectionRanges;

  /// Defines whether the built-in document formatting edit provider is enabled.
  external bool? get documentFormattingEdits;

  /// Defines whether the built-in document formatting range edit provider is
  /// enabled.
  external bool? get documentRangeFormattingEdits;
}
extension type Options._(JSObject _) implements JSObject {
  external bool? get validate;
  external AnonymousType_1410451? get lint;

  /// Configures the CSS data types known by the langauge service.
  external CSSDataConfiguration? get data;

  /// Settings for the CSS formatter.
  external CSSFormatConfiguration? get format;
}
@Deprecated('Use Options instead')
typedef DiagnosticsOptions = Options;
extension type LanguageServiceDefaults._(JSObject _) implements JSObject {
  external String get languageId;
  external JSAny? get onDidChange;
  external ModeConfiguration get modeConfiguration;
  external Options get options;
  @Deprecated('Use options instead')
  external DiagnosticsOptions get diagnosticsOptions;
  external JSAny? setOptions(Options options);
  external JSAny? setModeConfiguration(ModeConfiguration modeConfiguration);
  @Deprecated('Use setOptions instead')
  external JSAny? setDiagnosticsOptions(DiagnosticsOptions options);
}
extension type LanguageServiceRegistration._(JSObject _)
    implements IDisposable {
  external LanguageServiceDefaults get defaults;
}
extension type HTMLFormatConfiguration._(JSObject _) implements JSObject {
  external double get tabSize;
  external bool get insertSpaces;
  external double get wrapLineLength;
  external String get unformatted;
  external String get contentUnformatted;
  external bool get indentInnerHtml;
  external bool get preserveNewLines;
  external double? get maxPreserveNewLines;
  external bool get indentHandlebars;
  external bool get endWithNewline;
  external String get extraLiners;
  external AnonymousUnion_1640272 get wrapAttributes;
}
extension type CompletionConfiguration._(JSObject _) implements JSObject {
  external bool operator [](String providerId);
  external void operator []=(String providerId, bool newValue);
}
extension type IAttributeData._(JSObject _) implements JSObject {
  external String get name;
  external AnonymousUnion_9963490? get description;
  external String? get valueSet;
  external JSArray<IValueData?>? get values;
  external JSArray<IReference?>? get references;
}
extension type ITagData._(JSObject _) implements JSObject {
  external String get name;
  external AnonymousUnion_9963490? get description;
  external JSArray<IAttributeData> get attributes;
  external JSArray<IReference?>? get references;
}
extension type IValueSet._(JSObject _) implements JSObject {
  external String get name;
  external JSArray<IValueData> get values;
}

/// Custom HTML tags attributes and attribute values
/// https://github.com/microsoft/vscode-html-languageservice/blob/main/docs/customData.md
extension type HTMLDataV1._(JSObject _) implements JSObject {
  external JSArray<ITagData?>? get tags;
  external JSArray<IAttributeData?>? get globalAttributes;
  external JSArray<IValueSet?>? get valueSets;
}
extension type HTMLDataConfiguration._(JSObject _) implements JSObject {
  /// Defines whether the standard HTML tags and attributes are shown
  external bool? get useDefaultDataProvider;

  /// Provides a set of custom data providers.
  external AnonymousType_2063447? get dataProviders;
}
extension type BaseASTNode._(JSObject _) implements JSObject {
  external AnonymousUnion_5346609 get type;
  external JSAny? get parent;
  external double get offset;
  external double get length;
  external JSArray<JSAny?>? get children;
  external AnonymousUnion_1096157? get value;
}
extension type StringASTNode._(JSObject _) implements BaseASTNode {
  @_i2.redeclare
  external String get type;
  @_i2.redeclare
  external String get value;
}
extension type PropertyASTNode._(JSObject _) implements BaseASTNode {
  @_i2.redeclare
  external String get type;
  external StringASTNode get keyNode;
  external JSAny? get valueNode;
  external double? get colonOffset;
  @_i2.redeclare
  external JSArray<JSAny?> get children;
}
extension type ObjectASTNode._(JSObject _) implements BaseASTNode {
  @_i2.redeclare
  external String get type;
  external JSArray<PropertyASTNode> get properties;
  @_i2.redeclare
  external JSArray<JSAny?> get children;
}
extension type ArrayASTNode._(JSObject _) implements BaseASTNode {
  @_i2.redeclare
  external String get type;
  external JSArray<JSAny?> get items;
  @_i2.redeclare
  external JSArray<JSAny?> get children;
}
extension type NumberASTNode._(JSObject _) implements BaseASTNode {
  @_i2.redeclare
  external String get type;
  @_i2.redeclare
  external double get value;
  external bool get isInteger;
}
extension type BooleanASTNode._(JSObject _) implements BaseASTNode {
  @_i2.redeclare
  external String get type;
  @_i2.redeclare
  external bool get value;
}
extension type NullASTNode._(JSObject _) implements BaseASTNode {
  @_i2.redeclare
  external String get type;
  @_i2.redeclare
  external JSAny get value;
}
typedef ASTNode = AnonymousUnion_1333870;
typedef JSONSchemaRef = AnonymousUnion_1894070;
extension type JSONSchemaMap._(JSObject _) implements JSObject {
  external JSONSchemaRef operator [](String name);
}
extension type JSONSchema._(JSObject _) implements JSObject {
  external String? id;

  external String? $id;

  external String? $schema;

  external AnonymousUnion_8724622? type;

  external String? title;

  @JS('default')
  external JSAny? default$;

  external AnonymousType_2245370? definitions;

  external String? description;

  external JSONSchemaMap? properties;

  external JSONSchemaMap? patternProperties;

  external AnonymousUnion_7094455? additionalProperties;

  external double? minProperties;

  external double? maxProperties;

  external AnonymousUnion_2735524? items;

  external double? minItems;

  external double? maxItems;

  external bool? uniqueItems;

  external AnonymousUnion_7094455? additionalItems;

  external String? pattern;

  external double? minLength;

  external double? maxLength;

  external double? minimum;

  external double? maximum;

  external AnonymousUnion_4790927? exclusiveMinimum;

  external AnonymousUnion_4790927? exclusiveMaximum;

  external double? multipleOf;

  @JS('required')
  external JSArray<JSString?>? required$;

  external String? $ref;

  external JSArray<AnonymousUnion_1894070?>? anyOf;

  external JSArray<AnonymousUnion_1894070?>? allOf;

  external JSArray<AnonymousUnion_1894070?>? oneOf;

  external JSONSchemaRef? not;

  @JS('enum')
  external JSArray<JSAny?>? enum$;

  external String? format;

  @JS('const')
  external JSAny? const$;

  external JSONSchemaRef? contains;

  external JSONSchemaRef? propertyNames;

  external JSArray<JSAny?>? examples;

  external String? $comment;

  @JS('if')
  external JSONSchemaRef? if$;

  external JSONSchemaRef? then;

  @JS('else')
  external JSONSchemaRef? else$;

  external String? errorMessage;

  external String? patternErrorMessage;

  external String? deprecationMessage;

  external JSArray<JSString?>? enumDescriptions;

  external JSArray<JSString?>? markdownEnumDescriptions;

  external String? markdownDescription;

  external bool? doNotSuggest;

  external String? suggestSortText;

  external bool? allowComments;

  external bool? allowTrailingCommas;
}
typedef SeverityLevel = AnonymousUnion_6291848;
typedef JSONDocument = AnonymousType_1393492;
extension type MatchingSchema._(JSObject _) implements JSObject {
  external ASTNode node;

  external JSONSchema schema;
}
extension type const JsxEmit._(int _) {
  static const JsxEmit None = JsxEmit._(0);

  static const JsxEmit Preserve = JsxEmit._(1);

  static const JsxEmit React = JsxEmit._(2);

  static const JsxEmit ReactNative = JsxEmit._(3);

  static const JsxEmit ReactJSX = JsxEmit._(4);

  static const JsxEmit ReactJSXDev = JsxEmit._(5);
}
extension type const ModuleKind._(int _) {
  static const ModuleKind None = ModuleKind._(0);

  static const ModuleKind CommonJS = ModuleKind._(1);

  static const ModuleKind AMD = ModuleKind._(2);

  static const ModuleKind UMD = ModuleKind._(3);

  static const ModuleKind System = ModuleKind._(4);

  static const ModuleKind ES2015 = ModuleKind._(5);

  static const ModuleKind ESNext = ModuleKind._(99);
}
extension type const ModuleResolutionKind._(int _) {
  static const ModuleResolutionKind Classic = ModuleResolutionKind._(1);

  static const ModuleResolutionKind NodeJs = ModuleResolutionKind._(2);
}
extension type const NewLineKind._(int _) {
  static const NewLineKind CarriageReturnLineFeed = NewLineKind._(0);

  static const NewLineKind LineFeed = NewLineKind._(1);
}
extension type const ScriptTarget._(int _) {
  static const ScriptTarget ES3 = ScriptTarget._(0);

  static const ScriptTarget ES5 = ScriptTarget._(1);

  static const ScriptTarget ES2015 = ScriptTarget._(2);

  static const ScriptTarget ES2016 = ScriptTarget._(3);

  static const ScriptTarget ES2017 = ScriptTarget._(4);

  static const ScriptTarget ES2018 = ScriptTarget._(5);

  static const ScriptTarget ES2019 = ScriptTarget._(6);

  static const ScriptTarget ES2020 = ScriptTarget._(7);

  static const ScriptTarget ESNext = ScriptTarget._(99);

  static const ScriptTarget JSON = ScriptTarget._(100);

  static const ScriptTarget Latest = ScriptTarget._(99);
}
extension type DiagnosticRelatedInformation._(JSObject _) implements JSObject {
  /// Diagnostic category: warning = 0, error = 1, suggestion = 2, message = 3
  external AnonymousUnion_7456409 category;

  external double code;

  /// TypeScriptWorker removes all but the `fileName` property to avoid
  /// serializing circular JSON structures.
  external AnonymousType_8401536 file;

  external double? start;

  external double? length;

  external AnonymousUnion_1514162 messageText;
}
extension type Diagnostic._(JSObject _)
    implements DiagnosticRelatedInformation {
  /// May store more in future. For now, this will simply be `true` to indicate
  /// when a diagnostic is an unused-identifier diagnostic.
  external AnonymousType_1495304? reportsUnnecessary;

  external AnonymousType_1495304? reportsDeprecated;

  external String? source;

  external JSArray<DiagnosticRelatedInformation?>? relatedInformation;
}
extension type WorkerOptions._(JSObject _) implements JSObject {
  /// A full HTTP path to a JavaScript file which adds a function
  /// `customTSWorkerFactory` to the self inside a web-worker
  external String? customWorkerPath;
}
extension type IExtraLibs._(JSObject _) implements JSObject {
  external IExtraLib operator [](String path);
}
extension type EmitOutput._(JSObject _) implements JSObject {
  external bool emitSkipped;

  external JSArray<Diagnostic?>? diagnostics;
}
extension type IMirrorTextModel._(JSObject _) implements JSObject {
  external double get version;
}
extension type IMirrorModel._(JSObject _) implements IMirrorTextModel {
  external Uri get uri;
  @_i2.redeclare
  external double get version;
  external String getValue();
}
extension type _AnonymousFunction_9009365._(JSFunction _)
    implements JSFunction {
  external String call(
    String input,
    JSArray<JSAny?> arguments, [
    JSArray<JSAny?> arguments2,
    JSArray<JSAny?> arguments3,
    JSArray<JSAny?> arguments4,
    JSArray<JSAny?> arguments5,
    JSArray<JSAny?> arguments6,
    JSArray<JSAny?> arguments7,
    JSArray<JSAny?> arguments8,
  ]);
}
extension type AnonymousUnion_5090768._(JSAny _) implements JSAny {
  JSPromise<_i3.Worker> get asJSPromise => (_ as JSPromise<_i3.Worker>);

  _i3.Worker get asWorker => (_ as _i3.Worker);
}
extension type _AnonymousFunction_1135486._(JSFunction _)
    implements JSFunction {
  external IDisposable call(
    _AnonymousFunction_1027148 listener, [
    JSAny? thisArgs,
    JSArray<IDisposable?>? disposables,
  ]);
}
extension type _AnonymousFunction_1027148._(JSFunction _)
    implements JSFunction {
  external JSAny? call(JSAny? e);
}
extension type AnonymousType_1126581._(JSObject _) implements JSObject {
  external AnonymousType_1126581({
    String scheme,
    String? authority,
    String? path,
    String? query,
    String? fragment,
  });

  external String? scheme;

  external String? authority;

  external String? path;

  external String? query;

  external String? fragment;
}
extension type AnonymousUnion_4256847._(JSAny _) implements JSAny {
  UriComponents get asUriComponents => (_ as UriComponents);

  JSAny? get asJSAny => (_ as JSAny?);
}
extension type AnonymousType_8718114._(JSObject _) implements JSObject {
  external AnonymousType_8718114();

  external UriComponents operator [](String href);
}
extension type AnonymousUnion_1099144._(JSAny _) implements JSAny {
  bool get asBool => (_ as JSBoolean).toDart;

  MarkdownStringTrustedOptions get asMarkdownStringTrustedOptions =>
      (_ as MarkdownStringTrustedOptions);
}
extension type const AnonymousUnion_1753152._(String _) {
  static const AnonymousUnion_1753152 auto = AnonymousUnion_1753152._('auto');

  static const AnonymousUnion_1753152 visible = AnonymousUnion_1753152._(
    'visible',
  );

  static const AnonymousUnion_1753152 hidden = AnonymousUnion_1753152._(
    'hidden',
  );
}
extension type const AnonymousUnion_1641319._(String _) {
  static const AnonymousUnion_1641319 outlineModel = AnonymousUnion_1641319._(
    'outlineModel',
  );

  static const AnonymousUnion_1641319 foldingProviderModel =
      AnonymousUnion_1641319._('foldingProviderModel');

  static const AnonymousUnion_1641319 indentationModel =
      AnonymousUnion_1641319._('indentationModel');
}
extension type const AnonymousUnion_1265516._(String _) {
  static const AnonymousUnion_1265516 right = AnonymousUnion_1265516._('right');

  static const AnonymousUnion_1265516 left = AnonymousUnion_1265516._('left');
}
extension type const AnonymousUnion_5814346._(String _) {
  static const AnonymousUnion_5814346 proportional = AnonymousUnion_5814346._(
    'proportional',
  );

  static const AnonymousUnion_5814346 fill = AnonymousUnion_5814346._('fill');

  static const AnonymousUnion_5814346 fit = AnonymousUnion_5814346._('fit');
}
extension type const AnonymousUnion_7444867._(String _) {
  static const AnonymousUnion_7444867 always = AnonymousUnion_7444867._(
    'always',
  );

  static const AnonymousUnion_7444867 mouseover = AnonymousUnion_7444867._(
    'mouseover',
  );
}
extension type const AnonymousUnion_6317386._(String _) {
  static const AnonymousUnion_6317386 never = AnonymousUnion_6317386._('never');

  static const AnonymousUnion_6317386 always = AnonymousUnion_6317386._(
    'always',
  );

  static const AnonymousUnion_6317386 selection = AnonymousUnion_6317386._(
    'selection',
  );
}
extension type const AnonymousUnion_1372272._(String _) {
  static const AnonymousUnion_1372272 never = AnonymousUnion_1372272._('never');

  static const AnonymousUnion_1372272 always = AnonymousUnion_1372272._(
    'always',
  );

  static const AnonymousUnion_1372272 multiline = AnonymousUnion_1372272._(
    'multiline',
  );
}
extension type const AnonymousUnion_1259071._(String _) {
  static const AnonymousUnion_1259071 insert = AnonymousUnion_1259071._(
    'insert',
  );

  static const AnonymousUnion_1259071 replace = AnonymousUnion_1259071._(
    'replace',
  );
}
extension type const AnonymousUnion_1128509._(String _) {
  static const AnonymousUnion_1128509 always = AnonymousUnion_1128509._(
    'always',
  );

  static const AnonymousUnion_1128509 never = AnonymousUnion_1128509._('never');

  static const AnonymousUnion_1128509 whenTriggerCharacter =
      AnonymousUnion_1128509._('whenTriggerCharacter');

  static const AnonymousUnion_1128509 whenQuickSuggestion =
      AnonymousUnion_1128509._('whenQuickSuggestion');
}
extension type const AnonymousUnion_1305061._(String _) {
  static const AnonymousUnion_1305061 prefix = AnonymousUnion_1305061._(
    'prefix',
  );

  static const AnonymousUnion_1305061 subword = AnonymousUnion_1305061._(
    'subword',
  );

  static const AnonymousUnion_1305061 subwordSmart = AnonymousUnion_1305061._(
    'subwordSmart',
  );
}
extension type const AnonymousUnion_8388362._(String _) {
  static const AnonymousUnion_8388362 always = AnonymousUnion_8388362._(
    'always',
  );

  static const AnonymousUnion_8388362 onHover = AnonymousUnion_8388362._(
    'onHover',
  );

  static const AnonymousUnion_8388362 never = AnonymousUnion_8388362._('never');
}
extension type AnonymousUnion_1117146._(String _) implements String {
  String get asString => _;

  String get asString_default => _;
}
extension type const AnonymousUnion_1533781._(String _) {
  static const AnonymousUnion_1533781 peek = AnonymousUnion_1533781._('peek');

  static const AnonymousUnion_1533781 gotoAndPeek = AnonymousUnion_1533781._(
    'gotoAndPeek',
  );

  static const AnonymousUnion_1533781 goto = AnonymousUnion_1533781._('goto');
}
extension type const AnonymousUnion_6911130._(String _) {
  static const AnonymousUnion_6911130 on$ = AnonymousUnion_6911130._('on');

  static const AnonymousUnion_6911130 inline = AnonymousUnion_6911130._(
    'inline',
  );

  static const AnonymousUnion_6911130 off = AnonymousUnion_6911130._('off');
}
extension type const AnonymousUnion_1207780._(String _) {
  static const AnonymousUnion_1207780 always = AnonymousUnion_1207780._(
    'always',
  );

  static const AnonymousUnion_1207780 languageDefined =
      AnonymousUnion_1207780._('languageDefined');

  static const AnonymousUnion_1207780 beforeWhitespace =
      AnonymousUnion_1207780._('beforeWhitespace');

  static const AnonymousUnion_1207780 never = AnonymousUnion_1207780._('never');
}
extension type const AnonymousUnion_4728824._(String _) {
  static const AnonymousUnion_4728824 always = AnonymousUnion_4728824._(
    'always',
  );

  static const AnonymousUnion_4728824 auto = AnonymousUnion_4728824._('auto');

  static const AnonymousUnion_4728824 never = AnonymousUnion_4728824._('never');
}
extension type const AnonymousUnion_2482489._(String _) {
  static const AnonymousUnion_2482489 languageDefined =
      AnonymousUnion_2482489._('languageDefined');

  static const AnonymousUnion_2482489 quotes = AnonymousUnion_2482489._(
    'quotes',
  );

  static const AnonymousUnion_2482489 brackets = AnonymousUnion_2482489._(
    'brackets',
  );

  static const AnonymousUnion_2482489 never = AnonymousUnion_2482489._('never');
}
extension type const AnonymousUnion_2815775._(String _) {
  static const AnonymousUnion_2815775 on$ = AnonymousUnion_2815775._('on');

  static const AnonymousUnion_2815775 off = AnonymousUnion_2815775._('off');

  static const AnonymousUnion_2815775 offUnlessPressed =
      AnonymousUnion_2815775._('offUnlessPressed');

  static const AnonymousUnion_2815775 onUnlessPressed =
      AnonymousUnion_2815775._('onUnlessPressed');
}
extension type const AnonymousUnion_4338314._(String _) {
  static const AnonymousUnion_4338314 afterDrop = AnonymousUnion_4338314._(
    'afterDrop',
  );

  static const AnonymousUnion_4338314 never = AnonymousUnion_4338314._('never');
}
extension type const AnonymousUnion_2852331._(String _) {
  static const AnonymousUnion_2852331 afterPaste = AnonymousUnion_2852331._(
    'afterPaste',
  );

  static const AnonymousUnion_2852331 never = AnonymousUnion_2852331._('never');
}
extension type AnonymousUnion_8724622._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  JSArray<JSString> get asJSArray => (_ as JSArray<JSString>);
}
extension type const AnonymousUnion_5824844._(String _) {
  static const AnonymousUnion_5824844 default$ = AnonymousUnion_5824844._(
    'default',
  );

  static const AnonymousUnion_5824844 all = AnonymousUnion_5824844._('all');
}
extension type const AnonymousUnion_1704253._(String _) {
  static const AnonymousUnion_1704253 on$ = AnonymousUnion_1704253._('on');

  static const AnonymousUnion_1704253 off = AnonymousUnion_1704253._('off');

  static const AnonymousUnion_1704253 dimmed = AnonymousUnion_1704253._(
    'dimmed',
  );
}
extension type const AnonymousUnion_1421152._(String _) {
  static const AnonymousUnion_1421152 auto = AnonymousUnion_1421152._('auto');

  static const AnonymousUnion_1421152 off = AnonymousUnion_1421152._('off');

  static const AnonymousUnion_1421152 prompt = AnonymousUnion_1421152._(
    'prompt',
  );
}
extension type AnonymousUnion_1467782._(JSAny _) implements JSAny {
  double get asDouble => (_ as JSNumber).toDartDouble;

  String get asString => (_ as JSString).toDart;
}
extension type const AnonymousUnion_9690158._(String _) {
  static const AnonymousUnion_9690158 editable = AnonymousUnion_9690158._(
    'editable',
  );

  static const AnonymousUnion_9690158 on$ = AnonymousUnion_9690158._('on');

  static const AnonymousUnion_9690158 off = AnonymousUnion_9690158._('off');
}
extension type const AnonymousUnion_6445351._(String _) {
  static const AnonymousUnion_6445351 blink = AnonymousUnion_6445351._('blink');

  static const AnonymousUnion_6445351 smooth = AnonymousUnion_6445351._(
    'smooth',
  );

  static const AnonymousUnion_6445351 phase = AnonymousUnion_6445351._('phase');

  static const AnonymousUnion_6445351 expand = AnonymousUnion_6445351._(
    'expand',
  );

  static const AnonymousUnion_6445351 solid = AnonymousUnion_6445351._('solid');
}
extension type const AnonymousUnion_1276488._(String _) {
  static const AnonymousUnion_1276488 text = AnonymousUnion_1276488._('text');

  static const AnonymousUnion_1276488 default$ = AnonymousUnion_1276488._(
    'default',
  );

  static const AnonymousUnion_1276488 copy = AnonymousUnion_1276488._('copy');
}
extension type const AnonymousUnion_4883143._(String _) {
  static const AnonymousUnion_4883143 off = AnonymousUnion_4883143._('off');

  static const AnonymousUnion_4883143 explicit = AnonymousUnion_4883143._(
    'explicit',
  );

  static const AnonymousUnion_4883143 on$ = AnonymousUnion_4883143._('on');
}
extension type const AnonymousUnion_1155020._(String _) {
  static const AnonymousUnion_1155020 line = AnonymousUnion_1155020._('line');

  static const AnonymousUnion_1155020 block = AnonymousUnion_1155020._('block');

  static const AnonymousUnion_1155020 underline = AnonymousUnion_1155020._(
    'underline',
  );

  static const AnonymousUnion_1155020 lineThin = AnonymousUnion_1155020._(
    'line-thin',
  );

  static const AnonymousUnion_1155020 blockOutline = AnonymousUnion_1155020._(
    'block-outline',
  );

  static const AnonymousUnion_1155020 underlineThin = AnonymousUnion_1155020._(
    'underline-thin',
  );
}
extension type AnonymousUnion_5411652._(JSAny _) implements JSAny {
  bool get asBool => (_ as JSBoolean).toDart;

  String get asString => (_ as JSString).toDart;
}
extension type const AnonymousUnion_2810996._(String _) {
  static const AnonymousUnion_2810996 off = AnonymousUnion_2810996._('off');

  static const AnonymousUnion_2810996 on$ = AnonymousUnion_2810996._('on');

  static const AnonymousUnion_2810996 wordWrapColumn = AnonymousUnion_2810996._(
    'wordWrapColumn',
  );

  static const AnonymousUnion_2810996 bounded = AnonymousUnion_2810996._(
    'bounded',
  );
}
extension type const AnonymousUnion_1569193._(String _) {
  static const AnonymousUnion_1569193 off = AnonymousUnion_1569193._('off');

  static const AnonymousUnion_1569193 on$ = AnonymousUnion_1569193._('on');

  static const AnonymousUnion_1569193 inherit = AnonymousUnion_1569193._(
    'inherit',
  );
}
extension type const AnonymousUnion_1450754._(String _) {
  static const AnonymousUnion_1450754 none = AnonymousUnion_1450754._('none');

  static const AnonymousUnion_1450754 same = AnonymousUnion_1450754._('same');

  static const AnonymousUnion_1450754 indent = AnonymousUnion_1450754._(
    'indent',
  );

  static const AnonymousUnion_1450754 deepIndent = AnonymousUnion_1450754._(
    'deepIndent',
  );
}
extension type const AnonymousUnion_1536603._(String _) {
  static const AnonymousUnion_1536603 simple = AnonymousUnion_1536603._(
    'simple',
  );

  static const AnonymousUnion_1536603 advanced = AnonymousUnion_1536603._(
    'advanced',
  );
}
extension type const AnonymousUnion_1534200._(String _) {
  static const AnonymousUnion_1534200 normal = AnonymousUnion_1534200._(
    'normal',
  );

  static const AnonymousUnion_1534200 keepAll = AnonymousUnion_1534200._(
    'keepAll',
  );
}
extension type const AnonymousUnion_1211872._(String _) {
  static const AnonymousUnion_1211872 clickAndHover = AnonymousUnion_1211872._(
    'clickAndHover',
  );

  static const AnonymousUnion_1211872 click = AnonymousUnion_1211872._('click');

  static const AnonymousUnion_1211872 hover = AnonymousUnion_1211872._('hover');
}
extension type const AnonymousUnion_2038418._(String _) {
  static const AnonymousUnion_2038418 ctrlCmd = AnonymousUnion_2038418._(
    'ctrlCmd',
  );

  static const AnonymousUnion_2038418 alt = AnonymousUnion_2038418._('alt');
}
extension type const AnonymousUnion_9182975._(String _) {
  static const AnonymousUnion_9182975 spread = AnonymousUnion_9182975._(
    'spread',
  );

  static const AnonymousUnion_9182975 full = AnonymousUnion_9182975._('full');
}
extension type const AnonymousUnion_1536131._(String _) {
  static const AnonymousUnion_1536131 auto = AnonymousUnion_1536131._('auto');

  static const AnonymousUnion_1536131 off = AnonymousUnion_1536131._('off');

  static const AnonymousUnion_1536131 on$ = AnonymousUnion_1536131._('on');
}
extension type AnonymousUnion_1800907._(JSAny _) implements JSAny {
  bool get asBool => (_ as JSBoolean).toDart;

  IQuickSuggestionsOptions get asIQuickSuggestionsOptions =>
      (_ as IQuickSuggestionsOptions);
}
extension type const AnonymousUnion_1459732._(String _) {
  static const AnonymousUnion_1459732 none = AnonymousUnion_1459732._('none');

  static const AnonymousUnion_1459732 keep = AnonymousUnion_1459732._('keep');

  static const AnonymousUnion_1459732 brackets = AnonymousUnion_1459732._(
    'brackets',
  );

  static const AnonymousUnion_1459732 advanced = AnonymousUnion_1459732._(
    'advanced',
  );

  static const AnonymousUnion_1459732 full = AnonymousUnion_1459732._('full');
}
extension type const AnonymousUnion_1780222._(String _) {
  static const AnonymousUnion_1780222 on$ = AnonymousUnion_1780222._('on');

  static const AnonymousUnion_1780222 smart = AnonymousUnion_1780222._('smart');

  static const AnonymousUnion_1780222 off = AnonymousUnion_1780222._('off');
}
extension type const AnonymousUnion_1366129._(String _) {
  static const AnonymousUnion_1366129 top = AnonymousUnion_1366129._('top');

  static const AnonymousUnion_1366129 bottom = AnonymousUnion_1366129._(
    'bottom',
  );

  static const AnonymousUnion_1366129 inline = AnonymousUnion_1366129._(
    'inline',
  );

  static const AnonymousUnion_1366129 none = AnonymousUnion_1366129._('none');
}
extension type const AnonymousUnion_4282826._(String _) {
  static const AnonymousUnion_4282826 first = AnonymousUnion_4282826._('first');

  static const AnonymousUnion_4282826 recentlyUsed = AnonymousUnion_4282826._(
    'recentlyUsed',
  );

  static const AnonymousUnion_4282826 recentlyUsedByPrefix =
      AnonymousUnion_4282826._('recentlyUsedByPrefix');
}
extension type const AnonymousUnion_4464549._(String _) {
  static const AnonymousUnion_4464549 on$ = AnonymousUnion_4464549._('on');

  static const AnonymousUnion_4464549 off = AnonymousUnion_4464549._('off');

  static const AnonymousUnion_4464549 onlySnippets = AnonymousUnion_4464549._(
    'onlySnippets',
  );
}
extension type const AnonymousUnion_2487039._(String _) {
  static const AnonymousUnion_2487039 off = AnonymousUnion_2487039._('off');

  static const AnonymousUnion_2487039 singleFile = AnonymousUnion_2487039._(
    'singleFile',
  );

  static const AnonymousUnion_2487039 multiFile = AnonymousUnion_2487039._(
    'multiFile',
  );
}
extension type const AnonymousUnion_2133250._(String _) {
  static const AnonymousUnion_2133250 auto = AnonymousUnion_2133250._('auto');

  static const AnonymousUnion_2133250 indentation = AnonymousUnion_2133250._(
    'indentation',
  );
}
extension type const AnonymousUnion_1702192._(String _) {
  static const AnonymousUnion_1702192 always = AnonymousUnion_1702192._(
    'always',
  );

  static const AnonymousUnion_1702192 never = AnonymousUnion_1702192._('never');

  static const AnonymousUnion_1702192 mouseover = AnonymousUnion_1702192._(
    'mouseover',
  );
}
extension type const AnonymousUnion_6300795._(String _) {
  static const AnonymousUnion_6300795 never = AnonymousUnion_6300795._('never');

  static const AnonymousUnion_6300795 near = AnonymousUnion_6300795._('near');

  static const AnonymousUnion_6300795 always = AnonymousUnion_6300795._(
    'always',
  );
}
extension type const AnonymousUnion_6994842._(String _) {
  static const AnonymousUnion_6994842 svg = AnonymousUnion_6994842._('svg');

  static const AnonymousUnion_6994842 font = AnonymousUnion_6994842._('font');

  static const AnonymousUnion_6994842 off = AnonymousUnion_6994842._('off');
}
extension type const AnonymousUnion_6087383._(String _) {
  static const AnonymousUnion_6087383 none = AnonymousUnion_6087383._('none');

  static const AnonymousUnion_6087383 boundary = AnonymousUnion_6087383._(
    'boundary',
  );

  static const AnonymousUnion_6087383 selection = AnonymousUnion_6087383._(
    'selection',
  );

  static const AnonymousUnion_6087383 trailing = AnonymousUnion_6087383._(
    'trailing',
  );

  static const AnonymousUnion_6087383 all = AnonymousUnion_6087383._('all');
}
extension type const AnonymousUnion_1469778._(String _) {
  static const AnonymousUnion_1469778 none = AnonymousUnion_1469778._('none');

  static const AnonymousUnion_1469778 gutter = AnonymousUnion_1469778._(
    'gutter',
  );

  static const AnonymousUnion_1469778 line = AnonymousUnion_1469778._('line');

  static const AnonymousUnion_1469778 all = AnonymousUnion_1469778._('all');
}
extension type const AnonymousUnion_1100602._(String _) {
  static const AnonymousUnion_1100602 tree = AnonymousUnion_1100602._('tree');

  static const AnonymousUnion_1100602 editor = AnonymousUnion_1100602._(
    'editor',
  );
}
extension type const AnonymousUnion_4962316._(String _) {
  static const AnonymousUnion_4962316 off = AnonymousUnion_4962316._('off');

  static const AnonymousUnion_4962316 currentDocument =
      AnonymousUnion_4962316._('currentDocument');

  static const AnonymousUnion_4962316 matchingDocuments =
      AnonymousUnion_4962316._('matchingDocuments');

  static const AnonymousUnion_4962316 allDocuments = AnonymousUnion_4962316._(
    'allDocuments',
  );
}
extension type AnonymousUnion_1194055._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  ThemeColor get asThemeColor => (_ as ThemeColor);
}
extension type AnonymousUnion_1480064._(JSObject _) implements JSObject {
  IMarkdownString get asIMarkdownString => (_ as IMarkdownString);

  JSArray<IMarkdownString> get asJSArray => (_ as JSArray<IMarkdownString>);
}
extension type AnonymousUnion_8471410._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  ITextSnapshot get asITextSnapshot => (_ as ITextSnapshot);
}
extension type AnonymousUnion_8236653._(JSObject _) implements JSObject {
  IRange get asIRange => (_ as IRange);

  JSArray<IRange> get asJSArray => (_ as JSArray<IRange>);
}
extension type AnonymousUnion_1761706._(JSAny _) implements JSAny {
  ILocalizedString get asILocalizedString => (_ as ILocalizedString);

  String get asString => (_ as JSString).toDart;
}
extension type AnonymousType_2245370._(JSObject _) implements JSObject {
  external AnonymousType_2245370();

  external JSAny? operator [](String id);
}
extension type AnonymousUnion_9768228._(JSObject _) implements JSObject {
  ICodeEditorViewState get asICodeEditorViewState =>
      (_ as ICodeEditorViewState);

  IDiffEditorViewState get asIDiffEditorViewState =>
      (_ as IDiffEditorViewState);
}
extension type AnonymousUnion_5377231._(JSObject _) implements JSObject {
  ITextModel get asITextModel => (_ as ITextModel);

  IDiffEditorModel get asIDiffEditorModel => (_ as IDiffEditorModel);

  IDiffEditorViewModel get asIDiffEditorViewModel =>
      (_ as IDiffEditorViewModel);
}
extension type _AnonymousFunction_9788823._(JSFunction _)
    implements JSFunction {
  external JSAny? call();
}
extension type const AnonymousUnion_9797102._(String _) {
  static const AnonymousUnion_9797102 above = AnonymousUnion_9797102._('above');

  static const AnonymousUnion_9797102 below = AnonymousUnion_9797102._('below');

  static const AnonymousUnion_9797102 left = AnonymousUnion_9797102._('left');

  static const AnonymousUnion_9797102 right = AnonymousUnion_9797102._('right');
}
extension type AnonymousUnion_2870280._(IBaseMouseTarget _)
    implements IBaseMouseTarget {
  IMouseTargetUnknown get asIMouseTargetUnknown => (_ as IMouseTargetUnknown);

  IMouseTargetTextarea get asIMouseTargetTextarea =>
      (_ as IMouseTargetTextarea);

  IMouseTargetMargin get asIMouseTargetMargin => (_ as IMouseTargetMargin);

  IMouseTargetViewZone get asIMouseTargetViewZone =>
      (_ as IMouseTargetViewZone);

  IMouseTargetContentText get asIMouseTargetContentText =>
      (_ as IMouseTargetContentText);

  IMouseTargetContentEmpty get asIMouseTargetContentEmpty =>
      (_ as IMouseTargetContentEmpty);

  IMouseTargetContentWidget get asIMouseTargetContentWidget =>
      (_ as IMouseTargetContentWidget);

  IMouseTargetOverlayWidget get asIMouseTargetOverlayWidget =>
      (_ as IMouseTargetOverlayWidget);

  IMouseTargetScrollbar get asIMouseTargetScrollbar =>
      (_ as IMouseTargetScrollbar);

  IMouseTargetOverviewRuler get asIMouseTargetOverviewRuler =>
      (_ as IMouseTargetOverviewRuler);

  IMouseTargetOutsideEditor get asIMouseTargetOutsideEditor =>
      (_ as IMouseTargetOutsideEditor);
}

/// Exclude null and undefined from T
typedef NonNullable<T extends JSAny?> = AnonymousIntersection_1298543;
extension type AnonymousType_1495304._(JSObject _) implements JSObject {
  external AnonymousType_1495304();
}
extension type AnonymousIntersection_1298543<T extends JSAny?>._(JSAny _)
    implements JSAny {
  T get asT => (_ as T);

  AnonymousType_1495304 get asAnonymousType_1495304 =>
      (_ as AnonymousType_1495304);
}
extension type AnonymousUnion_1292433._(JSAny _) implements JSAny {
  OverlayWidgetPositionPreference get asOverlayWidgetPositionPreference =>
      OverlayWidgetPositionPreference._((_ as JSNumber).toDartInt);

  IOverlayWidgetPositionCoordinates get asIOverlayWidgetPositionCoordinates =>
      (_ as IOverlayWidgetPositionCoordinates);
}
extension type _AnonymousFunction_3765586._(JSFunction _)
    implements JSFunction {
  external JSAny? call(num top);
}
extension type _AnonymousFunction_9273974._(JSFunction _)
    implements JSFunction {
  external JSAny? call(num height);
}
extension type AnonymousType_1105536._(JSObject _) implements JSObject {
  external AnonymousType_1105536({bool preserveBOM, String lineEnding});

  external bool preserveBOM;

  external String lineEnding;
}
extension type _AnonymousFunction_3726976._(JSFunction _)
    implements JSFunction {
  external JSAny? call(IViewZoneChangeAccessor accessor);
}
extension type AnonymousType_1340361._(JSObject _) implements JSObject {
  external AnonymousType_1340361({double top, double left, double height});

  external double top;

  external double left;

  external double height;
}
extension type AnonymousUnion_4186185._(JSObject _) implements JSObject {
  ICursorStateComputer get asICursorStateComputer =>
      (_ as ICursorStateComputer);

  JSArray<Selection> get asJSArray => (_ as JSArray<Selection>);
}
extension type AnonymousUnion_1977706._(JSAny _) implements JSAny {
  bool get asBool => (_ as JSBoolean).toDart;

  double get asDouble => (_ as JSNumber).toDartDouble;

  String get asString => (_ as JSString).toDart;

  JSArray<AnonymousUnion_1096157> get asJSArray =>
      (_ as JSArray<AnonymousUnion_1096157>);
}
extension type AnonymousUnion_1480743._(JSAny _) implements JSAny {
  JSAny? get asJSAny => (_ as JSAny?);

  JSPromise<JSAny?> get asJSPromise => (_ as JSPromise<JSAny?>);
}
extension type AnonymousIntersection_1108773._(JSObject _)
    implements IEditorOptions, IGlobalEditorOptions {
  IEditorOptions get asIEditorOptions => (_ as IEditorOptions);

  IGlobalEditorOptions get asIGlobalEditorOptions =>
      (_ as IGlobalEditorOptions);
}
extension type AnonymousType_3503859._(JSObject _) implements JSObject {
  external AnonymousType_3503859({
    bool showMoves,
    bool showEmptyDecorations,
    bool useTrueInlineView,
  });

  /// Defaults to false.
  external bool? showMoves;

  external bool? showEmptyDecorations;

  /// Only applies when `renderSideBySide` is set to false.
  external bool? useTrueInlineView;
}
extension type AnonymousType_1028919._(JSObject _) implements JSObject {
  external AnonymousType_1028919({
    bool enabled,
    double revealLineCount,
    double minimumLineCount,
    double contextLineCount,
  });

  external bool? enabled;

  external double? revealLineCount;

  external double? minimumLineCount;

  external double? contextLineCount;
}
extension type const AnonymousUnion_5232810._(String _) {
  static const AnonymousUnion_5232810 legacy = AnonymousUnion_5232810._(
    'legacy',
  );

  static const AnonymousUnion_5232810 advanced = AnonymousUnion_5232810._(
    'advanced',
  );
}
extension type AnonymousUnion_1651566._(JSObject _) implements JSObject {
  IDiffEditorModel get asIDiffEditorModel => (_ as IDiffEditorModel);

  IDiffEditorViewModel get asIDiffEditorViewModel =>
      (_ as IDiffEditorViewModel);
}
extension type const AnonymousUnion_5800417._(String _) {
  static const AnonymousUnion_5800417 next = AnonymousUnion_5800417._('next');

  static const AnonymousUnion_5800417 previous = AnonymousUnion_5800417._(
    'previous',
  );
}
extension type AnonymousType_1708983._(JSObject _) implements JSObject {
  external AnonymousType_1708983({String value, Uri target});

  external String value;

  external Uri target;
}
extension type AnonymousUnion_6455845._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  AnonymousType_1708983 get asAnonymousType_1708983 =>
      (_ as AnonymousType_1708983);
}
extension type AnonymousType_5247951._(JSObject _) implements JSObject {
  external AnonymousType_5247951();

  external String operator [](String colorId);
}
extension type AnonymousUnion_1465962._(JSAny _) implements JSAny {
  bool get asBool => (_ as JSBoolean).toDart;

  JSPromise<JSBoolean> get asJSPromise => (_ as JSPromise<JSBoolean>);
}
extension type AnonymousUnion_7564194._(JSObject _) implements JSObject {
  IRange get asIRange => (_ as IRange);

  IPosition get asIPosition => (_ as IPosition);
}

extension type RegExp._(JSObject _) implements JSObject {
  external double lastIndex;

  /// Returns a copy of the text of the regular expression pattern. Read-only.
  /// The regExp argument is a Regular expression object. It can be a variable
  /// name or a literal.
  external String get source;

  /// Returns a Boolean value indicating the state of the global flag (g) used
  /// with a regular expression. Default is false. Read-only.
  external bool get global;

  /// Returns a Boolean value indicating the state of the ignoreCase flag (i)
  /// used with a regular expression. Default is false. Read-only.
  external bool get ignoreCase;

  /// Returns a Boolean value indicating the state of the multiline flag (m)
  /// used with a regular expression. Default is false. Read-only.
  external bool get multiline;

  /// Executes a search on a string using a regular expression pattern, and
  /// returns an array containing the results of that search.
  /// - [string]:  The String object or string literal on which to perform the
  ///   search.
  external RegExpExecArray? exec(String string);

  /// Returns a Boolean value that indicates whether or not a pattern exists in
  /// a searched string.
  /// - [string]:  String on which to perform the search.
  external bool test(String string);
  @Deprecated('A legacy feature for browser compatibility')
  external RegExp compile(String pattern, [String? flags]);
}
extension type RegExpExecArray._(JSArray<JSString> _)
    implements JSArray<JSString> {
  /// The index of the search at which the result was found.
  external double index;

  /// A copy of the search string.
  external String input;
}
extension type AnonymousType_1821766._(JSObject _) implements JSObject {
  external AnonymousType_1821766({IDocComment docComment});

  external IDocComment? docComment;
}

/// Provides functionality common to all JavaScript objects.
extension type Object._(JSObject _) implements JSObject {
  /// The initial value of Object.prototype.constructor is the standard built-in
  /// Object constructor.
  external JSFunction constructor;

  /// Returns a string representation of an object.
  @JS('toString')
  external String toString$();

  /// Returns a date converted to a string using the current locale.
  external String toLocaleString();

  /// Returns the primitive value of the specified object.
  external Object valueOf();

  /// Determines whether an object has a property with the specified name.
  /// - [v]:  A property name.
  external bool hasOwnProperty(PropertyKey v);

  /// Determines whether an object exists in another object's prototype chain.
  /// - [v]:  Another object whose prototype chain is to be checked.
  external bool isPrototypeOf(Object v);

  /// Determines whether a specified property is enumerable.
  /// - [v]:  A property name.
  external bool propertyIsEnumerable(PropertyKey v);
}
typedef PropertyKey = AnonymousUnion_2690789;
extension type AnonymousUnion_2690789._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  double get asDouble => (_ as JSNumber).toDartDouble;

  JSSymbol get asJSSymbol => (_ as JSSymbol);
}
extension type AnonymousUnion_1023627._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  RegExp get asRegExp => (_ as RegExp);
}
extension type AnonymousUnion_7629275<TResult1 extends JSAny?>._(JSAny _)
    implements JSAny {
  TResult1 get asTResult1 => (_ as TResult1);

  JSAny? get asJSAny => (_ as JSAny?);
}
extension type AnonymousUnion_8275447<TResult2 extends JSAny?>._(JSAny _)
    implements JSAny {
  TResult2 get asTResult2 => (_ as TResult2);

  JSAny? get asJSAny => (_ as JSAny?);
}
extension type AnonymousUnion_1421519._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  IRelativePattern get asIRelativePattern => (_ as IRelativePattern);
}
extension type ReadonlyArray<T extends JSAny?>._(JSObject _)
    implements JSObject {
  /// Gets the length of the array. This is a number one higher than the highest
  /// element defined in an array.
  external double get length;

  /// Returns a string representation of an array.
  @JS('toString')
  external String toString$();

  /// Returns a string representation of an array. The elements are converted to
  /// string using their toLocaleString methods.
  external String toLocaleString();

  /// Adds all the elements of an array separated by the specified separator
  /// string.
  /// - [separator]:  A string used to separate one element of an array from the
  ///   next in the resulting String. If omitted, the array elements are
  ///   separated with a comma.
  external String join([String? separator]);

  /// Returns a section of an array.
  /// - [start]:  The beginning of the specified portion of the array.
  /// - [end]:  The end of the specified portion of the array. This is exclusive
  ///   of the element at the index 'end'.
  external JSArray<T> slice([num? start, num? end]);

  /// Returns the index of the first occurrence of a value in an array.
  /// - [searchElement]:  The value to locate in the array.
  /// - [fromIndex]:  The array index at which to begin the search. If fromIndex
  ///   is omitted, the search starts at index 0.
  external double indexOf(T searchElement, [num? fromIndex]);

  /// Returns the index of the last occurrence of a specified value in an array.
  /// - [searchElement]:  The value to locate in the array.
  /// - [fromIndex]:  The array index at which to begin the search. If fromIndex
  ///   is omitted, the search starts at the last index in the array.
  external double lastIndexOf(T searchElement, [num? fromIndex]);

  /// Determines whether all the members of an array satisfy the specified test.
  /// - [predicate]:  A function that accepts up to three arguments. The every
  ///   method calls
  /// the predicate function for each element in the array until the predicate
  /// returns a value
  /// which is coercible to the Boolean value false, or until the end of the
  /// array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function.
  /// If thisArg is omitted, undefined is used as the this value.
  /// - [predicate]:  A function that accepts up to three arguments. The every
  ///   method calls
  /// the predicate function for each element in the array until the predicate
  /// returns a value
  /// which is coercible to the Boolean value false, or until the end of the
  /// array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function.
  /// If thisArg is omitted, undefined is used as the this value.
  external JSAny every<S extends T>(
    _AnonymousFunction_1236351<T> predicate, [
    JSAny? thisArg,
  ]);

  /// Determines whether all the members of an array satisfy the specified test.
  /// - [predicate]:  A function that accepts up to three arguments. The every
  ///   method calls
  /// the predicate function for each element in the array until the predicate
  /// returns a value
  /// which is coercible to the Boolean value false, or until the end of the
  /// array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function.
  /// If thisArg is omitted, undefined is used as the this value.
  /// - [predicate]:  A function that accepts up to three arguments. The every
  ///   method calls
  /// the predicate function for each element in the array until the predicate
  /// returns a value
  /// which is coercible to the Boolean value false, or until the end of the
  /// array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function.
  /// If thisArg is omitted, undefined is used as the this value.
  @JS('every')
  external bool every$1(
    _AnonymousFunction_1236351<T> predicate, [
    JSAny? thisArg,
  ]);

  /// Determines whether the specified callback function returns true for any
  /// element of an array.
  /// - [predicate]:  A function that accepts up to three arguments. The some
  ///   method calls
  /// the predicate function for each element in the array until the predicate
  /// returns a value
  /// which is coercible to the Boolean value true, or until the end of the
  /// array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function.
  /// If thisArg is omitted, undefined is used as the this value.
  external bool some(_AnonymousFunction_1236351<T> predicate, [JSAny? thisArg]);

  /// Performs the specified action for each element in an array.
  /// - [callbackfn]:  A function that accepts up to three arguments. forEach
  ///   calls the callbackfn function one time for each element in the array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   callbackfn function. If thisArg is omitted, undefined is used as the
  ///   this value.
  external JSAny? forEach(
    _AnonymousFunction_1236351<T> callbackfn, [
    JSAny? thisArg,
  ]);

  /// Calls a defined callback function on each element of an array, and returns
  /// an array that contains the results.
  /// - [callbackfn]:  A function that accepts up to three arguments. The map
  ///   method calls the callbackfn function one time for each element in the
  ///   array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   callbackfn function. If thisArg is omitted, undefined is used as the
  ///   this value.
  external JSArray<U> map<U extends JSAny?>(
    _AnonymousFunction_1024108<U, T> callbackfn, [
    JSAny? thisArg,
  ]);

  /// Returns the elements of an array that meet the condition specified in a
  /// callback function.
  /// - [predicate]:  A function that accepts up to three arguments. The filter
  ///   method calls the predicate function one time for each element in the
  ///   array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function. If thisArg is omitted, undefined is used as the this
  ///   value.
  /// - [predicate]:  A function that accepts up to three arguments. The filter
  ///   method calls the predicate function one time for each element in the
  ///   array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function. If thisArg is omitted, undefined is used as the this
  ///   value.
  external JSArray<S> filter<S extends T>(
    _AnonymousFunction_1236351<T> predicate, [
    JSAny? thisArg,
  ]);

  /// Returns the elements of an array that meet the condition specified in a
  /// callback function.
  /// - [predicate]:  A function that accepts up to three arguments. The filter
  ///   method calls the predicate function one time for each element in the
  ///   array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function. If thisArg is omitted, undefined is used as the this
  ///   value.
  /// - [predicate]:  A function that accepts up to three arguments. The filter
  ///   method calls the predicate function one time for each element in the
  ///   array.
  /// - [thisArg]:  An object to which the this keyword can refer in the
  ///   predicate function. If thisArg is omitted, undefined is used as the this
  ///   value.
  @JS('filter')
  external JSArray<T> filter$1(
    _AnonymousFunction_1236351<T> predicate, [
    JSAny? thisArg,
  ]);

  /// Calls the specified callback function for all the elements in an array.
  /// The return value of the callback function is the accumulated result, and
  /// is provided as an argument in the next call to the callback function.
  /// - [callbackfn]:  A function that accepts up to four arguments. The reduce
  ///   method calls the callbackfn function one time for each element in the
  ///   array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  /// - [callbackfn]:  A function that accepts up to four arguments. The reduce
  ///   method calls the callbackfn function one time for each element in the
  ///   array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  external T reduce(_AnonymousFunction_1835882<T> callbackfn);

  /// Calls the specified callback function for all the elements in an array.
  /// The return value of the callback function is the accumulated result, and
  /// is provided as an argument in the next call to the callback function.
  /// - [callbackfn]:  A function that accepts up to four arguments. The reduce
  ///   method calls the callbackfn function one time for each element in the
  ///   array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  /// - [callbackfn]:  A function that accepts up to four arguments. The reduce
  ///   method calls the callbackfn function one time for each element in the
  ///   array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  @JS('reduce')
  external T reduce$1(_AnonymousFunction_1835882<T> callbackfn, T initialValue);

  /// Calls the specified callback function for all the elements in an array.
  /// The return value of the callback function is the accumulated result, and
  /// is provided as an argument in the next call to the callback function.
  /// - [callbackfn]:  A function that accepts up to four arguments. The reduce
  ///   method calls the callbackfn function one time for each element in the
  ///   array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  /// - [callbackfn]:  A function that accepts up to four arguments. The reduce
  ///   method calls the callbackfn function one time for each element in the
  ///   array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  @JS('reduce')
  external U reduce$2<U extends JSAny?>(
    _AnonymousFunction_8698191<U, T> callbackfn,
    U initialValue,
  );

  /// Calls the specified callback function for all the elements in an array, in
  /// descending order. The return value of the callback function is the
  /// accumulated result, and is provided as an argument in the next call to the
  /// callback function.
  /// - [callbackfn]:  A function that accepts up to four arguments. The
  ///   reduceRight method calls the callbackfn function one time for each
  ///   element in the array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  /// - [callbackfn]:  A function that accepts up to four arguments. The
  ///   reduceRight method calls the callbackfn function one time for each
  ///   element in the array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  external T reduceRight(_AnonymousFunction_1835882<T> callbackfn);

  /// Calls the specified callback function for all the elements in an array, in
  /// descending order. The return value of the callback function is the
  /// accumulated result, and is provided as an argument in the next call to the
  /// callback function.
  /// - [callbackfn]:  A function that accepts up to four arguments. The
  ///   reduceRight method calls the callbackfn function one time for each
  ///   element in the array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  /// - [callbackfn]:  A function that accepts up to four arguments. The
  ///   reduceRight method calls the callbackfn function one time for each
  ///   element in the array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  @JS('reduceRight')
  external T reduceRight$1(
    _AnonymousFunction_1835882<T> callbackfn,
    T initialValue,
  );

  /// Calls the specified callback function for all the elements in an array, in
  /// descending order. The return value of the callback function is the
  /// accumulated result, and is provided as an argument in the next call to the
  /// callback function.
  /// - [callbackfn]:  A function that accepts up to four arguments. The
  ///   reduceRight method calls the callbackfn function one time for each
  ///   element in the array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  /// - [callbackfn]:  A function that accepts up to four arguments. The
  ///   reduceRight method calls the callbackfn function one time for each
  ///   element in the array.
  /// - [initialValue]:  If initialValue is specified, it is used as the initial
  ///   value to start the accumulation. The first call to the callbackfn
  ///   function provides this value as an argument instead of an array value.
  @JS('reduceRight')
  external U reduceRight$2<U extends JSAny?>(
    _AnonymousFunction_8698191<U, T> callbackfn,
    U initialValue,
  );
  external T operator [](num n);
  external void operator []=(num n, T newValue);
}
extension type AnonymousUnion_7270688._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  LanguageFilter get asLanguageFilter => (_ as LanguageFilter);

  ReadonlyArray<AnonymousUnion_7270688> get asReadonlyArray =>
      (_ as ReadonlyArray<AnonymousUnion_7270688>);
}
extension type _AnonymousFunction_1236351<T extends JSAny?>._(JSFunction _)
    implements JSFunction {
  external JSAny call(T value, num index, JSArray<T> array);
}
extension type _AnonymousFunction_1024108<U extends JSAny?, T extends JSAny?>._(
  JSFunction _
)
    implements JSFunction {
  external U call(T value, num index, JSArray<T> array);
}
extension type _AnonymousFunction_1835882<T extends JSAny?>._(JSFunction _)
    implements JSFunction {
  external T call(
    T previousValue,
    T currentValue,
    num currentIndex,
    JSArray<T> array,
  );
}
extension type _AnonymousFunction_8698191<U extends JSAny?, T extends JSAny?>._(
  JSFunction _
)
    implements JSFunction {
  external U call(
    U previousValue,
    T currentValue,
    num currentIndex,
    JSArray<T> array,
  );
}
extension type AnonymousType_8129350._(JSObject _) implements JSObject {
  external AnonymousType_8129350({bool insertAsSnippet});

  external bool? insertAsSnippet;
}
extension type AnonymousIntersection_1612513._(JSObject _)
    implements TextEdit, AnonymousType_8129350 {
  TextEdit get asTextEdit => (_ as TextEdit);

  AnonymousType_8129350 get asAnonymousType_8129350 =>
      (_ as AnonymousType_8129350);
}
extension type AnonymousUnion_1311135._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  _i4.JSTuple2<JSNumber, JSNumber> get asJSTuple2 =>
      (_ as _i4.JSTuple2<JSNumber, JSNumber>);
}
extension type AnonymousUnion_1021609._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  IMarkdownString get asIMarkdownString => (_ as IMarkdownString);
}
extension type AnonymousUnion_1319147._(JSObject _) implements JSObject {
  Location get asLocation => (_ as Location);

  JSArray<Location> get asJSArray => (_ as JSArray<Location>);
}
extension type AnonymousUnion_1486863._(JSAny _) implements JSAny {
  Uri get asUri => (_ as Uri);

  String get asString => (_ as JSString).toDart;
}
extension type _AnonymousFunction_6172145._(JSFunction _)
    implements JSFunction {
  external ProviderResult<ILink> call(ILink link, CancellationToken token);
}
extension type AnonymousUnion_2303113._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  CompletionItemLabel get asCompletionItemLabel => (_ as CompletionItemLabel);
}
extension type AnonymousUnion_3663630._(JSObject _) implements JSObject {
  IRange get asIRange => (_ as IRange);

  CompletionItemRanges get asCompletionItemRanges =>
      (_ as CompletionItemRanges);
}
extension type AnonymousType_1327453._(JSObject _) implements JSObject {
  external AnonymousType_1327453({String snippet});

  external String snippet;
}
extension type AnonymousUnion_6358053._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  AnonymousType_1327453 get asAnonymousType_1327453 =>
      (_ as AnonymousType_1327453);
}
extension type const AnonymousUnion_1214657._(String _) {
  static const AnonymousUnion_1214657 plaintext = AnonymousUnion_1214657._(
    'plaintext',
  );

  static const AnonymousUnion_1214657 markdown = AnonymousUnion_1214657._(
    'markdown',
  );
}
extension type const AnonymousUnion_3249694._(String _) {
  static const AnonymousUnion_3249694 standard = AnonymousUnion_3249694._(
    'standard',
  );

  static const AnonymousUnion_3249694 experimental = AnonymousUnion_3249694._(
    'experimental',
  );

  static const AnonymousUnion_3249694 nonstandard = AnonymousUnion_3249694._(
    'nonstandard',
  );

  static const AnonymousUnion_3249694 obsolete = AnonymousUnion_3249694._(
    'obsolete',
  );
}
extension type AnonymousUnion_9963490._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  MarkupContent get asMarkupContent => (_ as MarkupContent);
}
extension type AnonymousType_2581160._(JSObject _) implements JSObject {
  external AnonymousType_2581160();

  external CSSDataV1 operator [](String providerId);
}
extension type const AnonymousUnion_1283868._(String _) {
  static const AnonymousUnion_1283868 collapse = AnonymousUnion_1283868._(
    'collapse',
  );

  static const AnonymousUnion_1283868 expand = AnonymousUnion_1283868._(
    'expand',
  );
}
extension type AnonymousType_1410451._(JSObject _) implements JSObject {
  external AnonymousType_1410451({
    AnonymousUnion_6291848 compatibleVendorPrefixes,
    AnonymousUnion_6291848 vendorPrefix,
    AnonymousUnion_6291848 duplicateProperties,
    AnonymousUnion_6291848 emptyRules,
    AnonymousUnion_6291848 importStatement,
    AnonymousUnion_6291848 boxModel,
    AnonymousUnion_6291848 universalSelector,
    AnonymousUnion_6291848 zeroUnits,
    AnonymousUnion_6291848 fontFaceProperties,
    AnonymousUnion_6291848 hexColorLength,
    AnonymousUnion_6291848 argumentsInColorFunction,
    AnonymousUnion_6291848 unknownProperties,
    AnonymousUnion_6291848 ieHack,
    AnonymousUnion_6291848 unknownVendorSpecificProperties,
    AnonymousUnion_6291848 propertyIgnoredDueToDisplay,
    AnonymousUnion_6291848 important,
    AnonymousUnion_6291848 float,
    AnonymousUnion_6291848 idSelector,
  });

  external AnonymousUnion_6291848? get compatibleVendorPrefixes;
  external AnonymousUnion_6291848? get vendorPrefix;
  external AnonymousUnion_6291848? get duplicateProperties;
  external AnonymousUnion_6291848? get emptyRules;
  external AnonymousUnion_6291848? get importStatement;
  external AnonymousUnion_6291848? get boxModel;
  external AnonymousUnion_6291848? get universalSelector;
  external AnonymousUnion_6291848? get zeroUnits;
  external AnonymousUnion_6291848? get fontFaceProperties;
  external AnonymousUnion_6291848? get hexColorLength;
  external AnonymousUnion_6291848? get argumentsInColorFunction;
  external AnonymousUnion_6291848? get unknownProperties;
  external AnonymousUnion_6291848? get ieHack;
  external AnonymousUnion_6291848? get unknownVendorSpecificProperties;
  external AnonymousUnion_6291848? get propertyIgnoredDueToDisplay;
  external AnonymousUnion_6291848? get important;
  external AnonymousUnion_6291848? get float;
  external AnonymousUnion_6291848? get idSelector;
}
extension type const AnonymousUnion_6291848._(String _) {
  static const AnonymousUnion_6291848 error = AnonymousUnion_6291848._('error');

  static const AnonymousUnion_6291848 warning = AnonymousUnion_6291848._(
    'warning',
  );

  static const AnonymousUnion_6291848 ignore = AnonymousUnion_6291848._(
    'ignore',
  );
}
extension type const AnonymousUnion_1640272._(String _) {
  static const AnonymousUnion_1640272 auto = AnonymousUnion_1640272._('auto');

  static const AnonymousUnion_1640272 force = AnonymousUnion_1640272._('force');

  static const AnonymousUnion_1640272 forceAligned = AnonymousUnion_1640272._(
    'force-aligned',
  );

  static const AnonymousUnion_1640272 forceExpandMultiline =
      AnonymousUnion_1640272._('force-expand-multiline');
}
extension type AnonymousType_2063447._(JSObject _) implements JSObject {
  external AnonymousType_2063447();

  external HTMLDataV1 operator [](String providerId);
}
extension type const AnonymousUnion_5346609._(String _) {
  static const AnonymousUnion_5346609 object = AnonymousUnion_5346609._(
    'object',
  );

  static const AnonymousUnion_5346609 array = AnonymousUnion_5346609._('array');

  static const AnonymousUnion_5346609 property = AnonymousUnion_5346609._(
    'property',
  );

  static const AnonymousUnion_5346609 string = AnonymousUnion_5346609._(
    'string',
  );

  static const AnonymousUnion_5346609 number = AnonymousUnion_5346609._(
    'number',
  );

  static const AnonymousUnion_5346609 boolean = AnonymousUnion_5346609._(
    'boolean',
  );

  static const AnonymousUnion_5346609 null$ = AnonymousUnion_5346609._('null');
}
extension type AnonymousUnion_1096157._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  bool get asBool => (_ as JSBoolean).toDart;

  double get asDouble => (_ as JSNumber).toDartDouble;
}
extension type AnonymousUnion_1333870._(BaseASTNode _) implements BaseASTNode {
  ObjectASTNode get asObjectASTNode => (_ as ObjectASTNode);

  PropertyASTNode get asPropertyASTNode => (_ as PropertyASTNode);

  ArrayASTNode get asArrayASTNode => (_ as ArrayASTNode);

  StringASTNode get asStringASTNode => (_ as StringASTNode);

  NumberASTNode get asNumberASTNode => (_ as NumberASTNode);

  BooleanASTNode get asBooleanASTNode => (_ as BooleanASTNode);

  NullASTNode get asNullASTNode => (_ as NullASTNode);
}
extension type AnonymousUnion_1894070._(JSAny _) implements JSAny {
  JSAny? get asJSAny => (_ as JSAny?);

  bool get asBool => (_ as JSBoolean).toDart;
}
extension type AnonymousUnion_7094455._(JSAny _) implements JSAny {
  bool get asBool => (_ as JSBoolean).toDart;

  JSONSchemaRef get asJSONSchemaRef => (_ as AnonymousUnion_1894070);
}
extension type AnonymousUnion_2735524._(JSAny _) implements JSAny {
  JSONSchemaRef get asJSONSchemaRef => (_ as AnonymousUnion_1894070);

  JSArray<AnonymousUnion_1894070> get asJSArray =>
      (_ as JSArray<AnonymousUnion_1894070>);
}
extension type AnonymousUnion_4790927._(JSAny _) implements JSAny {
  bool get asBool => (_ as JSBoolean).toDart;

  double get asDouble => (_ as JSNumber).toDartDouble;
}
extension type AnonymousType_1393492._(JSObject _) implements JSObject {
  external AnonymousType_1393492({ASTNode? root});

  external ASTNode? root;

  external ASTNode? getNodeFromOffset(num offset, [bool? includeRightBound]);
}
extension type AnonymousType_8401536._(JSObject _) implements JSObject {
  external AnonymousType_8401536({String fileName});

  external String fileName;
}
extension type const AnonymousUnion_7456409._(num _) {
  static const AnonymousUnion_7456409 $0 = AnonymousUnion_7456409._(0);

  static const AnonymousUnion_7456409 $1 = AnonymousUnion_7456409._(1);

  static const AnonymousUnion_7456409 $2 = AnonymousUnion_7456409._(2);

  static const AnonymousUnion_7456409 $3 = AnonymousUnion_7456409._(3);
}

/// A linked list of formatted diagnostic messages to be used as part of a
/// multiline message.
/// It is built from the bottom up, leaving the head to be the "main"
/// diagnostic.
extension type DiagnosticMessageChain._(JSObject _) implements JSObject {
  external String messageText;

  /// Diagnostic category: warning = 0, error = 1, suggestion = 2, message = 3
  external AnonymousUnion_7456409 category;

  external double code;

  external JSArray<JSAny?>? next;
}
extension type AnonymousUnion_1514162._(JSAny _) implements JSAny {
  String get asString => (_ as JSString).toDart;

  DiagnosticMessageChain get asDiagnosticMessageChain =>
      (_ as DiagnosticMessageChain);
}
extension type IExtraLib._(JSObject _) implements JSObject {
  external String content;

  external double version;
}
