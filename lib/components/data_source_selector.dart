import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../models/data_sources/csv_data_source.dart';
import '../models/data_sources/data_source.dart';
import '../models/data_sources/sqlite_data_source.dart';
import 'data_preview.dart';

/// Data source type enumeration for the UI
enum DataSourceType {
  csv('CSV File', 'Upload and parse comma-separated values files'),
  sqlite(
    'SQLite Database',
    'Upload SQLite database files or create in-memory databases',
  );

  const DataSourceType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// A component for selecting and configuring data sources
class DataSourceSelector extends StatefulComponent {
  final void Function(DataSource dataSource)? onDataSourceSelected;
  final void Function(String message)? onError;
  final DataSource? initialDataSource;

  const DataSourceSelector({
    this.onDataSourceSelected,
    this.onError,
    this.initialDataSource,
    super.key,
  });

  @override
  State<DataSourceSelector> createState() => _DataSourceSelectorState();
}

class _DataSourceSelectorState extends State<DataSourceSelector> {
  DataSourceType _selectedType = DataSourceType.csv;
  DataSource? _currentDataSource;
  bool _isLoading = false;
  String? _error;
  String? _dataSourceName;

  // CSV configuration
  String _csvDelimiter = ',';
  bool _csvHasHeader = true;
  web.File? _selectedFile;

  // SQLite configuration
  String _sqliteType = 'sample'; // 'sample', 'upload'
  bool _sqlitePersistent = false;
  String _sqlitePersistentName = '';
  String? _selectedTable;
  List<String> _availableTables = [];

  @override
  void initState() {
    super.initState();
    _loadInitialDataSource();
  }

  Future<void> _loadInitialDataSource() async {
    final initialDataSource = component.initialDataSource;
    if (initialDataSource == null) {
      return;
    }
    _isLoading = true;
    try {
      _currentDataSource = initialDataSource;
      _selectedType = DataSourceType.values.byName(initialDataSource.type);
      _dataSourceName = initialDataSource.name;
      await initialDataSource.connect();
    } catch (e) {
      component.onError?.call('Failed to load initial data source: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'max-w-4xl mx-auto p-6 space-y-6', [
      _buildTypeSelector(),
      _buildConfigurationPanel(),
      if (!_isLoading && _currentDataSource != null) _buildPreviewSection(),
    ]);
  }

  Component _buildTypeSelector() {
    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-neutral-200 p-6',
      [
        h2(classes: 'text-xl font-semibold text-neutral-900 mb-4', [
          text('Choose Data Source Type'),
        ]),
        div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
          for (final type in DataSourceType.values) _buildTypeCard(type),
        ]),
      ],
    );
  }

  Component _buildTypeCard(DataSourceType type) {
    final isSelected = _selectedType == type;

    return div(
      classes: [
        'relative rounded-lg border-2 p-4 cursor-pointer transition-all duration-200',
        if (isSelected)
          'border-primary-500 bg-primary-50'
        else
          'border-neutral-200 hover:border-neutral-300 hover:bg-neutral-50',
      ].join(' '),
      events: {'click': (_) => _selectType(type)},
      [
        div(classes: 'flex items-start space-x-3', [
          div(classes: 'flex-shrink-0 mt-1', [
            div(
              classes: [
                'w-4 h-4 rounded-full border-2 transition-all duration-200',
                if (isSelected)
                  'border-primary-500 bg-primary-500'
                else
                  'border-neutral-300',
              ].join(' '),
              [
                if (isSelected)
                  div(
                    classes: 'w-2 h-2 bg-white rounded-full m-auto mt-0.5',
                    [],
                  ),
              ],
            ),
          ]),
          div(classes: 'flex-1', [
            h3(
              classes: [
                'text-lg font-medium transition-colors duration-200',
                if (isSelected) 'text-primary-900' else 'text-neutral-900',
              ].join(' '),
              [text(type.displayName)],
            ),
            p(
              classes: [
                'text-sm mt-1 transition-colors duration-200',
                if (isSelected) 'text-primary-700' else 'text-neutral-500',
              ].join(' '),
              [text(type.description)],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildConfigurationPanel() {
    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-neutral-200 p-6',
      [
        h2(classes: 'text-xl font-semibold text-neutral-900 mb-4', [
          text('Configuration'),
        ]),
        // Name input field (common for all data source types)
        div(classes: 'mb-6 space-y-2', [
          label(classes: 'block text-sm font-medium text-neutral-700', [
            text('Data Source Name *'),
          ]),
          input(
            type: InputType.text,
            attributes: {
              'placeholder': 'Enter a name for this data source',
              'value': _dataSourceName ?? '',
            },
            classes:
                'block w-full px-3 py-2 border border-neutral-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500',
            events: {
              'input': (event) {
                setState(() {
                  _dataSourceName =
                      (event.target as web.HTMLInputElement).value;
                });
              },
            },
          ),
        ]),
        if (_selectedType == DataSourceType.csv)
          _buildCsvConfiguration()
        else
          _buildSqliteConfiguration(),
      ],
    );
  }

  Component _buildCsvConfiguration() {
    return div(classes: 'space-y-6', [
      // File upload
      div(classes: 'space-y-2', [
        label(classes: 'block text-sm font-medium text-neutral-700', [
          text('CSV File'),
        ]),
        div(classes: 'relative', [
          input(
            type: InputType.file,
            attributes: {'accept': '.csv,.txt'},
            classes:
                'block w-full px-3 py-2 border border-neutral-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500',
            id: 'csv-file-input',
            events: {'change': (event) => _handleCsvFileSelect(event)},
          ),
          if (_selectedFile != null)
            div(classes: 'mt-2 text-sm text-neutral-600', [
              text(
                'Selected: ${_selectedFile!.name} (${_formatFileSize(_selectedFile!.size)})',
              ),
            ]),
        ]),
      ]),

      // CSV options
      div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
        // Delimiter
        div(classes: 'space-y-2', [
          label(classes: 'block text-sm font-medium text-neutral-700', [
            text('Delimiter'),
          ]),
          select(
            classes:
                'block w-full px-3 py-2 border border-neutral-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500',
            events: {'change': (event) => _handleDelimiterChange(event)},
            [
              option(value: ',', selected: _csvDelimiter == ',', [
                text('Comma (,)'),
              ]),
              option(value: ';', selected: _csvDelimiter == ';', [
                text('Semicolon (;)'),
              ]),
              option(value: '\t', selected: _csvDelimiter == '\t', [
                text('Tab'),
              ]),
              option(value: '|', selected: _csvDelimiter == '|', [
                text('Pipe (|)'),
              ]),
            ],
          ),
        ]),

        // Header option
        div(classes: 'space-y-2', [
          label(classes: 'block text-sm font-medium text-neutral-700', [
            text('File Format'),
          ]),
          div(classes: 'flex items-center space-x-3', [
            input(
              type: InputType.checkbox,
              attributes: {'checked': _csvHasHeader ? 'true' : 'false'},
              classes:
                  'h-4 w-4 text-primary-600 border-neutral-300 rounded focus:ring-primary-500',
              events: {'change': (event) => _handleHeaderChange(event)},
            ),
            span(classes: 'text-sm text-neutral-700', [
              text('First row contains column headers'),
            ]),
          ]),
        ]),
      ]),

      // Load button
      div(classes: 'pt-4', [
        button(
          classes: [
            'w-full px-4 py-2 text-sm font-medium text-white rounded-md transition-colors duration-200',
            if (_selectedFile != null &&
                (_dataSourceName != null && _dataSourceName!.isNotEmpty) &&
                !_isLoading)
              'bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2'
            else
              'bg-neutral-400 cursor-not-allowed',
          ].join(' '),
          disabled:
              _selectedFile == null ||
              _dataSourceName == null ||
              _dataSourceName!.isEmpty ||
              _isLoading,
          events: {'click': (_) => _loadCsvDataSource()},
          [
            if (_isLoading)
              span(classes: 'flex items-center justify-center space-x-2', [
                div(
                  classes:
                      'animate-spin rounded-full h-4 w-4 border-b-2 border-white',
                  [],
                ),
                span([text('Loading...')]),
              ])
            else
              text('Load CSV Data'),
          ],
        ),
      ]),
    ]);
  }

  Component _buildSqliteConfiguration() {
    return div(classes: 'space-y-6', [
      // Database type
      div(classes: 'space-y-2', [
        label(classes: 'block text-sm font-medium text-neutral-700', [
          text('Database Type'),
        ]),
        div(classes: 'space-y-3', [
          for (final option in [
            (
              'sample',
              'Sample Data',
              'Use pre-loaded sample movie data for testing and exploration',
            ),
            (
              'upload',
              'Upload Database File',
              'Upload an existing SQLite database file with optional persistence',
            ),
          ])
            _buildRadioOption(
              option.$1,
              option.$2,
              option.$3,
              _sqliteType == option.$1,
              (value) => setState(() => _sqliteType = value),
            ),
        ]),
      ]),

      // Configuration based on type
      if (_sqliteType == 'upload') ...[
        _buildSqliteFileUpload(),
        // Persistence options for upload
        div(classes: 'space-y-3', [
          div(classes: 'flex items-center', [
            input(
              type: InputType.checkbox,
              attributes: {
                'checked': _sqlitePersistent ? 'true' : 'false',
                'id': 'sqlite-persistent',
              },
              classes:
                  'h-4 w-4 text-primary-600 focus:ring-primary-500 border-neutral-300 rounded',
              events: {
                'change': (e) => setState(() {
                  _sqlitePersistent =
                      (e.target as web.HTMLInputElement).checked;
                }),
              },
            ),
            label(
              classes: 'ml-2 block text-sm text-neutral-700',
              attributes: {'for': 'sqlite-persistent'},
              [text('Save to persistent storage')],
            ),
          ]),
          if (_sqlitePersistent)
            div(classes: 'ml-6 space-y-2', [
              label(classes: 'block text-sm font-medium text-neutral-700', [
                text('Persistent Database Name'),
              ]),
              input(
                type: InputType.text,
                attributes: {
                  'placeholder': 'my_database',
                  'value': _sqlitePersistentName,
                },
                classes:
                    'block w-full px-3 py-2 border border-neutral-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm',
                events: {
                  'input': (e) => setState(() {
                    _sqlitePersistentName =
                        (e.target as web.HTMLInputElement).value;
                  }),
                },
              ),
              p(classes: 'text-xs text-neutral-500', [
                text(
                  'The database will be saved in browser storage and can be accessed later',
                ),
              ]),
            ]),
        ]),
      ],

      // Table selection (if database is loaded)
      if (_availableTables.isNotEmpty) _buildTableSelector(),

      // Load button
      div(classes: 'pt-4', [
        button(
          classes: [
            'w-full px-4 py-2 text-sm font-medium text-white rounded-md transition-colors duration-200',
            if (_dataSourceName != null &&
                _dataSourceName!.isNotEmpty &&
                !_isLoading)
              'bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2'
            else
              'bg-neutral-400 cursor-not-allowed',
          ].join(' '),
          disabled:
              _dataSourceName == null || _dataSourceName!.isEmpty || _isLoading,
          events: {'click': (_) => _loadSqliteDataSource()},
          [
            if (_isLoading)
              span(classes: 'flex items-center justify-center space-x-2', [
                div(
                  classes:
                      'animate-spin rounded-full h-4 w-4 border-b-2 border-white',
                  [],
                ),
                span([text('Loading...')]),
              ])
            else
              text(
                _sqliteType == 'sample'
                    ? 'Load Sample Data'
                    : 'Connect to Database',
              ),
          ],
        ),
      ]),
    ]);
  }

  Component _buildRadioOption(
    String value,
    String title,
    String description,
    bool isSelected,
    void Function(String) onChanged,
  ) {
    return div(
      classes: [
        'relative rounded-lg border p-4 cursor-pointer transition-all duration-200',
        if (isSelected)
          'border-primary-500 bg-primary-50'
        else
          'border-neutral-200 hover:border-neutral-300 hover:bg-neutral-50',
      ].join(' '),
      events: {'click': (_) => onChanged(value)},
      [
        div(classes: 'flex items-start space-x-3', [
          div(classes: 'flex-shrink-0 mt-1', [
            div(
              classes: [
                'w-4 h-4 rounded-full border-2 transition-all duration-200',
                if (isSelected)
                  'border-primary-500 bg-primary-500'
                else
                  'border-neutral-300',
              ].join(' '),
              [
                if (isSelected)
                  div(
                    classes: 'w-2 h-2 bg-white rounded-full m-auto mt-0.5',
                    [],
                  ),
              ],
            ),
          ]),
          div(classes: 'flex-1', [
            h4(
              classes: [
                'text-sm font-medium transition-colors duration-200',
                if (isSelected) 'text-primary-900' else 'text-neutral-900',
              ].join(' '),
              [text(title)],
            ),
            p(
              classes: [
                'text-xs mt-1 transition-colors duration-200',
                if (isSelected) 'text-primary-700' else 'text-neutral-500',
              ].join(' '),
              [text(description)],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildSqliteFileUpload() {
    return div(classes: 'space-y-2', [
      label(classes: 'block text-sm font-medium text-neutral-700', [
        text('SQLite Database File'),
      ]),
      input(
        type: InputType.file,
        attributes: {'accept': '.db,.sqlite,.sqlite3'},
        classes:
            'block w-full px-3 py-2 border border-neutral-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500',
        events: {'change': (event) => _handleSqliteFileSelect(event)},
      ),
    ]);
  }

  Component _buildTableSelector() {
    return div(classes: 'space-y-2', [
      label(classes: 'block text-sm font-medium text-neutral-700', [
        text('Select Table'),
      ]),
      select(
        classes:
            'block w-full px-3 py-2 border border-neutral-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500',
        events: {'change': (event) => _handleTableChange(event)},
        [
          option(value: '', [text('Choose a table...')]),
          for (final table in _availableTables)
            option(value: table, selected: _selectedTable == table, [
              text(table),
            ]),
        ],
      ),
    ]);
  }

  Component _buildPreviewSection() {
    return div(
      classes: 'bg-white rounded-lg shadow-sm border border-neutral-200 p-6',
      [
        h2(classes: 'text-xl font-semibold text-neutral-900 mb-4', [
          text('Data Preview'),
        ]),
        if (_error != null)
          div(classes: 'mb-4 p-4 bg-red-50 border border-red-200 rounded-md', [
            p(classes: 'text-sm text-red-700', [text(_error!)]),
          ]),
        DataPreview(
          dataSource: _currentDataSource!,
          onError: (message) => setState(() => _error = message),
        ),
      ],
    );
  }

  void _selectType(DataSourceType type) {
    setState(() {
      _selectedType = type;
      _currentDataSource = null;
      _error = null;
      _selectedFile = null;
      _availableTables.clear();
      _selectedTable = null;
    });
  }

  void _handleCsvFileSelect(web.Event event) {
    final input = event.target as web.HTMLInputElement;
    final files = input.files;
    if (files != null && files.length > 0) {
      setState(() {
        _selectedFile = files.item(0);
      });
    }
  }

  void _handleDelimiterChange(web.Event event) {
    final select = event.target as web.HTMLSelectElement;
    setState(() {
      _csvDelimiter = select.value;
    });
  }

  void _handleHeaderChange(web.Event event) {
    final checkbox = event.target as web.HTMLInputElement;
    setState(() {
      _csvHasHeader = checkbox.checked;
    });
  }

  void _handleSqliteFileSelect(web.Event event) {
    final input = event.target as web.HTMLInputElement;
    final files = input.files;
    if (files != null && files.length > 0) {
      setState(() {
        _selectedFile = files.item(0);
      });
    }
  }

  void _handleTableChange(web.Event event) {
    final select = event.target as web.HTMLSelectElement;
    setState(() {
      _selectedTable = select.value;
    });

    // Update the data source with the new table selection
    if (_currentDataSource is SqliteDataSource && _selectedTable != null) {
      final sqliteDs = _currentDataSource as SqliteDataSource;
      sqliteDs.selectTable(_selectedTable!);
      component.onDataSourceSelected?.call(_currentDataSource!);
    }
  }

  Future<void> _loadCsvDataSource() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dataSource = await CsvDataSource.fromFile(
        name: _dataSourceName,
        file: _selectedFile!,
        delimiter: _csvDelimiter,
        hasHeader: _csvHasHeader,
      );

      final connected = await dataSource.connect();
      if (!connected) {
        throw Exception('Failed to connect to CSV data source');
      }

      setState(() {
        _currentDataSource = dataSource;
        _dataSourceName = dataSource.name;
        _isLoading = false;
      });

      component.onDataSourceSelected?.call(dataSource);
    } catch (e) {
      final errorMessage = 'Failed to load CSV file: ${e.toString()}';
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      component.onError?.call(errorMessage);
    }
  }

  Future<void> _loadSqliteDataSource() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      late SqliteDataSource dataSource;

      switch (_sqliteType) {
        case 'sample':
          dataSource = SqliteDataSource.withSampleData(
            name: 'Sample Movie Database',
          );
          break;
        case 'upload':
          if (_selectedFile == null) {
            throw Exception('Please select a database file');
          }
          // Read file as binary data
          final reader = web.FileReader();
          reader.readAsArrayBuffer(_selectedFile!);
          await reader.onLoadEnd.first;
          final data = reader.result as JSArrayBuffer;
          final bytes = data.toDart.asUint8List();

          if (_sqlitePersistent && _sqlitePersistentName.isNotEmpty) {
            dataSource = SqliteDataSource.fromUpload(
              name: _dataSourceName ?? _selectedFile!.name,
              databaseData: bytes,
              persistent: true,
              persistentName: _sqlitePersistentName,
            );
          } else {
            dataSource = SqliteDataSource.fromUpload(
              name: _dataSourceName ?? _selectedFile!.name,
              databaseData: bytes,
            );
          }
          break;
        default:
          throw Exception('Unknown SQLite type: $_sqliteType');
      }

      final connected = await dataSource.connect();
      if (!connected) {
        throw Exception('Failed to connect to SQLite database');
      }

      setState(() {
        _currentDataSource = dataSource;
        _availableTables = dataSource.tables;
        _selectedTable = dataSource.selectedTable;
        _dataSourceName = dataSource.name;
        _isLoading = false;
      });

      component.onDataSourceSelected?.call(dataSource);
    } catch (e) {
      final errorMessage = 'Failed to load SQLite database: ${e.toString()}';
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      component.onError?.call(errorMessage);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
