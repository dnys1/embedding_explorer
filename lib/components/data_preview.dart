import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../models/data_source.dart';

/// A component that displays a preview of data from a data source
///
/// Shows a table with column headers, data types, and sample rows
class DataPreview extends StatefulComponent {
  final DataSource dataSource;
  final int maxRows;
  final bool showDataTypes;
  final bool showRowNumbers;
  final void Function(String message)? onError;

  const DataPreview({
    required this.dataSource,
    this.maxRows = 10,
    this.showDataTypes = true,
    this.showRowNumbers = true,
    this.onError,
    super.key,
  });

  @override
  State<DataPreview> createState() => _DataPreviewState();
}

class _DataPreviewState extends State<DataPreview> {
  List<Map<String, dynamic>> _sampleData = [];
  Map<String, String> _schema = {};
  bool _isLoading = false;
  String? _error;
  int _totalRows = 0;

  static final Logger _logger = Logger('DataPreview');

  @override
  void initState() {
    super.initState();
    _logger.finest(
      'DataPreview initialized for data source: ${component.dataSource.name} (${component.dataSource.type})',
    );
    _loadPreviewData();
  }

  Future<void> _loadPreviewData() async {
    _logger.info(
      'Loading preview data for: ${component.dataSource.name} (max rows: ${component.maxRows})',
    );

    if (!component.dataSource.isConnected) {
      _logger.warning(
        'Data source is not connected: ${component.dataSource.name}',
      );
      setState(() {
        _error = 'Data source is not connected';
        _isLoading = false;
      });
      component.onError?.call('Data source is not connected');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    _logger.finest(
      'Starting parallel data loading for schema, sample data, and row count',
    );

    try {
      // Load schema and sample data in parallel
      final (schema, sampleData, totalRows) = await (
        component.dataSource.getSchema(),
        component.dataSource.getSampleData(limit: component.maxRows),
        component.dataSource.getRowCount(),
      ).wait;

      _logger.info(
        'Successfully loaded preview data: ${sampleData.length} rows, ${schema.length} columns, $totalRows total rows',
      );
      _logger.finest('Schema fields: ${schema.keys.join(', ')}');

      setState(() {
        _schema = schema;
        _sampleData = sampleData;
        _totalRows = totalRows;
        _isLoading = false;
      });
    } catch (e) {
      final errorMessage = 'Failed to load preview data: ${e.toString()}';
      _logger.severe(
        'Failed to load preview data for ${component.dataSource.name}',
        e,
      );
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      component.onError?.call(errorMessage);
    }
  }

  @override
  Component build(BuildContext context) {
    return div(
      classes:
          'data-preview bg-white rounded-lg shadow-sm border border-gray-200',
      [_buildHeader(), _buildContent()],
    );
  }

  Component _buildHeader() {
    return div(
      classes: 'px-4 py-3 border-b border-gray-200 bg-gray-50 rounded-t-lg',
      [
        div(classes: 'flex items-center justify-between', [
          div(classes: 'flex items-center space-x-3', [
            h3(classes: 'text-lg font-medium text-gray-900', [
              text('Data Preview'),
            ]),
            if (_isLoading)
              div(
                classes: 'flex items-center space-x-2 text-sm text-gray-500',
                [
                  div(
                    classes:
                        'animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500',
                    [],
                  ),
                  span([text('Loading...')]),
                ],
              )
            else if (_sampleData.isNotEmpty)
              span(classes: 'text-sm text-gray-500', [
                text('Showing ${_sampleData.length} of $_totalRows rows'),
              ]),
          ]),
          div(classes: 'flex items-center space-x-2', [
            span(
              classes:
                  'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800',
              [text(component.dataSource.type.toUpperCase())],
            ),
            span(classes: 'text-sm text-gray-500', [
              text(component.dataSource.name),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildContent() {
    if (_isLoading) {
      return div(classes: 'p-8 text-center', [
        div(
          classes:
              'animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-4',
          [],
        ),
        p(classes: 'text-gray-500', [text('Loading preview data...')]),
      ]);
    }

    if (_error != null) {
      return div(classes: 'p-4', [
        div(classes: 'rounded-md bg-red-50 p-4', [
          div(classes: 'flex', [
            div(classes: 'flex-shrink-0', [
              svg(
                classes: 'h-5 w-5 text-red-400',
                attributes: {'fill': 'currentColor', 'viewBox': '0 0 20 20'},
                [
                  path(
                    attributes: {
                      'fill-rule': 'evenodd',
                      'd':
                          'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z',
                      'clip-rule': 'evenodd',
                    },
                    [],
                  ),
                ],
              ),
            ]),
            div(classes: 'ml-3', [
              h3(classes: 'text-sm font-medium text-red-800', [
                text('Error loading preview'),
              ]),
              div(classes: 'mt-2 text-sm text-red-700', [
                p([text(_error!)]),
              ]),
              div(classes: 'mt-4', [
                button(
                  classes:
                      'bg-red-100 px-2 py-1 text-sm font-medium text-red-800 rounded-md hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2',
                  events: {'click': (_) => _loadPreviewData()},
                  [text('Retry')],
                ),
              ]),
            ]),
          ]),
        ]),
      ]);
    }

    if (_sampleData.isEmpty) {
      return div(classes: 'p-8 text-center', [
        div(classes: 'text-gray-400 mb-4', [
          svg(
            classes: 'mx-auto h-12 w-12',
            attributes: {
              'fill': 'none',
              'viewBox': '0 0 24 24',
              'stroke': 'currentColor',
            },
            [
              path(
                attributes: {
                  'stroke-linecap': 'round',
                  'stroke-linejoin': 'round',
                  'stroke-width': '2',
                  'd':
                      'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
                },
                [],
              ),
            ],
          ),
        ]),
        h3(classes: 'text-sm font-medium text-gray-900 mb-2', [
          text('No data available'),
        ]),
        p(classes: 'text-sm text-gray-500', [
          text(
            'This data source appears to be empty or contains no accessible data.',
          ),
        ]),
      ]);
    }

    return div(classes: 'overflow-x-auto', [
      table(classes: 'min-w-full divide-y divide-gray-200', [
        _buildTableHeader(),
        _buildTableBody(),
      ]),
    ]);
  }

  Component _buildTableHeader() {
    final columns = _sampleData.isNotEmpty
        ? _sampleData.first.keys.toList()
        : <String>[];

    return thead(classes: 'bg-gray-50', [
      tr([
        if (component.showRowNumbers)
          th(
            classes:
                'px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider bg-gray-100',
            [text('#')],
          ),
        for (final column in columns)
          th(
            classes:
                'px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider',
            [
              div(classes: 'flex flex-col space-y-1', [
                span(classes: 'font-medium text-gray-900', [text(column)]),
                if (component.showDataTypes && _schema.containsKey(column))
                  span(
                    classes: 'text-xs text-gray-500 font-normal capitalize',
                    [text(_getDisplayType(_schema[column]!))],
                  ),
              ]),
            ],
          ),
      ]),
    ]);
  }

  Component _buildTableBody() {
    return tbody(classes: 'bg-white divide-y divide-gray-200', [
      for (int index = 0; index < _sampleData.length; index++)
        _buildTableRow(_sampleData[index], index),
    ]);
  }

  Component _buildTableRow(Map<String, dynamic> row, int index) {
    return tr(classes: index % 2 == 0 ? 'bg-white' : 'bg-gray-50', [
      if (component.showRowNumbers)
        td(
          classes:
              'px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500 bg-gray-100',
          [text('${index + 1}')],
        ),
      for (final entry in row.entries)
        td(classes: 'px-6 py-4 whitespace-nowrap text-sm text-gray-900', [
          _buildCellContent(entry.value, entry.key),
        ]),
    ]);
  }

  Component _buildCellContent(dynamic value, String columnName) {
    if (value == null) {
      return span(classes: 'text-gray-400 italic', [text('null')]);
    }

    final stringValue = value.toString();
    final fieldType = _schema[columnName];

    // Truncate long values
    final displayValue = stringValue.length > 50
        ? '${stringValue.substring(0, 47)}...'
        : stringValue;

    // Style based on data type
    String cellClasses = 'font-mono text-sm';

    switch (fieldType) {
      case 'integer':
        cellClasses += ' text-blue-600';
        break;
      case 'real':
        cellClasses += ' text-green-600';
        break;
      case 'boolean':
        cellClasses += ' text-purple-600';
        break;
      case 'date':
      case 'datetime':
        cellClasses += ' text-indigo-600';
        break;
      default:
        cellClasses += ' text-gray-900';
    }

    return span(
      classes: cellClasses,
      attributes: stringValue.length > 50 ? {'title': stringValue} : {},
      [text(displayValue)],
    );
  }

  String _getDisplayType(String type) {
    switch (type.toLowerCase()) {
      case 'integer':
        return 'int';
      case 'real':
        return 'number';
      case 'text':
        return 'text';
      case 'boolean':
        return 'bool';
      case 'date':
        return 'date';
      case 'datetime':
        return 'datetime';
      case 'blob':
        return 'binary';
      default:
        return type;
    }
  }
}
