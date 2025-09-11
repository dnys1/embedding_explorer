import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../common/ui/ui.dart';
import '../model/data_source.dart';

/// A component that displays a preview of data from a data source
///
/// Shows a table with column headers, data types, and sample rows
/// Now uses shadcn/ui components for improved styling and UX
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
    return Card(
      className: 'data-preview',
      children: [_buildHeader(), _buildContent()],
    );
  }

  Component _buildHeader() {
    return CardHeader(
      children: [
        div(classes: 'flex items-center justify-between', [
          div(classes: 'flex items-center space-x-3', [
            h3(classes: 'text-lg font-medium text-neutral-900', [
              text('Data Preview'),
            ]),
            if (_isLoading)
              div(
                classes: 'flex items-center space-x-2 text-sm text-neutral-500',
                [
                  Skeleton(className: 'h-4 w-4 rounded-full'),
                  span([text('Loading...')]),
                ],
              )
            else if (_sampleData.isNotEmpty)
              span(classes: 'text-sm text-neutral-500', [
                text('Showing ${_sampleData.length} of $_totalRows rows'),
              ]),
          ]),
          div(classes: 'flex items-center space-x-2', [
            Badge(
              variant: BadgeVariant.secondary,
              children: [text(component.dataSource.type.toUpperCase())],
            ),
            span(classes: 'text-sm text-neutral-500', [
              text(component.dataSource.name),
            ]),
          ]),
        ]),
      ],
    );
  }

  Component _buildContent() {
    if (_isLoading) {
      return CardContent(
        children: [
          div(classes: 'p-8 text-center space-y-4', [
            Skeleton(className: 'h-8 w-8 rounded-full mx-auto'),
            Skeleton(className: 'h-4 w-48 mx-auto'),
            div(classes: 'space-y-2', [
              Skeleton(className: 'h-4 w-full'),
              Skeleton(className: 'h-4 w-3/4'),
              Skeleton(className: 'h-4 w-5/6'),
            ]),
          ]),
        ],
      );
    }

    if (_error case final error?) {
      return CardContent(
        children: [
          Alert(
            variant: AlertVariant.destructive,
            children: [
              div(classes: 'flex', [
                div(classes: 'flex-shrink-0', [
                  svg(
                    classes: 'h-5 w-5',
                    attributes: {
                      'fill': 'currentColor',
                      'viewBox': '0 0 20 20',
                    },
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
                div(classes: 'ml-3 flex-1', [
                  AlertTitle(children: [text('Error loading preview')]),
                  AlertDescription(children: [text(error)]),
                  div(classes: 'mt-4', [
                    Button(
                      variant: ButtonVariant.outline,
                      size: ButtonSize.sm,
                      onPressed: _loadPreviewData,
                      children: [text('Retry')],
                    ),
                  ]),
                ]),
              ]),
            ],
          ),
        ],
      );
    }

    if (_sampleData.isEmpty) {
      return CardContent(
        children: [
          div(classes: 'p-8 text-center', [
            div(classes: 'text-neutral-400 mb-4', [
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
            h3(classes: 'text-sm font-medium text-neutral-900 mb-2', [
              text('No data available'),
            ]),
            p(classes: 'text-sm text-neutral-500', [
              text(
                'This data source appears to be empty or contains no accessible data.',
              ),
            ]),
          ]),
        ],
      );
    }

    return CardContent(
      children: [
        div(classes: 'overflow-x-auto', [
          table(classes: 'min-w-full divide-y divide-neutral-200', [
            _buildTableHeader(),
            _buildTableBody(),
          ]),
        ]),
      ],
    );
  }

  Component _buildTableHeader() {
    final columns = _sampleData.isNotEmpty
        ? _sampleData.first.keys.toList()
        : <String>[];

    return thead(classes: 'bg-neutral-50', [
      tr([
        if (component.showRowNumbers)
          th(
            classes:
                'px-6 py-3 text-left text-xs font-medium text-neutral-500 uppercase tracking-wider bg-neutral-100',
            [text('#')],
          ),
        for (final column in columns)
          th(
            classes:
                'px-6 py-3 text-left text-xs font-medium text-neutral-500 uppercase tracking-wider',
            [
              div(classes: 'flex flex-col space-y-2', [
                span(classes: 'font-medium text-neutral-900', [text(column)]),
                if (component.showDataTypes && _schema.containsKey(column))
                  Badge(
                    variant: BadgeVariant.outline,
                    className: 'text-xs w-fit',
                    children: [text(_getDisplayType(_schema[column]!))],
                  ),
              ]),
            ],
          ),
      ]),
    ]);
  }

  Component _buildTableBody() {
    return tbody(classes: 'bg-white divide-y divide-neutral-200', [
      for (int index = 0; index < _sampleData.length; index++)
        _buildTableRow(_sampleData[index], index),
    ]);
  }

  Component _buildTableRow(Map<String, dynamic> row, int index) {
    return tr(classes: index % 2 == 0 ? 'bg-white' : 'bg-neutral-50', [
      if (component.showRowNumbers)
        td(
          classes:
              'px-6 py-4 whitespace-nowrap text-sm font-medium text-neutral-500 bg-neutral-100',
          [text('${index + 1}')],
        ),
      for (final entry in row.entries)
        td(classes: 'px-6 py-4 whitespace-nowrap text-sm text-neutral-900', [
          _buildCellContent(entry.value, entry.key),
        ]),
    ]);
  }

  Component _buildCellContent(dynamic value, String columnName) {
    if (value == null) {
      return Badge(
        variant: BadgeVariant.outline,
        className: 'text-neutral-400 italic',
        children: [text('null')],
      );
    }

    final stringValue = value.toString();
    final fieldType = _schema[columnName];

    // Truncate long values
    final displayValue = stringValue.length > 50
        ? '${stringValue.substring(0, 47)}...'
        : stringValue;

    // Style based on data type
    final cellClasses = StringBuffer('font-mono text-sm');

    switch (fieldType) {
      case 'integer':
        cellClasses.write(' text-primary-600');
      case 'real':
        cellClasses.write(' text-green-600');
      case 'boolean':
        cellClasses.write(' text-purple-600');
      case 'date':
      case 'datetime':
        cellClasses.write(' text-indigo-600');
      default:
        cellClasses.write(' text-neutral-900');
    }

    final cellContent = span(classes: cellClasses.toString(), [
      text(displayValue),
    ]);

    // Wrap with tooltip if value is truncated
    if (stringValue.length > 50) {
      return Tooltip(content: stringValue, child: cellContent);
    }

    return cellContent;
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
