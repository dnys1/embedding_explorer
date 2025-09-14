import 'dart:js_interop';

import 'package:aws_common/aws_common.dart';
import 'package:jaspr/jaspr.dart';
import 'package:path/path.dart' as path;
import 'package:web/web.dart' as web;

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../util/element.dart';
import '../model/data_source.dart';
import '../model/data_source_config.dart';
import '../model/data_source_settings.dart';
import '../service/csv_data_source.dart';
import '../service/data_source_repository.dart';
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

class _DataSourceSelectorState extends State<DataSourceSelector>
    with ConfigurationManagerListener {
  late DataSourceType _selectedType;

  /// Access to the data source repository
  DataSourceRepository get _repository => configManager.dataSources;
  DataSource? _currentDataSource;
  bool _isLoading = false;
  String? _error;
  String? _dataSourceName;

  // CSV configuration
  String _csvDelimiter = ',';
  bool _csvHasHeader = true;
  bool _csvPersistent = false;
  String? _csvPersistentName;
  web.File? _selectedFile;

  // SQLite configuration
  SqliteDataSourceType _sqliteType = SqliteDataSourceType.sample;
  String? _sqliteFilename;

  @override
  void initState() {
    super.initState();
    _loadInitialDataSource();
  }

  void _loadInitialDataSource() {
    _currentDataSource = component.initialDataSource;
    switch (component.initialDataSource) {
      case final CsvDataSource dataSource:
        _selectedType = DataSourceType.csv;
        _dataSourceName = dataSource.name;
        _csvDelimiter = dataSource.csvSettings.delimiter;
        _csvHasHeader = dataSource.csvSettings.hasHeader;
        _csvPersistent = dataSource.csvSettings.persistent;
        _csvPersistentName = dataSource.csvSettings.persistentName;
      case final SqliteDataSource dataSource:
        _selectedType = DataSourceType.sqlite;
        _dataSourceName = dataSource.name;
        _sqliteType = SqliteDataSourceType.persistent;
        _sqliteFilename = dataSource.sqliteSettings.filename;
      case null:
        _selectedType = DataSourceType.csv;
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
            RadioGroup(
              className: 'grid grid-cols-1 md:grid-cols-2 gap-4',
              children: [
                for (final type in DataSourceType.values) _buildTypeCard(type),
              ],
            ),
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
            h4(
              classes: [
                'font-medium transition-colors duration-200',
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
              Input.text(
                id: 'data-source-name',
                placeholder: 'Enter a name for this data source',
                value: _dataSourceName,
                onChange: (value) => setState(() => _dataSourceName = value),
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
      FileUpload(
        label: 'CSV File',
        accept: '.csv,.txt',
        inputId: 'csv-file-input',
        dropText: 'Drop your CSV file here',
        supportedFormats: 'Supports .csv, .txt files',
        selectedFile: _selectedFile,
        onFileChanged: (file) => setState(() => _selectedFile = file),
      ),

      // Persistence options
      div(classes: 'space-y-3', [
        div(classes: 'flex items-center space-x-2', [
          Checkbox(
            id: 'csv-persistent',
            checked: _csvPersistent,
            onChanged: (checked) => setState(() {
              _csvPersistent = checked;
              _csvPersistentName ??= _dataSourceName
                  ?.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
                  .toLowerCase();
            }),
          ),
          Label(
            htmlFor: 'csv-persistent',
            children: [text('Save to persistent storage')],
          ),
        ]),
        if (_csvPersistent)
          div(classes: 'ml-6 space-y-2', [
            Label(
              htmlFor: 'csv-persistent-name',
              children: [text('Persistent Dataset Name')],
            ),
            Input.text(
              id: 'csv-persistent-name',
              placeholder: 'my_csv_dataset',
              value: _csvPersistentName,
              onChange: (value) => setState(() => _csvPersistentName = value),
            ),
            p(classes: 'text-xs text-muted-foreground', [
              text(
                'The CSV data will be saved in browser storage and can be accessed later',
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

  bool _shouldShowOption(SqliteDataSourceType type) {
    return switch (type) {
      SqliteDataSourceType.persistent =>
        _repository.persistentSqliteDatabaseNames.isNotEmpty,
      _ => true,
    };
  }

  Component _buildSqliteConfiguration() {
    return div(classes: 'space-y-6', [
      // Database type
      div(classes: 'space-y-2', [
        Label(children: [text('Database Type')]),
        div(classes: 'space-y-3', [
          for (final option in SqliteDataSourceType.values.where(
            _shouldShowOption,
          ))
            _buildRadioOption(
              value: option,
              title: option.displayName,
              description: option.description,
              isSelected: _sqliteType == option,
              onChanged: (value) => setState(() => _sqliteType = value),
            ),
        ]),
      ]),

      // Configuration based on type
      if (_sqliteType == SqliteDataSourceType.import)
        FileUpload(
          label: 'Database File',
          accept: '.db,.sqlite,.sqlite3',
          inputId: 'sqlite-file-input',
          dropText: 'Drop your SQLite file here',
          supportedFormats: 'Supports .db, .sqlite, .sqlite3 files',
          selectedFile: _selectedFile,
          onFileChanged: (file) => setState(() {
            _selectedFile = file;
            if (_sqliteFilename == null && file != null) {
              final filename = path.withoutExtension(file.name).snakeCase;
              var ext = path.extension(file.name);
              if (ext.isEmpty) {
                ext = '.db';
              }
              _sqliteFilename = '$filename$ext';
            }
          }),
        ),

      if (_sqliteType == SqliteDataSourceType.persistent)
        // Select from existing persistent databases
        div(classes: 'space-y-2', [
          Label(children: [text('Select Database')]),
          Select(
            value: _sqliteFilename,
            placeholder: 'Select a database',
            onChange: (value) => setState(() => _sqliteFilename = value),
            children: [
              for (final name in _repository.persistentSqliteDatabaseNames)
                Option(
                  value: name,
                  selected: _sqliteFilename == name,
                  children: [text(name)],
                ),
            ],
          ),
        ]),

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
                _sqliteType == SqliteDataSourceType.sample
                    ? 'Load Sample Data'
                    : 'Connect to Database',
              ),
          ],
        ),
      ]),
    ]);
  }

  Component _buildRadioOption({
    required SqliteDataSourceType value,
    required String title,
    required String description,
    required bool isSelected,
    required void Function(SqliteDataSourceType) onChanged,
  }) {
    return div(
      classes: [
        'relative rounded-lg border-2 p-4 cursor-pointer transition-all duration-200',
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
                'font-medium transition-colors duration-200',
                if (isSelected) 'text-primary-900' else 'text-neutral-900',
              ].join(' '),
              [text(title)],
            ),
            p(
              classes: [
                'text-sm mt-1 transition-colors duration-200',
                if (isSelected) 'text-primary-700' else 'text-neutral-500',
              ].join(' '),
              [text(description)],
            ),
          ]),
        ]),
      ],
    );
  }

  Component _buildPreviewSection() {
    return div(id: 'data-preview', [
      if (_error != null)
        Alert(variant: AlertVariant.destructive, children: [text(_error!)])
      else
        DataPreview(
          dataSource: _currentDataSource!,
          onError: (message) => setState(() => _error = message),
          onDataSourceUpdated: (dataSource) {
            // Sync state and notify parent when data source is updated (e.g., query changed)
            _syncStateFromDataSource(dataSource);
            component.onDataSourceSelected?.call(dataSource);
          },
        ),
    ]);
  }

  /// Synchronize UI state with the current data source state
  void _syncStateFromDataSource(DataSource dataSource) {
    if (dataSource is SqliteDataSource) {
      _selectedType = DataSourceType.sqlite;

      // Sync SQLite-specific settings
      final settings = dataSource.sqliteSettings;
      _sqliteFilename = settings.filename;
    } else {
      // Handle other data source types (CSV, etc.)
      _selectedType = dataSource.type;
    }
  }

  void _selectType(DataSourceType type) {
    setState(() {
      _selectedType = type;
      _currentDataSource = null;
      _error = null;
      _selectedFile = null;

      // Reset type-specific state
      if (type == DataSourceType.sqlite) {
        _sqliteType = SqliteDataSourceType.sample;
        _sqliteFilename = null;
      } else if (type == DataSourceType.csv) {
        _csvDelimiter = ',';
        _csvHasHeader = true;
        _csvPersistent = false;
        _csvPersistentName = null;
      }
    });
  }

  void _handleDelimiterChange(web.Event event) {
    final select = event.target as web.HTMLSelectElement;
    setState(() {
      _csvDelimiter = select.value;
    });
  }

  Future<void> _scrollToPreview() async {
    final preview = await waitForElement<web.HTMLElement>('data-preview');
    preview.scrollIntoView({'behavior': 'smooth'}.jsify()!);
  }

  Future<void> _loadCsvDataSource() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dataSourceConfig = DataSourceConfig(
        name: _dataSourceName!,
        type: DataSourceType.csv,
        settings: CsvDataSourceSettings(
          delimiter: _csvDelimiter,
          hasHeader: _csvHasHeader,
          persistent: _csvPersistent,
          persistentName: _csvPersistentName,
        ),
      );
      final dataSource = await _repository.loadFromFile(
        config: dataSourceConfig,
        file: _selectedFile!,
      );

      setState(() {
        _currentDataSource = dataSource;
        _dataSourceName = dataSource.name;
        _isLoading = false;
      });

      component.onDataSourceSelected?.call(dataSource);

      // Scroll to preview section after successful load
      _scrollToPreview().ignore();
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
      final config = DataSourceConfig(
        name: _dataSourceName!,
        type: DataSourceType.sqlite,
        settings: SqliteDataSourceSettings(filename: _sqliteFilename),
      );
      final dataSource = _sqliteType == SqliteDataSourceType.import
          ? await _repository.loadFromFile(config: config, file: _selectedFile!)
          : await _repository.connect(config);

      setState(() {
        _currentDataSource = dataSource;
        _dataSourceName = dataSource.name;
        _syncStateFromDataSource(dataSource);
        _isLoading = false;
      });

      component.onDataSourceSelected?.call(dataSource);

      // Scroll to preview section after successful load
      _scrollToPreview().ignore();
    } catch (e) {
      final errorMessage = 'Failed to load SQLite database: ${e.toString()}';
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      component.onError?.call(errorMessage);
    }
  }
}
