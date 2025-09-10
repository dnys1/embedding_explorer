import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../utils/indexed_db.dart';

/// Base class for managing collections of configurations
abstract class ConfigurationCollection<T> with ChangeNotifier {
  final Map<String, T> _items = {};

  static final Logger _logger = Logger('ConfigurationCollection');

  /// Get all configuration items
  Map<String, T> get items => Map.unmodifiable(_items);

  /// Get a specific configuration by ID
  T? getById(String id) => _items[id];

  /// Get all configuration IDs
  List<String> get ids => _items.keys.toList();

  /// Get all configurations as a list
  List<T> get all => _items.values.toList();

  /// Check if a configuration exists
  bool contains(String id) => _items.containsKey(id);

  /// Get the count of configurations
  int get length => _items.length;

  /// Add or update a configuration
  void set(String id, T item) {
    _items[id] = item;
    notifyListeners();
    _saveToStorage();
  }

  /// Remove a configuration
  bool remove(String id) {
    final removed = _items.remove(id);
    if (removed != null) {
      notifyListeners();
      _saveToStorage();
      return true;
    }
    return false;
  }

  /// Clear all configurations
  void clear() {
    _items.clear();
    notifyListeners();
    _saveToStorage();
  }

  /// Generate a unique ID for a new configuration
  String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    var counter = 1;
    String id;
    do {
      id = '${prefix}_${timestamp}_$counter';
      counter++;
    } while (_items.containsKey(id));
    return id;
  }

  /// Load configurations from local storage
  Future<void> loadFromStorage() async {
    try {
      final jsonString = await _getStorageValue();
      if (jsonString != null) {
        final Map<String, dynamic> data =
            jsonDecode(jsonString) as Map<String, dynamic>;
        _items.clear();
        for (final entry in data.entries) {
          final item = fromJson(entry.value as Map<String, dynamic>);
          if (item != null) {
            _items[entry.key] = item;
          }
        }
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error loading configurations from storage', e);
    }
  }

  /// Save configurations to local storage
  Future<void> _saveToStorage() async {
    try {
      final data = <String, dynamic>{};
      for (final entry in _items.entries) {
        data[entry.key] = toJson(entry.value);
      }
      await _setStorageValue(jsonEncode(data));
    } catch (e) {
      _logger.severe('Error saving configurations to storage', e);
    }
  }

  /// The prefix for generating IDs
  String get prefix;

  /// The storage key for this collection
  String get storageKey;

  /// Convert an item to JSON
  Map<String, dynamic> toJson(T item);

  /// Convert JSON to an item
  T? fromJson(Map<String, dynamic> json);

  /// Get value from storage (to be implemented with actual storage mechanism)
  Future<String?> _getStorageValue() async {
    return indexedDB.getValue(storageKey);
  }

  /// Set value in storage (to be implemented with actual storage mechanism)
  Future<void> _setStorageValue(String value) async {
    await indexedDB.setValue(storageKey, value);
  }
}
