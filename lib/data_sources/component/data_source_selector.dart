import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../../common/ui/ui.dart';
import '../../configurations/model/configuration_manager.dart';
import '../../util/clsx.dart';
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
  State<DataSourceSelector> createState() => DataSourceSelectorState();
}

class DataSourceSelectorState extends State<DataSourceSelector>
    with ConfigurationManagerListener {
  late DataSourceType selectedType;

  /// Access to the data source repository
  DataSourceRepository get _repository => configManager.dataSources;
  DataSource? _currentDataSource;
  bool _isLoading = false;
  String? _error;
  String _dataSourceName = '';

  // CSV configuration
  String _csvDelimiter = ',';
  bool _csvHasHeader = true;
  web.File? _selectedFile;

  // SQLite configuration
  SqliteDataSourceType sqliteType = SqliteDataSourceType.import;
  String? _sqliteFilename;

  @override
  void initState() {
    super.initState();
    _loadInitialDataSource();
  }

  void _loadInitialDataSource() {
    _currentDataSource = component.initialDataSource;
    _syncStateFromDataSource(_currentDataSource);
    if (_currentDataSource?.type == DataSourceType.sqlite) {
      sqliteType = SqliteDataSourceType.persistent;
    }
  }

  /// Synchronize UI state with the current data source state
  void _syncStateFromDataSource(DataSource? dataSource) {
    switch (dataSource) {
      case CsvDataSource csvDataSource:
        selectedType = DataSourceType.csv;
        _dataSourceName = csvDataSource.name;
        _csvDelimiter = csvDataSource.csvSettings.delimiter;
        _csvHasHeader = csvDataSource.csvSettings.hasHeader;
      case final SampleDataSource dataSource:
        selectedType = DataSourceType.sample;
        _dataSourceName = dataSource.name;
      case final SqliteDataSource dataSource:
        selectedType = DataSourceType.sqlite;
        _dataSourceName = dataSource.name;
        _sqliteFilename = dataSource.config.filename;
      case null:
        selectedType = DataSourceType.csv;
    }
  }

  void _selectType(DataSourceType type) {
    setState(() {
      selectedType = type;
      _currentDataSource = null;
      _error = null;
      _selectedFile = null;
      _dataSourceName = '';

      // Reset type-specific state
      switch (type) {
        case DataSourceType.csv:
          _csvDelimiter = ',';
          _csvHasHeader = true;
        case DataSourceType.sqlite:
          sqliteType = SqliteDataSourceType.import;
          _sqliteFilename = null;
        case DataSourceType.sample:
          _dataSourceName = 'Movies';
      }
    });
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
    final isSelected = selectedType == type;

    return div(
      key: ValueKey(type),
      classes: [
        'relative rounded-lg border-2 p-4 cursor-pointer transition-all duration-200',
        if (type == DataSourceType.sample) 'md:col-span-2',
        if (isSelected)
          'border-primary-500 bg-primary-50'
        else
          'border-neutral-200 hover:border-neutral-300 hover:bg-neutral-50',
      ].clsx,
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
            switch (selectedType) {
              DataSourceType.csv => _buildCsvConfiguration(),
              DataSourceType.sqlite => _buildSqliteConfiguration(),
              DataSourceType.sample => div([]),
            },
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

      // CSV options
      div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
        // Delimiter
        div(classes: 'space-y-2', [
          Label(children: [text('Delimiter')]),
          Select(
            value: _csvDelimiter,
            onChange: (value) => setState(() => _csvDelimiter = value),
            children: [
              Option(value: ',', children: [text('Comma (,)')]),
              Option(value: ';', children: [text('Semicolon (;)')]),
              Option(value: '\t', children: [text('Tab')]),
              Option(value: '|', children: [text('Pipe (|)')]),
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
                  (_dataSourceName.isNotEmpty) &&
                  !_isLoading
              ? ButtonVariant.primary
              : ButtonVariant.secondary,
          className: 'w-full',
          disabled:
              _selectedFile == null || _dataSourceName.isEmpty || _isLoading,
          onPressed:
              _selectedFile != null &&
                  (_dataSourceName.isNotEmpty) &&
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
    final availableOptions = SqliteDataSourceType.values
        .where(_shouldShowOption)
        .toList(growable: false);
    return div(classes: 'space-y-6', [
      // Database type
      if (availableOptions.length > 1)
        div(classes: 'space-y-2', [
          Label(children: [text('Database Type')]),
          div(classes: 'space-y-3', [
            for (final option in availableOptions)
              _buildRadioOption(
                value: option,
                title: option.displayName,
                description: option.description,
                isSelected: sqliteType == option,
                onChanged: (value) => setState(() => sqliteType = value),
              ),
          ]),
        ]),

      // Configuration based on type
      if (sqliteType == SqliteDataSourceType.import)
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
              _sqliteFilename = file.name;
            }
          }),
        ),

      if (sqliteType == SqliteDataSourceType.persistent)
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
          variant: _dataSourceName.isNotEmpty && !_isLoading
              ? ButtonVariant.primary
              : ButtonVariant.secondary,
          className: 'w-full',
          disabled: _dataSourceName.isEmpty || _isLoading,
          onPressed: _dataSourceName.isNotEmpty && !_isLoading
              ? _loadSqliteDataSource
              : null,
          children: [
            if (_isLoading) ...[
              Skeleton(className: 'h-4 w-4 rounded-full mr-2'),
              text('Loading...'),
            ] else
              text('Connect to Database'),
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
      final dataSourceConfig = DataSourceConfig.create(
        name: _dataSourceName,
        type: DataSourceType.csv,
        filename: _selectedFile!.name,
        settings: CsvDataSourceSettings(
          delimiter: _csvDelimiter,
          hasHeader: _csvHasHeader,
        ),
      );
      final dataSource = await _repository.import(
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
      final config = DataSourceConfig.create(
        name: _dataSourceName,
        filename: _sqliteFilename ?? _selectedFile!.name,
        type: DataSourceType.sqlite,
        settings: SqliteDataSourceSettings(),
      );
      final dataSource = sqliteType == SqliteDataSourceType.import
          ? await _repository.import(config: config, file: _selectedFile!)
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
