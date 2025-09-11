import 'package:aws_common/aws_common.dart';
import '../model/data_source_config.dart';
import '../../util/file.dart';
import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../../common/ui/ui.dart';
import '../model/data_source.dart';
import '../service/csv_data_source.dart';
import '../service/sqlite_data_source.dart';
import 'data_preview.dart';

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
  String? _sqlitePersistentName;
  String _sqlQuery = '';
  bool _showQueryEditor = false;

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
    return Card(
      children: [
        CardHeader(
          children: [
            CardTitle(children: [text('Choose Data Source Type')]),
          ],
        ),
        CardContent(
          children: [
            div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
              for (final type in DataSourceType.values) _buildTypeCard(type),
            ]),
          ],
        ),
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
    return Card(
      children: [
        CardHeader(
          children: [
            CardTitle(children: [text('Configuration')]),
          ],
        ),
        CardContent(
          children: [
            // Name input field (common for all data source types)
            div(classes: 'mb-6 space-y-2', [
              Label(
                htmlFor: 'data-source-name',
                children: [text('Data Source Name *')],
              ),
              input(
                classes:
                    'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                attributes: {
                  'id': 'data-source-name',
                  'placeholder': 'Enter a name for this data source',
                  'value': _dataSourceName ?? '',
                },
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
        ),
      ],
    );
  }

  Component _buildCsvConfiguration() {
    return div(classes: 'space-y-6', [
      // File upload
      div(classes: 'space-y-2', [
        Label(children: [text('CSV File')]),
        div(classes: 'relative', [
          input(
            id: 'csv-file-input',
            type: InputType.file,
            classes:
                'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
            attributes: {'accept': '.csv,.txt'},
            events: {'change': (event) => _handleCsvFileSelect(event)},
          ),
          if (_selectedFile != null)
            div(classes: 'mt-2', [
              Badge(
                variant: BadgeVariant.secondary,
                children: [
                  text(
                    'Selected: ${_selectedFile!.name} (${_formatFileSize(_selectedFile!.size)})',
                  ),
                ],
              ),
            ]),
        ]),
      ]),

      // CSV options
      div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
        // Delimiter
        div(classes: 'space-y-2', [
          Label(children: [text('Delimiter')]),
          select(
            classes:
                'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
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
          Label(children: [text('File Format')]),
          div(classes: 'flex items-center space-x-3', [
            Checkbox(
              id: 'csv-has-header',
              checked: _csvHasHeader,
              onChanged: (checked) => setState(() => _csvHasHeader = checked),
            ),
            Label(
              htmlFor: 'csv-has-header',
              children: [text('First row contains column headers')],
            ),
          ]),
        ]),
      ]),

      // Load button
      div(classes: 'pt-4', [
        Button(
          variant:
              _selectedFile != null &&
                  (_dataSourceName != null && _dataSourceName!.isNotEmpty) &&
                  !_isLoading
              ? ButtonVariant.primary
              : ButtonVariant.secondary,
          className: 'w-full',
          disabled:
              _selectedFile == null ||
              _dataSourceName == null ||
              _dataSourceName!.isEmpty ||
              _isLoading,
          onPressed:
              _selectedFile != null &&
                  (_dataSourceName != null && _dataSourceName!.isNotEmpty) &&
                  !_isLoading
              ? _loadCsvDataSource
              : null,
          children: [
            if (_isLoading) ...[
              Skeleton(className: 'h-4 w-4 rounded-full mr-2'),
              text('Loading...'),
            ] else
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
        Label(children: [text('Database Type')]),
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
          div(classes: 'flex items-center space-x-2', [
            Checkbox(
              id: 'sqlite-persistent',
              checked: _sqlitePersistent,
              onChanged: (checked) => setState(() {
                _sqlitePersistent = checked;
                _sqlitePersistentName ??= _dataSourceName?.snakeCase;
              }),
            ),
            Label(
              htmlFor: 'sqlite-persistent',
              children: [text('Save to persistent storage')],
            ),
          ]),
          if (_sqlitePersistent)
            div(classes: 'ml-6 space-y-2', [
              Label(children: [text('Persistent Database Name')]),
              input(
                classes:
                    'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
                attributes: {
                  'placeholder': 'my_database',
                  'value': ?_sqlitePersistentName,
                },
                events: {
                  'input': (e) => setState(() {
                    _sqlitePersistentName =
                        (e.target as web.HTMLInputElement).value;
                  }),
                },
              ),
              p(classes: 'text-xs text-muted-foreground', [
                text(
                  'The database will be saved in browser storage and can be accessed later',
                ),
              ]),
            ]),
        ]),
      ],

      // SQL Query editor (if database is loaded and connected)
      if (_showQueryEditor) _buildSqlQueryEditor(),

      // Load button
      div(classes: 'pt-4', [
        Button(
          variant:
              _dataSourceName != null &&
                  _dataSourceName!.isNotEmpty &&
                  !_isLoading
              ? ButtonVariant.primary
              : ButtonVariant.secondary,
          className: 'w-full',
          disabled:
              _dataSourceName == null || _dataSourceName!.isEmpty || _isLoading,
          onPressed:
              _dataSourceName != null &&
                  _dataSourceName!.isNotEmpty &&
                  !_isLoading
              ? _loadSqliteDataSource
              : null,
          children: [
            if (_isLoading) ...[
              Skeleton(className: 'h-4 w-4 rounded-full mr-2'),
              text('Loading...'),
            ] else
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
          'border-primary bg-accent/50 ring-2 ring-primary ring-offset-2'
        else
          'border-border hover:border-accent-foreground hover:bg-accent/25',
      ].join(' '),
      events: {'click': (_) => onChanged(value)},
      [
        div(classes: 'flex items-start space-x-3', [
          div(classes: 'flex-shrink-0 mt-1', [
            Radio(
              value: value,
              groupValue: isSelected ? value : null,
              onChanged: onChanged,
              name: 'sqlite-type',
            ),
          ]),
          div(classes: 'flex-1', [
            h4(
              classes: [
                'text-sm font-medium transition-colors duration-200',
                if (isSelected) 'text-foreground' else 'text-foreground',
              ].join(' '),
              [text(title)],
            ),
            p(
              classes: [
                'text-xs mt-1 transition-colors duration-200',
                if (isSelected)
                  'text-muted-foreground'
                else
                  'text-muted-foreground',
              ].join(' '),
              [text(description)],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildSqliteFileUpload() {
    return div(classes: 'space-y-4', [
      Label(children: [text('Database File')]),
      div(
        classes: [
          'relative cursor-pointer group border-2 border-dashed rounded-lg p-6 text-center transition-colors',
          if (_selectedFile != null)
            'border-border bg-accent/50'
          else
            'border-border hover:border-accent-foreground hover:bg-accent/50',
        ].join(' '),
        events: {
          'click': (_) {
            final fileInput =
                web.document.querySelector('#sqlite-file-input')
                    as web.HTMLInputElement?;
            fileInput?.click();
          },
          'drop': (e) {
            e.preventDefault();
            final files = (e as web.DragEvent).dataTransfer?.files;
            if (files != null && files.length > 0) {
              final file = files.item(0);
              if (file != null) {
                setState(() => _selectedFile = file);
              }
            }
          },
          'dragover': (e) => e.preventDefault(),
          'dragenter': (e) => e.preventDefault(),
        },
        [
          if (_selectedFile != null) ...[
            div(classes: 'space-y-2', [
              Badge(
                variant: BadgeVariant.secondary,
                children: [text(_selectedFile!.name)],
              ),
              p(classes: 'text-sm text-muted-foreground', [
                text('${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB'),
              ]),
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () => setState(() => _selectedFile = null),
                children: [text('Remove file')],
              ),
            ]),
          ] else ...[
            div(classes: 'space-y-2', [
              div(classes: 'mx-auto w-12 h-12 text-muted-foreground', [
                // Upload icon placeholder
                div(
                  classes: 'w-full h-full bg-muted-foreground/20 rounded-full',
                  [],
                ),
              ]),
              div(classes: 'space-y-1', [
                p(classes: 'text-sm text-foreground', [
                  text('Drop your SQLite file here, or '),
                  span(classes: 'text-primary font-medium', [text('browse')]),
                ]),
                p(classes: 'text-xs text-muted-foreground', [
                  text('Supports .db, .sqlite, .sqlite3 files'),
                ]),
              ]),
            ]),
          ],
        ],
      ),
      // Hidden file input
      input(
        classes: 'hidden',
        attributes: {
          'type': 'file',
          'accept': '.db,.sqlite,.sqlite3',
          'id': 'sqlite-file-input',
        },
        events: {
          'change': (e) {
            final files = (e.target as web.HTMLInputElement).files;
            if (files != null && files.length > 0) {
              final file = files.item(0);
              if (file != null) {
                setState(() => _selectedFile = file);
              }
            }
          },
        },
      ),
    ]);
  }

  Component _buildSqlQueryEditor() {
    return div(classes: 'space-y-2', [
      Label(children: [text('SQL Query')]),
      div(classes: 'space-y-2', [
        Textarea(
          placeholder:
              'SELECT * FROM table_name\nWHERE condition = value\nORDER BY column',
          value: _sqlQuery,
          onInput: (String value) => setState(() => _sqlQuery = value),
          className: 'min-h-[120px] font-mono text-sm',
        ),
        p(classes: 'text-xs text-muted-foreground', [
          text(
            'Enter a SQL query to retrieve the data you need. You can use JOINs, WHERE clauses, and other SQL features.',
          ),
        ]),
        if (_sqlQuery.trim().isNotEmpty)
          Button(
            variant: ButtonVariant.primary,
            size: ButtonSize.sm,
            onPressed: _applySqlQuery,
            children: [text('Apply Query')],
          ),
      ]),
    ]);
  }

  Component _buildPreviewSection() {
    if (_error != null) {
      return Alert(
        variant: AlertVariant.destructive,
        children: [text(_error!)],
      );
    } else {
      return DataPreview(
        dataSource: _currentDataSource!,
        onError: (message) => setState(() => _error = message),
      );
    }
  }

  void _selectType(DataSourceType type) {
    setState(() {
      _selectedType = type;
      _currentDataSource = null;
      _error = null;
      _selectedFile = null;
      _showQueryEditor = false;
      _sqlQuery = '';
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

  void _applySqlQuery() {
    if (_currentDataSource is SqliteDataSource && _sqlQuery.trim().isNotEmpty) {
      final sqliteDs = _currentDataSource as SqliteDataSource;
      try {
        sqliteDs.setSqlQuery(_sqlQuery.trim());
        component.onDataSourceSelected?.call(_currentDataSource!);
        setState(() {
          _error = null;
        });
      } catch (e) {
        setState(() {
          _error = 'Invalid SQL query: ${e.toString()}';
        });
        component.onError?.call('Invalid SQL query: ${e.toString()}');
      }
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
        case 'upload':
          if (_selectedFile == null) {
            throw Exception('Please select a database file');
          }
          final bytes = await _selectedFile!.readAsBytes();

          if (_sqlitePersistent) {
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
        default:
          throw Exception('Unknown SQLite type: $_sqliteType');
      }

      final connected = await dataSource.connect();
      if (!connected) {
        throw Exception('Failed to connect to SQLite database');
      }

      setState(() {
        _currentDataSource = dataSource;
        _showQueryEditor = true;
        _sqlQuery = dataSource.sqlQuery ?? '';
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
