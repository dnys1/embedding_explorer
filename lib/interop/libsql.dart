/// WASM interop bindings for LibSQL-wasm.
///
/// Requires that the sqlite3InitModule function has been called and the return
/// value assigned to `globalThis.libsql`.
@JS('libsql')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import 'common.dart';

Future<void>? _loadFuture;

Future<void> loadModule({Uri? moduleUri}) async {
  if (globalContext['libsql'].isDefinedAndNotNull) {
    return;
  }
  return _loadFuture ??= _loadModule(moduleUri);
}

Future<void> _loadModule(Uri? libsqlUri) async {
  libsqlUri ??= Uri.base.resolve('./js/libsql.js');
  final logger = Logger('libsql');
  logger.config('Loading LibSQL module from $libsqlUri');

  // Different ways to load the module, depending on how it was included
  _LibsqlLoader? libsqlLoader;
  {
    libsqlLoader =
        await importModule(libsqlUri.toString().toJS).toDart as _LibsqlLoader?;
    if (libsqlLoader.isUndefinedOrNull ||
        libsqlLoader!.getProperty('default'.toJS).isUndefinedOrNull) {
      libsqlLoader = globalContext['libsqlLoader'] as _LibsqlLoader;
    }
  }

  globalContext['libsql'] = await libsqlLoader
      .init(
        InitOptions(
          locateFile: (path, prefix) {
            // for example:
            //  prefix=http://localhost:8080/js/
            //  path=sqlite3.wasm
            return Uri.parse(prefix).resolve(path).toString();
          },
          print: (msg) => logger.finest(msg),
          printErr: (msg) => logger.warning(msg),
        ),
      )
      .toDart;
}

extension type _LibsqlLoader._(JSObject _) implements JSObject {
  /// A function installed by Emscripten to load and initialize the module. It
  /// accepts an optional object to act as the so-called Emscripten Module, with
  /// which the client may be notified of loading progress an errors.
  ///
  /// See the [Emscripten docs on the topic][1] for full details.
  ///
  /// Note that this project has no influence over those options and the
  /// Emscripten
  /// project may change them at any time, so we neither document nor support
  /// them.
  /// Note, also, that this project may attempt to internally override any
  /// specific
  /// option, potentially leading to undesired side effects if client code does
  /// the
  /// same.
  ///
  /// [1] https://emscripten.org/docs/api_reference/module.html
  @JS('default')
  external JSPromise<JSAny?> init([InitOptions? opts]);
}

@JS('capi.sqlite3_vfs_find')
external JSAny? _findVfs(String name);

/// Whether the current browser environment supports the OPFS VFS.
bool get supportsOpfs {
  final vfs = _findVfs('opfs');
  return vfs.isTruthy.toDart;
}

extension type SqlValue._(JSAny _) implements JSAny {
  static SqlValue? fromDart(Object? o) {
    return switch (o) {
      null => null,
      String s => SqlValue.string(s),
      num n => SqlValue.number(n),
      Uint8List b => SqlValue.blob(b),
      ByteBuffer b => SqlValue.arrayBuffer(b),
      _ => throw ArgumentError.value(o, 'SqlValue', 'Unsupported type'),
    };
  }

  factory SqlValue.string(String s) => SqlValue._(s.toJS);
  factory SqlValue.number(num n) => SqlValue._(n.toJS);
  factory SqlValue.blob(Uint8List b) => SqlValue._(b.toJS);
  factory SqlValue.arrayBuffer(ByteBuffer b) => SqlValue._(b.toJS);

  String get asString => (_ as JSString).toDart;
  num get asNumber => (_ as JSNumber).toDartDouble;
  Uint8List get asBlob => (_ as JSUint8Array).toDart;
  ByteBuffer get asArrayBuffer => (_ as JSArrayBuffer).toDart;

  Object get toDart {
    final self = _;
    if (self.typeofEquals('string')) {
      return asString;
    }
    if (self.typeofEquals('number')) {
      return asNumber;
    }
    if (self.typeofEquals('object')) {
      if (self.isA<JSArrayBuffer>()) {
        return asArrayBuffer;
      }
      if (self.isA<JSUint8Array>()) {
        return asBlob;
      }
    }
    throw ArgumentError.value(self, 'SqlValue', 'Unsupported type');
  }
}

extension type NamedSqlValue._(JSObject _) implements JSObject {
  Map<String, Object?> get toDart => (_.dartify()! as Map).cast();
}

extension type DatabaseOptions._(JSObject _) implements JSObject {
  external factory DatabaseOptions({
    String? filename,
    String? flags,
    String? vfs,
  });
}

extension type BindingSpec._(JSAny _) implements JSAny {
  factory BindingSpec.positional(List<SqlValue?> values) =>
      BindingSpec._(values.toJS);
  factory BindingSpec.named(Map<String, SqlValue?> values) =>
      BindingSpec._(values.jsify()!);
}

/// A string specifying what this function should return: The default value is
/// (usually) `"this"`. The exceptions is if the caller passes neither of
/// `callback` nor `returnValue` but does pass an explicit `rowMode` then the
/// default returnValue is `"resultRows"`, described below. The options are:
///
/// - `"this"` menas that the DB object itself should be returned.
/// - `"resultRows"` means to return the value of the `resultRows` option. If
///   `resultRows` is not set, this function behaves as if it were set to an
///   empty array.
/// - `"saveSql"` means to return the value of the `saveSql` option. If `saveSql`
///   is not set, this function behaves as if it were set to an empty array.
extension type const ExecReturnValue._(String _) implements String {
  static const ExecReturnValue db = ExecReturnValue._('this');
  static const ExecReturnValue resultRows = ExecReturnValue._('resultRows');
  static const ExecReturnValue saveSql = ExecReturnValue._('saveSql');
}

extension type ExecOptions._(JSObject _) implements JSObject {
  external factory ExecOptions._create({
    String? sql,
    BindingSpec? bind,
    ExecReturnValue? returnValue,
    JSString? rowMode,
    JSArray<JSString>? columnNames,
    JSArray<JSAny>? resultRows,
  });

  factory ExecOptions.exec({
    required String sql,
    List<Object?> bind = const [],
  }) {
    return ExecOptions._create(
      sql: sql,
      bind: BindingSpec.positional(bind.map(SqlValue.fromDart).toList()),
    );
  }

  factory ExecOptions.query({
    required String sql,
    List<Object?> bind = const [],
  }) {
    final options = ExecOptions._create(
      sql: sql,
      bind: BindingSpec.positional(bind.map(SqlValue.fromDart).toList()),
      returnValue: ExecReturnValue.resultRows,
      columnNames: JSArray<JSString>(),
      resultRows: JSArray<JSAny>(),
      rowMode: 'object'.toJS,
    );
    return options;
  }

  /// The SQL to run (unless it's provided as the first argument). The SQL may
  /// contain any number of statements.
  external String? sql;

  /// A single value valid as an argument for PreparedStatement#bind . This
  /// is only applied to the first non-empty statement in the SQL which has any
  /// bindable parameters. (Empty statements are skipped entirely.)
  external BindingSpec? bind;

  /// A string specifying what this function should return: The default value is
  /// (usually) `"this"`. The exceptions is if the caller passes neither of
  /// `callback` nor `returnValue` but does pass an explicit `rowMode` then the
  /// default returnValue is `"resultRows"`, described below. The options are:
  ///
  /// - `"this"` menas that the DB object itself should be returned.
  /// - `"resultRows"` means to return the value of the `resultRows` option. If
  /// `resultRows` is not set, this function behaves as if it were set to an
  /// empty array.
  /// - `"saveSql"` means to return the value of the `saveSql` option. If
  ///   `saveSql`
  /// is not set, this function behaves as if it were set to an empty array.
  external ExecReturnValue? returnValue;

  external JSFunction? _callback;

  set callback(
    void Function(Map<String, Object?> row, PreparedStatement stmt) callback,
  ) {
    _callback = (JSObject row, PreparedStatement stmt) {
      final values = (row.dartify()! as Map).cast<String, Object?>();
      callback(values, stmt);
    }.toJS;
  }

  JSFunction? get callback => _callback;

  @JS('columnNames')
  external JSArray<JSString> get _columnNames;

  /// If this is an array, the column names of the result set are stored in this
  /// array before the `callback` (if any) is triggered (regardless of whether
  /// the query produces any result rows). If no statement has result columns,
  /// this value is unchanged.
  ///
  /// Applies only to the first statement which has a non-zero result column
  /// count, regardless of whether the statement actually produces any result
  /// rows.
  ///
  /// **Achtung:** an SQL result may have multiple columns with identical names.
  List<String> get columnNames =>
      _columnNames.toDart.map((e) => e.toDart).toList();

  @JS('resultRows')
  external JSArray<JSObject> get _resultRows;

  /// If this is an array, it functions similarly to the `callback` option: each
  /// row of the result set (if any), with the exception that the `rowMode`
  /// `'stmt'` is not legal. It is legal to use both `resultRows` and callback,
  /// but `resultRows` is likely much simpler to use for small data sets and can
  /// be used over a WebWorker-style message interface. `exec()` throws if
  /// `resultRows` is set and rowMode is `'stmt'`.
  ///
  /// Applies only to the first statement which has a non-zero result column
  /// count, regardless of whether the statement actually produces any result
  /// rows.
  List<Map<String, Object?>> get resultRows => _resultRows.toDart
      .map((e) => (e.dartify()! as Map).cast<String, Object?>())
      .toList();
}

extension type const SQLiteDataType._(int _) implements int {
  static const SQLiteDataType integer = SQLiteDataType._(1);
  static const SQLiteDataType float = SQLiteDataType._(2);
  static const SQLiteDataType text = SQLiteDataType._(3);
  static const SQLiteDataType blob = SQLiteDataType._(4);
  static const SQLiteDataType null$ = SQLiteDataType._(5);
}

extension type const BeginQualifier._(String _) implements String {
  static const BeginQualifier immediate = BeginQualifier._('IMMEDIATE');
  static const BeginQualifier exclusive = BeginQualifier._('EXCLUSIVE');
  static const BeginQualifier deferred = BeginQualifier._('DEFERRED');
}

/// Prepared statements are created solely through the Database#prepare
/// method. Calling the constructor directly will trigger an exception.
///
/// It is important that statements be finalized in a timely manner, else
/// clients
/// risk introducing locking errors later on in their apps.
///
/// By and large, clients can avoid statement lifetime issues by using the
/// Database#exec  method. For cases when more control or flexibility is
/// needed, however, clients will need to Database#prepare  statements and
/// then ensure that their lifetimes are properly managed. The simplest way to
/// do
/// this is with a `try`/`finally` block, as in this example:
///
/// Example:
/// ```ts
///   const stmt = myDb.prepare("...");
///   try {
///   ... use the stmt object ...
///   } finally {
///   stmt.finalize();
///   }
/// ```
extension type PreparedStatement._(JSObject _) implements JSObject {
  external PreparedStatement();

  /// The number of result columns this statement has, or 0 for statements which
  /// do not have result columns.
  ///
  /// _Minor achtung:_ for all releases > 3.42.0 this is a property interceptor
  /// which invokes `sqlite3_column_count`, so its use should be avoided in
  /// loops
  /// because of the call overhead. In versions <= 3.42.0 this value is
  /// collected
  /// and cached when the statement is created, but that can lead to misbehavior
  /// if changes are made to the database schema while this statement is active.
  external int columnCount;

  /// The number of bindable parameters this statement has.
  external int parameterCount;

  /// WASM pointer rwhich resolves to the `sqlite3_stmt*` which this object
  /// wraps. This value may be passed to any WASM-bound functions which accept
  /// an
  /// `sqlite3_stmt*` argument. It resolves to `undefined` after this statement
  /// is PreparedStatement#finalize d.
  external double? pointer;

  /// Binds one more values to its bindable parameters.
  /// Binds a value to a bindable parameter.
  /// - [idx]:  The index of the bindable parameter to bind to, **ACHTUNG**:
  /// 1-based!
  external PreparedStatement bind(BindingSpec binding);

  /// Binds one more values to its bindable parameters.
  /// Binds a value to a bindable parameter.
  /// - [idx]:  The index of the bindable parameter to bind to, **ACHTUNG**:
  /// 1-based!
  @JS('bind')
  external PreparedStatement bindAt(num idx, SqlValue binding);

  /// Special case of PreparedStatement#bind  which binds the given value
  /// using the `BLOB` binding mechanism instead of the default selected one for
  /// the value. Index can be the index number (**ACHTUNG**: 1-based!) or the
  /// string corresponding to a named parameter.
  external PreparedStatement bindAsBlob(SqlValue? value);

  /// Special case of PreparedStatement#bind  which binds the given value
  /// using the `BLOB` binding mechanism instead of the default selected one for
  /// the value. Index can be the index number (**ACHTUNG**: 1-based!) or the
  /// string corresponding to a named parameter.
  @JS('bindAsBlob')
  external PreparedStatement bindAsBlobAt(num idx, SqlValue? value);

  /// Clears all bound values.
  external PreparedStatement clearBindings();

  /// "Finalizes" this statement. This is a no-op if the statement has already
  /// been finalized. Returns the value of the underlying `sqlite3_finalize()`
  /// call (0 on success, non-0 on error) or `undefined` if the statement has
  /// already been finalized. It does not throw if `sqlite3_finalize()` returns
  /// non-0 because this function is effectively a destructor and "destructors
  /// do
  /// not throw." This function will throw if it is called while the statement
  /// is
  /// in active use via a Database#exec  callback.
  external int? finalize();

  /// Fetches the value from the given 0-based column index of the current data
  /// row, throwing if index is out of range.
  ///
  /// Requires that PreparedStatement#step  has just returned a truthy
  /// value, else an exception is thrown.
  ///
  /// By default it will determine the data type of the result automatically. If
  /// passed a second arugment, it must be one of the enumeration values for
  /// sqlite3 types, which are defined as members of the sqlite3 namespace:
  /// `SQLITE_INTEGER`, `SQLITE_FLOAT`, `SQLITE_TEXT`, `SQLITE_BLOB`. Any other
  /// value, except for `undefined`, will trigger an exception. Passing
  /// `undefined` is the same as not passing a value. It is legal to, e.g.,
  /// fetch
  /// an integer value as a string, in which case sqlite3 will convert the value
  /// to a string.
  ///
  /// If the index is an array, this function behaves a differently: it assigns
  /// the indexes of the array, from 0 to the number of result columns, to the
  /// values of the corresponding result column, and returns that array:
  ///
  /// const values = stmt.get([]);
  ///
  /// This will return an array which contains one entry for each result column
  /// of the statement's current row..
  ///
  /// If the index is a plain object, this function behaves even differentlier:
  /// it assigns the properties of the object to the values of their
  /// corresponding result columns:
  ///
  /// const values = stmt.get({});
  ///
  /// This returns an object with properties named after the columns of the
  /// result set. Be aware that the ordering of the properties is undefined. If
  /// their order is important, use the array form instead.
  ///
  /// Blobs are returned as `Uint8Array` instances.
  ///
  /// Special case handling of 64-bit integers: the `Number` type is used for
  /// both floating point numbers and integers which are small enough to fit
  /// into
  /// it without loss of precision. If a larger integer is fetched, it is
  /// returned as a `BigInt` if that support is enabled, else it will throw an
  /// exception. The range of integers supported by the Number class is defined
  /// as:
  ///
  /// - `Number.MIN_SAFE_INTEGER = -9007199254740991`
  /// - `Number.MAX_SAFE_INTEGER = 9007199254740991`
  external SqlValue get(int ndx, [SQLiteDataType? asType]);

  @JS('get')
  external JSArray<SqlValue?> _getAll(JSArray<SqlValue?> ndx);

  /// Fetches the value from the given 0-based column index of the current data
  /// row, throwing if index is out of range.
  ///
  /// Requires that PreparedStatement#step  has just returned a truthy
  /// value, else an exception is thrown.
  ///
  /// By default it will determine the data type of the result automatically. If
  /// passed a second arugment, it must be one of the enumeration values for
  /// sqlite3 types, which are defined as members of the sqlite3 namespace:
  /// `SQLITE_INTEGER`, `SQLITE_FLOAT`, `SQLITE_TEXT`, `SQLITE_BLOB`. Any other
  /// value, except for `undefined`, will trigger an exception. Passing
  /// `undefined` is the same as not passing a value. It is legal to, e.g.,
  /// fetch
  /// an integer value as a string, in which case sqlite3 will convert the value
  /// to a string.
  ///
  /// If the index is an array, this function behaves a differently: it assigns
  /// the indexes of the array, from 0 to the number of result columns, to the
  /// values of the corresponding result column, and returns that array:
  ///
  /// const values = stmt.get([]);
  ///
  /// This will return an array which contains one entry for each result column
  /// of the statement's current row..
  ///
  /// If the index is a plain object, this function behaves even differentlier:
  /// it assigns the properties of the object to the values of their
  /// corresponding result columns:
  ///
  /// const values = stmt.get({});
  ///
  /// This returns an object with properties named after the columns of the
  /// result set. Be aware that the ordering of the properties is undefined. If
  /// their order is important, use the array form instead.
  ///
  /// Blobs are returned as `Uint8Array` instances.
  ///
  /// Special case handling of 64-bit integers: the `Number` type is used for
  /// both floating point numbers and integers which are small enough to fit
  /// into
  /// it without loss of precision. If a larger integer is fetched, it is
  /// returned as a `BigInt` if that support is enabled, else it will throw an
  /// exception. The range of integers supported by the Number class is defined
  /// as:
  ///
  /// - `Number.MIN_SAFE_INTEGER = -9007199254740991`
  /// - `Number.MAX_SAFE_INTEGER = 9007199254740991`
  List<SqlValue?> getAll() {
    return _getAll(JSArray<SqlValue?>()).toDart;
  }

  @JS('get')
  external JSObject _getAllNamed(JSObject ndx);

  /// Fetches the value from the given 0-based column index of the current data
  /// row, throwing if index is out of range.
  ///
  /// Requires that PreparedStatement#step  has just returned a truthy
  /// value, else an exception is thrown.
  ///
  /// By default it will determine the data type of the result automatically. If
  /// passed a second arugment, it must be one of the enumeration values for
  /// sqlite3 types, which are defined as members of the sqlite3 namespace:
  /// `SQLITE_INTEGER`, `SQLITE_FLOAT`, `SQLITE_TEXT`, `SQLITE_BLOB`. Any other
  /// value, except for `undefined`, will trigger an exception. Passing
  /// `undefined` is the same as not passing a value. It is legal to, e.g.,
  /// fetch
  /// an integer value as a string, in which case sqlite3 will convert the value
  /// to a string.
  ///
  /// If the index is an array, this function behaves a differently: it assigns
  /// the indexes of the array, from 0 to the number of result columns, to the
  /// values of the corresponding result column, and returns that array:
  ///
  /// const values = stmt.get([]);
  ///
  /// This will return an array which contains one entry for each result column
  /// of the statement's current row..
  ///
  /// If the index is a plain object, this function behaves even differentlier:
  /// it assigns the properties of the object to the values of their
  /// corresponding result columns:
  ///
  /// const values = stmt.get({});
  ///
  /// This returns an object with properties named after the columns of the
  /// result set. Be aware that the ordering of the properties is undefined. If
  /// their order is important, use the array form instead.
  ///
  /// Blobs are returned as `Uint8Array` instances.
  ///
  /// Special case handling of 64-bit integers: the `Number` type is used for
  /// both floating point numbers and integers which are small enough to fit
  /// into
  /// it without loss of precision. If a larger integer is fetched, it is
  /// returned as a `BigInt` if that support is enabled, else it will throw an
  /// exception. The range of integers supported by the Number class is defined
  /// as:
  ///
  /// - `Number.MIN_SAFE_INTEGER = -9007199254740991`
  /// - `Number.MAX_SAFE_INTEGER = 9007199254740991`
  Map<String, SqlValue?> getAllNamed() {
    return (_getAllNamed(JSObject()).dartify()! as Map)
        .cast<String, SqlValue?>();
  }

  /// Equivalent to PreparedStatement#get (ndx) but coerces the result to a
  /// `Uint8Array`.
  external JSUint8Array? getBlob(int ndx);

  /// Returns the result column name of the given index, or throws if index is
  /// out of bounds or this statement has been finalized. This may be used
  /// without having run PreparedStatement#step() first.
  external String getColumnName(int ndx);

  /// If this statement potentially has result columns, this function returns an
  /// array of all such names. If passed an array, it is used as the target and
  /// all names are appended to it. Returns the target array. Throws if this
  /// statement cannot have result columns. `this.columnCount`, set with the
  /// statement is prepared, holds the number of columns.
  external JSArray<JSString> getColumnNames([JSArray<JSString?>? target]);

  /// Equivalent to PreparedStatement#get (ndx) but coerces the result to a
  /// number.
  external double? getFloat(int ndx);

  /// Equivalent to PreparedStatement#get (ndx) but coerces the result to
  /// an integral number.
  external int? getInt(int ndx);

  /// Equivalent to PreparedStatement#getString (ndx) but returns passes
  /// the result of passing the fetched string string through `JSON.parse()`. If
  /// JSON parsing throws, that exception is propagated.
  external JSAny? getJSON(int ndx);

  /// If this statement has named bindable parameters and the given name matches
  /// one, its 1-based bind index is returned. If no match is found, 0 is
  /// returned. If it has no bindable parameters, the undefined value is
  /// returned.
  external int? getParamIndex(String name);

  /// Equivalent to PreparedStatement#get (ndx) but coerces the result to a
  /// string.
  external String? getString(int ndx);

  /// Resets this statement so that it may be `step()`ed again from the
  /// beginning. Returns `this`. Throws if this statement has been finalized, if
  /// it may not legally be reset because it is currently being used from a
  /// Database#exec  callback, or (as of versions 3.42.1 and 3.43) if the
  /// underlying call to `sqlite3_reset()` returns non-0.
  ///
  /// If passed a truthy argument then PreparedStatement#clearBindings  is
  /// also called, otherwise any existing bindings, along with any memory
  /// allocated for them, are retained.
  ///
  /// In versions 3.42.0 and earlier, this function did not throw if
  /// `sqlite3_reset()` returns non-0, but it was discovered that throwing (or
  /// significant extra client-side code) is necessary in order to avoid certain
  /// silent failure scenarios
  external PreparedStatement reset([bool? alsoClearBinds]);

  /// Steps the statement one time. If the result indicates that a row of data
  /// is
  /// available, a truthy value is returned. If no row of data is available, a
  /// falsy value is returned. Throws on error.
  external bool step();

  /// Functions like PreparedStatement#step  except that it calls
  /// PreparedStatement#finalize  on this statement immediately after
  /// stepping unless the `step()` throws.
  ///
  /// On success, it returns true if the step indicated that a row of data was
  /// available, else it returns false.
  ///
  /// This is intended to simplify use cases such as:
  ///
  /// ADb.prepare('INSERT INTO foo(a) VALUES(?)').bind(123).stepFinalize();
  external bool stepFinalize();

  /// Functions exactly like PreparedStatement#step  except that...
  ///
  /// On success, it calls PreparedStatement#reset  and returns this
  /// object. On error, it throws and does not call reset().
  ///
  /// This is intended to simplify constructs like:
  ///
  /// For(...) { stmt.bind(...).stepReset(); }
  ///
  /// Note that the PreparedStatement#reset  call makes it illegal to call
  /// PreparedStatement#get  after the step.
  external PreparedStatement stepReset();
}

/// An instance of an implementing class corresponds to one `sqlite3*` created
/// using `sqlite3_open` or equivalent.
///
/// Example:
/// ```ts
///   ```typescript
///   const db = new sqlite3.DB();
///   try {
///     db.exec([
///       "create table t(a);",
///       "insert into t(a) values(10),(20),(30)"
///     ]);
///   } finally {
///     db.close();
///   }
///   ```;
/// ```
@JS('oo1.DB')
extension type Database._(JSObject _) {
  external Database._new([DatabaseOptions? options]);

  factory Database({String? filename, String? flags, String? vfs}) {
    return Database._new(
      DatabaseOptions(
        filename: filename ?? undefined, // Cannot pass `null`
        flags: flags ?? undefined,
        vfs: vfs ?? undefined,
      ),
    );
  }

  /// Filename which was passed to the constructor.
  external String filename;

  /// Resolves to the `sqlite3*` which this object wraps. This value may be
  /// passed to any WASM-bound functions which accept an `sqlite3*` argument. It
  /// resolves to `undefined` after this object is `close()`d.
  external double? pointer;

  /// Executes SQL statements and optionally collects query results and/or calls
  /// a callback for each result row.
  ///
  /// _LOTS_ of overloads on this one one, depending on:
  ///
  /// - `sql` as parameter or as option
  /// - `returnValue`:
  ///
  ///   - `"this"`: default, return database instance, use for fluent calls
  ///   - `"resultRows"`: return values of `resultRows` array (set to empty array if
  /// not set by user)
  ///   - `"saveSql"`: return values of `saveSql` option (set to empty array if not
  /// set by user)
  /// - `resultRows`:
  ///
  ///   - `"array"`: Array of column values for every result row
  ///   - `"object"`: Object mapping column names to values for every result row
  ///   - `"stmt"`: Only for use with `callback` option, pass
  /// PreparedStatement object for every row.
  ///   - `number`: Extract column with (zero-based) index from every result row
  ///   - `string`: Extract column with name from every result row, must have format
  /// `$<column>`, with `column` having at least two characters.
  ///
  /// ⚠️**ACHTUNG**⚠️: The combination of `returnValue: "resultRows"` and
  /// `rowMode: "stmt"` type checks fine, but will lead to a runtime error. This
  /// is due to a limitation in TypeScript's type system which does not allow
  /// restrictions on `string` types.
  @JS('exec')
  external JSArray<JSObject> _query(ExecOptions opts);

  @JS('exec')
  external void _exec(ExecOptions opts);

  void exec({required String sql, List<Object?> bind = const []}) {
    _exec(ExecOptions.exec(sql: sql, bind: bind));
  }

  List<Map<String, Object?>> query({
    required String sql,
    List<Object?> bind = const [],
  }) {
    final result = _query(ExecOptions.query(sql: sql, bind: bind));
    return result.toDart
        .map((e) => (e.dartify()! as Map).cast<String, Object?>())
        .toList();
  }

  /// Compiles the given SQL and returns a PreparedStatement. This is the
  /// only way to create new PreparedStatement objects. Throws on error.
  external PreparedStatement prepare(String sql);

  /// Returns true if the database handle is open, else false.
  external bool isOpen();

  /// Throws if the given DB has been closed.
  external Database affirmOpen();

  /// Finalizes all still-open statements which were opened by this object and
  /// closes this database connection. This is a no-op if the db has already
  /// been
  /// closed. After calling `close()`, pointer will resolve to
  /// `undefined`, so that can be used to check whether the db instance is still
  /// opened.
  ///
  /// If onclose.before  is a function then it is called before any
  /// close-related cleanup. If onclose.after  is a function then it is
  /// called after the db is closed but before auxiliary state like
  /// this.filename
  /// is cleared.
  ///
  /// Both onclose handlers are passed this object as their only argument. If
  /// this db is not opened, neither of the handlers are called. Any exceptions
  /// the handlers throw are ignored because "destructors must not throw."
  ///
  /// Note that garbage collection of a db handle, if it happens at all, will
  /// never trigger `close()`, so onclose handlers are not a reliable way
  /// to implement close-time cleanup or maintenance of a db.
  external JSAny? close();

  /// Returns the number of changes, as per `sqlite3_changes()` (if the first
  /// argument is `false`) or `sqlite3_total_changes()` (if it's `true`). If the
  /// 2nd argument is `true`, it uses `sqlite3_changes64()` or
  /// `sqlite3_total_changes64()`, which will trigger an exception if this build
  /// does not have `BigInt` support enabled.
  external int changes([bool? total, bool? sixtyFour]);

  /// Returns the filename associated with the given database name. Defaults to
  /// `main`. Throws if this database is `close()`d.
  external String? dbFilename([String? dbName]);

  /// Returns the name of the given 0-based db number. Defaults to `0`. Throws
  /// if
  /// this database is `close()`d.
  external String? dbName([int? dbIndex]);

  /// Returns the name of the sqlite_vfs for the given database. Defaults to
  /// `main`. Throws if this database is `close()`d.
  external String? dbVfsName([String? dbName]);

  /// Creates a new scalar, aggregate, or window function which is accessible
  /// via
  /// SQL code.
  ///
  /// When called from SQL, arguments to the UDF, and its result, will be
  /// converted between JS and SQL with as much fidelity as is feasible,
  /// triggering an exception if a type conversion cannot be determined. Some
  /// freedom is afforded to numeric conversions due to friction between the JS
  /// and C worlds: integers which are larger than 32 bits will be treated as
  /// doubles or `BigInt` values.
  ///
  /// UDFs cannot currently be removed from a DB handle after they're added.
  /// More
  /// correctly, they can be removed as documented for
  /// `sqlite3_create_function_v2()`, but doing so will "leak" the JS-created
  /// WASM binding of those functions.
  ///
  /// The first two call forms can only be used for creating scalar functions.
  /// Creating an aggregate or window function requires the options-object form,
  /// as described below.
  external Database createFunction(String name, JSFunction func);

  /// Prepares the given SQL, `step()`s it one time, and returns an array
  /// containing the values of the first result row. If it has no results,
  /// `undefined` is returned. If passed a second argument other than
  /// `undefined`, it is treated like an argument to
  /// PreparedStatement#bind , so may be any type supported by that
  /// function. Throws on error.
  external JSArray<SqlValue?>? selectArray(String sql, [BindingSpec? bind]);

  /// Runs the given SQL and returns an array of all results, with each row
  /// represented as an array, as per the `'array'` `rowMode` option to
  /// Database#exec . An empty result set resolves to an empty array. The
  /// second argument, if any, is treated as the `bind` option to a call to
  /// `exec()`. Throws on error.
  external JSArray<JSArray<SqlValue?>> selectArrays(
    String sql, [
    BindingSpec? bind,
  ]);

  /// Prepares the given SQL, `step()`s it one time, and returns an object
  /// containing the key/value pairs of the first result row. If it has no
  /// results, `undefined` is returned. Note that the order of returned object's
  /// keys is not guaranteed to be the same as the order of the fields in the
  /// query string. If passed a second argument other than undefined, it is
  /// treated like an argument to Stmt.bind(), so may be any type supported by
  /// that function. Throws on error.
  external JSObject? selectObject(String sql, [BindingSpec? bind]);

  /// Works identically to Database#selectArrays  except that each value in
  /// the returned array is an object, as per the `"object"` rowMode option to
  /// Database#exec .
  external JSArray<JSObject> selectObjects(String sql, [BindingSpec? bind]);

  /// Prepares the given SQL, `step()`s the resulting PreparedStatement
  /// one time, and returns the value of the first result column. If it has no
  /// results, `undefined` is returned. If passed a second argument, it is
  /// treated like an argument to PreparedStatement#bind , so may be any
  /// type supported by that function. Passing the `undefined` value is the same
  /// as passing no value, which is useful when... If passed a 3rd argument, it
  /// is expected to be one of the `SQLITE_{typename}` constants. Passing the
  /// `undefined` value is the same as not passing a value. Throws on error
  /// (e.g.
  /// malformed SQL).
  external SqlValue? selectValue(String sql, BindingSpec? bind);

  /// Runs the given query and returns an array of the values from the first
  /// result column of each row of the result set. The 2nd argument is an
  /// optional value for use in a single-argument call to
  /// PreparedStatement#bind . The 3rd argument may be any value suitable
  /// for use as the 2nd argument to PreparedStatement#get . If a 3rd
  /// argument is desired but no bind data are needed, pass `undefined` for the
  /// 2nd argument. If there are no result rows, an empty array is returned.
  external JSArray<SqlValue?> selectValues(String sql, [BindingSpec? bind]);

  /// Returns the number of currently-opened PreparedStatement handles for
  /// this db handle, or 0 if this object is `close()`d. Note that only handles
  /// prepared via Database#prepare  are counted, and not handles prepared
  /// using `capi.sqlite3_prepare_v3()` (or equivalent).
  external double openStatementCount();

  /// Starts a transaction, calls the given `callback`, and then either rolls
  /// back or commits the transaction, depending on whether the `callback`
  /// throws. The `callback` is passed this object as its only argument. On
  /// success, returns the result of the callback. Throws on error.
  ///
  /// Note that transactions may not be nested, so this will throw if it is
  /// called recursively. For nested transactions, use the
  /// Database#savepoint  method or manually manage `SAVEPOINT`s using
  /// Database#exec .
  ///
  /// If called with 2 arguments, the first must be a keyword which is legal
  /// immediately after a `BEGIN` statement, e.g. one of `"DEFERRED"`,
  /// `"IMMEDIATE"`, or `"EXCLUSIVE"`. Though the exact list of supported
  /// keywords is not hard-coded here, in order to be future-compatible, if the
  /// argument does not look like a single keyword then an exception is
  /// triggered
  /// with a description of the problem.
  @JS('transaction')
  external void _transaction$1(
    BeginQualifier beginQualifier,
    JSFunction callback,
  );
  @JS('transaction')
  external void _transaction(JSFunction callback);

  void transaction(
    void Function(Database db) callback, {
    BeginQualifier? beginQualifier,
  }) {
    if (beginQualifier != null) {
      _transaction$1(beginQualifier, callback.toJS);
    } else {
      _transaction(callback.toJS);
    }
  }

  @JS('getAutocommit')
  external int _getAutocommit();

  bool get autocommit => _getAutocommit() != 0;

  external JSBigInt lastInsertRowid();
}

extension type const JSStorageMode._(String _) implements String {
  static const JSStorageMode local = JSStorageMode._('local');
  static const JSStorageMode session = JSStorageMode._('session');
}

/// SQLite3 database backed by `localStorage` or `sessionStorage`.
///
/// When the sqlite3 API is installed in the main thread, the this class is
/// added, which simplifies usage of the kvvfs.
@JS('oo1.JsStorageDb')
extension type JsStorageDb._(JSObject _) implements Database {
  external JsStorageDb(JSStorageMode mode);

  /// Returns an _estimate_ of how many bytes of storage are used by the kvvfs.
  external double storageSize();

  /// Clears all kvvfs-owned state and returns the number of records it deleted
  /// (one record per database page).
  external double clearStorage();
}

/// SQLite3 database backed by the Origin Private File System API.
///
/// Installed in the namespace only if OPFS VFS support is active.
///
/// This support is only available when sqlite3.js is loaded from a Worker
/// thread, whether it's loaded in its own dedicated worker or in a worker
/// together with client code. This OPFS wrapper implements an `sqlite3_vfs`
/// wrapper entirely in JavaScript.
///
/// This feature is activated automatically if the browser appears to have the
/// necessary APIs to support it. It can be tested for in JS code using one
/// of:
///
/// If(sqlite3.capi.sqlite3_vfs_find("opfs")){ ... OPFS VFS is available ... }
/// // Alternately: if(sqlite3.oo1.OpfsDb){ ... OPFS VFS is available ... }
///
/// If it is available, the VFS named `"opfs"` can be used with any sqlite3
/// APIs
/// which accept a VFS name, such as `sqlite3_vfs_find()`,
/// `sqlite3_db_open_v2()`, and the `sqlite3.oo1.DB` constructor, noting that
/// OpfsDb  is a convenience subclass of Database which
/// automatically uses this VFS. For URI-style names, use
/// `file:my.db?vfs=opfs`.
///
/// ## ⚠️Achtung: Safari versions < 17:
///
/// Safari versions less than version 17 are incompatible with the current
/// OPFS
/// VFS implementation because of a bug in storage handling from sub-workers.
/// There is no workaround for that - supporting it will require a separate
/// VFS
/// implementation and we do not, as of July 2023, have an expected time frame
/// for its release. Both the `SharedAccessHandle` pool VFS and the WASMFS
/// support offers alternatives which should work with Safari versions 16.4 or
/// higher.
///
/// ## ⚠️Achtung: COOP and COEP HTTP Headers
///
/// In order to offer some level of transparent concurrent-db-access support,
/// JavaScript's SharedArrayBuffer type is required for the OPFS VFS, and that
/// class is only available if the web server includes the so-called COOP and
/// COEP response headers when delivering scripts:
///
/// Cross-Origin-Embedder-Policy: require-corp
/// Cross-Origin-Opener-Policy: same-origin
///
/// Without these headers, the `SharedArrayBuffer` will not be available, so
/// the
/// OPFS VFS will not load. That class is required in order to coordinate
/// communication between the synchronous and asynchronous parts of the
/// `sqlite3_vfs` OPFS proxy.
///
/// The COEP header may also have a value of `credentialless`, but whether or
/// not
/// that will work in the context of any given application depends on how it
/// uses
/// other remote assets.
///
/// How to emit those headers depends on the underlying web server.
@JS('oo1.OpfsDb')
extension type OpfsDatabase._(JSObject _) implements Database {
  external OpfsDatabase(String filename, String flags);

  /// Import a database into OPFS storage. It only works with database files and
  /// will throw if passed a different file type.
  external static JSPromise<JSNumber> importDb(
    JSString filename,
    JSUint8Array data,
  );
}

/// Options for configuring the SAH Pool VFS
extension type SAHPoolOptions._(JSObject _) implements JSObject {
  external factory SAHPoolOptions({
    bool? clearOnInit,
    int? initialCapacity,
    String? directory,
    String? name,
  });

  /// If truthy (default=false) contents and filename mapping are removed from
  /// each SAH it is acquired during initalization of the VFS, leaving the
  /// VFS's storage in a pristine state. Use this only for databases which need
  /// not survive a page reload.
  external bool? clearOnInit;

  /// (default=6) Specifies the default capacity of the VFS.
  ///
  /// This should not be set unduly high because the VFS has to open (and keep
  /// open) a file for each entry in the pool. This setting only has an effect
  /// when the pool is initially empty. It does not have any effect if a pool
  /// already exists. Note that this number needs to be at least twice the
  /// number of expected database files (to account for journal files) and may
  /// need to be even higher than three times the number of databases plus one,
  /// depending on the value of the `TEMP_STORE` pragma and how the databases
  /// are used.
  external int? initialCapacity;

  /// (default="."+options.name) Specifies the OPFS directory name in which to
  /// store metadata for the VFS.
  ///
  /// Only one instance of this VFS can use the same directory concurrently.
  /// Using a different directory name for each application enables different
  /// engines in the same HTTP origin to co-exist, but their data are invisible
  /// to each other. Changing this name will effectively orphan any databases
  /// stored under previous names. This option may contain multiple path
  /// elements, e.g. "/foo/bar/baz", and they are created automatically. In
  /// practice there should be no driving need to change this.
  ///
  /// **ACHTUNG:** all files in this directory are assumed to be managed by the
  /// VFS. Do not place other files in this directory, as they may be deleted
  /// or otherwise modified by the VFS.
  external String? directory;

  /// (default="opfs-sahpool") sets the name to register this VFS under.
  ///
  /// Normally this should not be changed, but it is possible to register this
  /// VFS under multiple names so long as each has its own separate directory
  /// to work from. The storage for each is invisible to all others. The name
  /// must be a string compatible with `sqlite3_vfs_register()` and friends and
  /// suitable for use in URI-style database file names.
  ///
  /// **ACHTUNG:** if a custom name is provided, a custom directory must also
  /// be provided if any other instance is registered with the default
  /// directory. No two instances may use the same directory. If no directory
  /// is explicitly provided then a directory name is synthesized from the name
  /// option.
  external String? name;
}

/// Shared Access Handle (SAH) Pool utility for managing OPFS databases.
///
/// This provides advanced database management capabilities including:
/// - Listing all databases in OPFS storage
/// - Importing and exporting database files
/// - Managing storage capacity and cleanup
/// - File lifecycle management
///
/// This is the recommended interface for applications that need to manage
/// multiple databases and their lifecycle in OPFS storage.
extension type SAHPoolUtil._(JSObject _) implements JSObject {
  @JS('addCapacity')
  external JSPromise<JSNumber> _addCapacity(int numEntries);

  /// Adds `numEntries` entries to the current pool.
  ///
  /// This change is persistent across sessions so should not be called
  /// automatically at each app startup (but see `reserveMinimumCapacity()`). Its
  /// returned Promise resolves to the new capacity. Because this operation is
  /// necessarily asynchronous, the C-level VFS API cannot call this on its own
  /// as needed.
  Future<int> addCapacity(int numEntries) async {
    final jsResult = await _addCapacity(numEntries).toDart;
    return jsResult.toDartInt;
  }

  @JS('reduceCapacity')
  external JSPromise<JSNumber> _reduceCapacity(int numEntries);

  /// Removes up to [numEntries] entries from the pool, with the caveat that it
  /// can only remove currently-unused entries.
  ///
  /// It returns a Promise which resolves to the number of entries actually
  /// removed.
  Future<int> reduceCapacity(int numEntries) async {
    final jsResult = await _reduceCapacity(numEntries).toDart;
    return jsResult.toDartInt;
  }

  @JS('exportFile')
  external JSUint8Array _exportFile(String filename);

  @JS('reserveMinimumCapacity')
  external JSPromise<JSNumber> _reserveMinimumCapacity(int minCapacity);

  /// If the current capacity is less than [minCapacity], the capacity is
  /// increased to [minCapacity], else this returns with no side effects.
  ///
  /// The resulting Promise resolves to the new capacity.
  Future<int> reserveMinimumCapacity(int minCapacity) async {
    final jsResult = await _reserveMinimumCapacity(minCapacity).toDart;
    return jsResult.toDartInt;
  }

  @JS('getCapacity')
  external int _getCapacity();

  /// Returns the number of files currently contained in the SAH pool.
  ///
  /// The default capacity is only large enough for one or two databases and
  /// their associated temp files.
  int get capacity => _getCapacity();

  /// Synchronously reads the contents of the given file into a [JSUint8Array] and
  /// returns it.
  ///
  /// This will throw if the given name is not currently in active use or on I/O
  /// error. Note that the given name is not visible directly in OPFS (or, if it
  /// is, it's not from this VFS). The reason for that is that this VFS manages
  /// name-to-file mappings in a roundabout way in order to maintain its list of
  /// SAHs.
  Uint8List exportFile(String filename) {
    return _exportFile(filename).toDart;
  }

  @JS('getFileCount')
  external int _getFileCount();

  /// Returns the number of files from the pool currently allocated to VFS slots.
  ///
  /// This is not the same as the files being "opened".
  int get fileCount => _getFileCount();

  @JS('getFileNames')
  external JSArray<JSString> _getFileNames();

  /// Returns an array of the names of the files currently allocated to VFS
  /// slots.
  ///
  /// This list is the same length as [fileCount].
  List<String> get fileNames =>
      _getFileNames().toDart.map((jsString) => jsString.toDart).toList();

  @JS('importDb')
  external JSNumber _importDb(String name, JSUint8Array data);

  /// Imports the contents of an SQLite database, provided as a byte array or
  /// ArrayBuffer, under the given name, overwriting any existing content.
  ///
  /// Throws if the pool has no available file slots, on I/O error, or if the
  /// input does not appear to be a database. In the latter case, only a cursory
  /// examination is made.
  ///
  /// Note that this routine is only for importing database files, not arbitrary
  /// files, the reason being that this VFS will automatically clean up any
  /// non-database files so importing them is pointless.
  ///
  /// If passed a function for its second argument, its behavior changes to
  /// asynchronous, and it imports its data in chunks fed to it by the given
  /// callback function. It calls the callback (which may be async) repeatedly,
  /// expecting either a Uint8Array or ArrayBuffer (to denote new input) or
  /// undefined (to denote EOF).
  ///
  /// For so long as the callback continues to return non-undefined, it will
  /// append incoming data to the given VFS-hosted database file. The result of
  /// the resolved Promise when called this way is the size of the resulting
  /// database.
  ///
  /// On success, the number of bytes written is returned. On success this
  /// routine rewrites the database header bytes in the output file (not the
  /// input array) to force disabling of WAL mode.
  ///
  /// On a write error, the handle is removed from the pool and made available
  /// for re-use.
  int importDb(String name, Uint8List data) {
    final jsResult = _importDb(name, data.toJS);
    return jsResult.toDartInt;
  }

  /// If a virtual file exists with the given name, disassociates it from the
  /// pool and returns true, else returns false without side effects. Results are
  /// undefined if the file is currently in active use. Recall that names need to
  /// use absolute paths (starting with a slash).
  external bool unlink(String filename);

  @JS('wipeFiles')
  external JSPromise<JSAny?> _wipeFiles();

  /// Clears all client-defined state of all SAHs and makes all of them available
  /// for re-use by the pool. Results are undefined if any such handles are
  /// currently in use, e.g. by an sqlite3 db.
  Future<void> wipeFiles() async {
    await _wipeFiles().toDart;
  }

  @JS('removeVfs')
  external JSPromise<JSBoolean> _removeVfs();

  /// Unregisters the VFS and removes its directory from OPFS (which means all
  /// client content is destroyed). After calling this, the VFS may no longer be
  /// used and there is currently no way to re-add it aside from reloading the
  /// current JavaScript context.
  ///
  /// Results are undefined if a database is currently in use with this VFS.
  ///
  /// The returned Promise resolves to true if it performed the removal and false
  /// if the VFS was not installed.
  ///
  /// If the VFS has a multi-level directory, e.g. "/foo/bar/baz", only the
  /// bottom-most directory is removed because this VFS cannot know for certain
  /// whether the higher-level directories contain data which should be removed.
  Future<bool> removeVfs() async {
    final jsResult = await _removeVfs().toDart;
    return jsResult.toDart;
  }

  /// The SQLite VFS name under which this pool's VFS is registered.
  external String get vfsName;

  /// The constructor for [OpfsSAHPoolDatabase] instances.
  external JSFunction get OpfsSAHPoolDb;

  /// Open a database from the pool.
  OpfsSAHPoolDatabase openDatabase(String filename) {
    return OpfsSAHPoolDb.callAsConstructor(filename.toJS);
  }
}

extension type OpfsSAHPoolDatabase._(JSObject _) implements Database {}

/// Install the OPFS SAH Pool VFS and return the utility object
@JS('installOpfsSAHPoolVfs')
external JSPromise<SAHPoolUtil> _installOpfsSAHPoolVfs([
  SAHPoolOptions? options,
]);

/// Global SAH Pool utility instance (cached after first initialization)
SAHPoolUtil? _globalSAHPool;

/// Get or initialize the global SAH Pool utility
Future<SAHPoolUtil> getSAHPoolUtil({
  String? name,
  bool? clearOnInit,
  int? initialCapacity,
}) async {
  if (_globalSAHPool case final globalSAHPool?) {
    return globalSAHPool;
  }

  final Logger logger = Logger('SAHPool');
  logger.info('Initializing SAH Pool VFS...');

  final globalSAHPool = await _installOpfsSAHPoolVfs(
    SAHPoolOptions(
      name: name ?? 'default',
      clearOnInit: clearOnInit ?? false,
      initialCapacity: initialCapacity,
    ),
  ).toDart;

  logger.info(
    'SAH Pool VFS initialized with VFS name: ${globalSAHPool.vfsName}',
  );
  logger.info('Pool capacity: ${globalSAHPool.capacity}');
  logger.info('Existing databases: ${globalSAHPool.fileNames.join(', ')}');

  return _globalSAHPool = globalSAHPool;
}

/// Exception class for reporting WASM-side allocation errors.
@JS('WasmAllocError')
extension type WasmAllocError._(JSObject _) implements JSError {
  external WasmAllocError(String message);

  external JSAny? toss;
}

/// Exception class used primarily by the oo1 API.
@JS('SQLite3Error')
extension type SQLite3Error._(JSObject _) implements JSError {
  external SQLite3Error(String message);

  external int resultCode;
}

extension type InitOptions._(JSObject _) implements JSObject {
  external factory InitOptions._create({
    JSFunction? locateFile,
    JSFunction? print,
    JSFunction? printErr,
  });

  factory InitOptions({
    String Function(String path, String prefix)? locateFile,
    void Function(String msg)? print,
    void Function(String msg)? printErr,
  }) {
    return InitOptions._create(
      locateFile: locateFile?.toJS,
      print: print?.toJS,
      printErr: printErr?.toJS,
    );
  }
}
