import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

// ignore: implementation_imports
import 'package:aws_common/src/js/indexed_db.dart' as self show indexedDB;
// ignore: implementation_imports
import 'package:aws_common/src/js/indexed_db.dart' hide indexedDB;
import '../workers/indexed_db_worker.dart';
import 'package:logging/logging.dart';
import 'package:web/web.dart' as web;

final IndexedDB indexedDB = IndexedDB._();

/// Utility class for IndexedDB storage operations
class IndexedDB {
  static const String _dbName = 'embedding_explorer_db';
  static const String _storeName = 'configurations';
  static const int _dbVersion = 1;
  static const String _keyPrefix = 'embedding_explorer_';
  static final Logger _logger = Logger('IndexedDB');

  IndexedDB._();

  web.IDBDatabase? _database;
  bool _isInitialized = false;
  bool get debugIsInitialized => _isInitialized;

  late final IndexedDB worker = _IndexedDbWorker();

  /// Initialize the IndexedDB database
  Future<void> initialize() async {
    if (_isInitialized) return;

    final request = self.indexedDB!.open(_dbName, _dbVersion);

    try {
      request.addEventListener(
        'upgradeneeded',
        (web.IDBVersionChangeEvent event) {
          final target = event.target as web.IDBOpenDBRequest;
          final db = target.result as web.IDBDatabase;

          // Create object store if it doesn't exist
          if (!db.objectStoreNames.contains(_storeName)) {
            db.createObjectStore(_storeName);
          }
        }.toJS,
      );

      final result = await request.future.timeout(Duration(seconds: 10));
      if (!result.isA<web.IDBDatabase>()) {
        throw StateError('Failed to open IndexedDB');
      }
      _isInitialized = true;
      _database = result as web.IDBDatabase;
    } catch (e) {
      _logger.severe('Error opening IndexedDB', request.error?.message ?? e);
      _isInitialized = false;
      rethrow;
    }
  }

  /// Ensure the database is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _database == null) {
      await initialize();
    }
  }

  /// Get a value from IndexedDB
  Future<String?> getValue(String key) async {
    await _ensureInitialized();

    final transaction = _database!.transaction(_storeName.toJS, 'readonly');
    final store = transaction.objectStore(_storeName);
    final request = store.get((_keyPrefix + key).toJS);

    try {
      final result = await request.future.timeout(Duration(seconds: 5));
      final value = result.dartify();
      return value?.toString();
    } catch (e) {
      _logger.severe(
        'Error reading $key from IndexedDB',
        request.error?.message ?? e,
      );
      rethrow;
    }
  }

  /// Set a value in IndexedDB
  Future<void> setValue(String key, String value) async {
    await _ensureInitialized();

    final transaction = _database!.transaction(_storeName.toJS, 'readwrite');
    final store = transaction.objectStore(_storeName);
    final request = store.put(value.toJS, (_keyPrefix + key).toJS);

    try {
      await request.future.timeout(Duration(seconds: 5));
    } catch (e) {
      _logger.severe(
        'Error writing $key to IndexedDB',
        request.error?.message ?? e,
      );
      rethrow;
    }
  }

  /// Remove a value from IndexedDB
  Future<void> removeValue(String key) async {
    await _ensureInitialized();

    final transaction = _database!.transaction(_storeName.toJS, 'readwrite');
    final store = transaction.objectStore(_storeName);
    final request = store.delete((_keyPrefix + key).toJS);

    try {
      await request.future.timeout(Duration(seconds: 5));
    } catch (e) {
      _logger.severe(
        'Error removing $key from IndexedDB',
        request.error?.message ?? e,
      );
      rethrow;
    }
  }

  /// Check if a key exists in IndexedDB
  Future<bool> hasKey(String key) async {
    final value = await getValue(key);
    return value != null;
  }

  /// Clear all storage for this application
  Future<void> clearAll() async {
    await _ensureInitialized();

    final transaction = _database!.transaction(_storeName.toJS, 'readwrite');
    final store = transaction.objectStore(_storeName);

    try {
      // Get all keys first
      final keysRequest = store.getAllKeys();
      final keysResult = await keysRequest.future.timeout(Duration(seconds: 5));
      final keys = keysResult as JSArray<JSString>;

      // Delete keys that start with our prefix
      final futures = <Future<void>>[];
      for (int i = 0; i < keys.length; i++) {
        final key = keys[i].toDart;
        if (key.startsWith(_keyPrefix)) {
          final deleteRequest = store.delete(key.toJS);
          futures.add(deleteRequest.future.timeout(Duration(seconds: 5)));
        }
      }

      await Future.wait(futures);
    } catch (e) {
      _logger.severe('Error clearing IndexedDB', e);
      rethrow;
    }
  }

  /// Get all keys for this application
  Future<List<String>> getAllKeys() async {
    await _ensureInitialized();

    final transaction = _database!.transaction(_storeName.toJS, 'readonly');
    final store = transaction.objectStore(_storeName);
    final request = store.getAllKeys();

    try {
      final result = await request.future.timeout(Duration(seconds: 5));
      final keys = <String>[];
      final jsKeys = result as JSArray;

      for (int i = 0; i < jsKeys.length; i++) {
        final key = jsKeys[i].toString();
        if (key.startsWith(_keyPrefix)) {
          keys.add(key.substring(_keyPrefix.length));
        }
      }

      return keys;
    } catch (e) {
      _logger.severe('Error getting keys from IndexedDB', e);
      rethrow;
    }
  }

  /// Get the approximate size of stored data
  Future<int> getStorageSize() async {
    await _ensureInitialized();

    try {
      final keys = await getAllKeys();
      int totalSize = 0;

      for (final key in keys) {
        final value = await getValue(key);
        if (value != null) {
          totalSize += key.length + value.length;
        }
      }

      return totalSize;
    } catch (e) {
      _logger.severe('Error calculating storage size', e);
      return 0;
    }
  }

  Future<void> close() async {
    _database?.close();
    _database = null;
    _isInitialized = false;
  }
}

final class _IndexedDbWorker implements IndexedDB {
  IndexedDbWorker? _worker;
  static final Logger _logger = Logger('IndexedDB.Worker');

  static var _nextRequestId = 1;

  @override
  web.IDBDatabase? _database;

  @override
  bool _isInitialized = false;

  @override
  bool get debugIsInitialized => _isInitialized;

  @override
  IndexedDB get worker => this;

  @override
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _worker = IndexedDbWorker.create();
    _worker!.logs.listen((entry) {
      _logger.log(Level.FINEST, entry.message, entry.error, entry.stackTrace);
    });
    await _worker!.spawn();
    _isInitialized = true;
  }

  @override
  Future<void> clearAll() async {
    await _ensureInitialized();
    final request = IndexedDbRequest(
      requestId: _nextRequestId++,
      type: IndexedDbRequestType.clear,
    );
    _worker!.add(request);
    await _worker!.stream.firstWhere(
      (response) => response.requestId == request.requestId,
    );
  }

  @override
  Future<List<String>> getAllKeys() async {
    await _ensureInitialized();
    final request = IndexedDbRequest(
      requestId: _nextRequestId++,
      type: IndexedDbRequestType.getAllKeys,
    );
    _worker!.add(request);
    final response = await _worker!.stream.firstWhere(
      (response) => response.requestId == request.requestId,
    );
    return (jsonDecode(response.value!) as List).cast<String>();
  }

  @override
  Future<int> getStorageSize() async {
    await _ensureInitialized();
    final request = IndexedDbRequest(
      requestId: _nextRequestId++,
      type: IndexedDbRequestType.getStorageSize,
    );
    _worker!.add(request);
    final response = await _worker!.stream.firstWhere(
      (response) => response.requestId == request.requestId,
    );
    return int.parse(response.value!);
  }

  @override
  Future<String?> getValue(String key) async {
    await _ensureInitialized();
    final request = IndexedDbRequest(
      requestId: _nextRequestId++,
      type: IndexedDbRequestType.get,
      key: key,
    );
    _worker!.add(request);
    final response = await _worker!.stream.firstWhere(
      (response) => response.requestId == request.requestId,
    );
    return response.value;
  }

  @override
  Future<bool> hasKey(String key) async {
    await _ensureInitialized();
    final request = IndexedDbRequest(
      requestId: _nextRequestId++,
      type: IndexedDbRequestType.exists,
      key: key,
    );
    _worker!.add(request);
    final response = await _worker!.stream.firstWhere(
      (response) => response.requestId == request.requestId,
    );
    return response.value == 'true';
  }

  @override
  Future<void> removeValue(String key) async {
    await _ensureInitialized();
    final request = IndexedDbRequest(
      requestId: _nextRequestId++,
      type: IndexedDbRequestType.delete,
      key: key,
    );
    _worker!.add(request);
    await _worker!.stream.firstWhere(
      (response) => response.requestId == request.requestId,
    );
  }

  @override
  Future<void> setValue(String key, String value) async {
    await _ensureInitialized();
    final request = IndexedDbRequest(
      requestId: _nextRequestId++,
      type: IndexedDbRequestType.set,
      key: key,
      value: value,
    );
    _worker!.add(request);
    await _worker!.stream.firstWhere(
      (response) => response.requestId == request.requestId,
    );
  }

  @override
  Future<void> close() async {
    await _worker?.close();
    _worker = null;
    _isInitialized = false;
  }
}
