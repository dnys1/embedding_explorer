import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../util/type_id.dart';
import '../service/configuration_service.dart';
import 'configuration_item.dart';

/// Base class for managing collections of configurations
abstract class ConfigurationCollection<T extends ConfigurationItem>
    with ChangeNotifier {
  ConfigurationCollection(this.configService);

  final Map<String, T> _items = {};

  static final Logger _logger = Logger('ConfigurationCollection');

  final ConfigurationService configService;

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
  Future<void> add(T item) async {
    _items[item.id] = item;
    notifyListeners();
    await saveItem(item.id, item);
  }

  /// Remove a configuration
  Future<bool> remove(String id) async {
    final removed = _items.remove(id);
    if (removed != null) {
      notifyListeners();
      await removeItem(removed);
      return true;
    }
    return false;
  }

  /// Clear all configurations
  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await configService.database.execute('DELETE FROM $tableName');
  }

  /// Generate a unique ID for a new configuration
  String generateId() {
    return typeId(prefix);
  }

  /// Load configurations from database
  Future<void> loadFromStorage() async {
    try {
      final items = await loadAllItems();
      _items.clear();
      for (final item in items) {
        final id = item.id;
        _items[id] = item;
      }
      notifyListeners();
    } catch (e) {
      _logger.severe('Error loading configurations from storage', e);
    }
  }

  /// The prefix for generating IDs
  String get prefix;

  /// The name of the data table.
  String get tableName;

  /// Save a single item to the database
  @protected
  Future<void> saveItem(String id, T item);

  /// Load a single item from the database
  @protected
  Future<T?> loadItem(String id);

  /// Load all items from the database
  @protected
  Future<List<T>> loadAllItems();

  /// Remove a single item from the database
  @protected
  Future<void> removeItem(T item);

  Logger get logger => Logger('ConfigurationCollection.$tableName');
}
