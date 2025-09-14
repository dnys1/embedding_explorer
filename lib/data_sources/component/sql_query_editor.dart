import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../../common/ui/ui.dart';
import '../service/sqlite_data_source.dart';

/// A component for editing and applying SQL queries to SQLite data sources
///
/// Provides a text area for SQL input, error handling, and apply functionality
/// with loading states and user feedback.
class SqlQueryEditor extends StatefulComponent {
  final SqliteDataSource dataSource;
  final void Function()? onQueryApplied;
  final void Function(String error)? onError;

  const SqlQueryEditor({
    required this.dataSource,
    this.onQueryApplied,
    this.onError,
    super.key,
  });

  @override
  State<SqlQueryEditor> createState() => _SqlQueryEditorState();
}

class _SqlQueryEditorState extends State<SqlQueryEditor> {
  String _sqlQuery = '';
  bool _isApplyingQuery = false;
  String? _queryError;

  static final Logger _logger = Logger('SqlQueryEditor');

  @override
  void initState() {
    super.initState();
    _sqlQuery = component.dataSource.sqlQuery;
    _logger.finest(
      'SqlQueryEditor initialized with query: ${_sqlQuery.length} chars',
    );
  }

  @override
  Component build(BuildContext context) {
    return Card(
      children: [
        CardHeader(
          children: [
            CardTitle(children: [text('SQL Query Editor')]),
            CardDescription(
              children: [
                text(
                  'Customize the data by writing SQL queries. You can use JOINs, WHERE clauses, and other SQL features.',
                ),
              ],
            ),
          ],
        ),
        CardContent(
          children: [
            div(classes: 'space-y-4', [
              div(classes: 'space-y-2', [
                Label(children: [text('SQL Query')]),
                Textarea(
                  placeholder:
                      'SELECT * FROM table_name\nWHERE condition = value\nORDER BY column',
                  value: _sqlQuery,
                  onInput: _updateQuery,
                  className: 'min-h-[120px] font-mono text-sm',
                ),
              ]),

              // Show query-specific error if present
              if (_queryError != null)
                Alert(
                  variant: AlertVariant.destructive,
                  children: [
                    AlertTitle(children: [text('SQL Error')]),
                    AlertDescription(children: [text(_queryError!)]),
                  ],
                ),

              // Action buttons
              div(classes: 'flex items-center justify-between', [
                if (_sqlQuery.isNotEmpty &&
                    _sqlQuery != component.dataSource.sqlQuery)
                  Button(
                    variant: ButtonVariant.primary,
                    size: ButtonSize.sm,
                    disabled: _isApplyingQuery,
                    onPressed: _isApplyingQuery ? null : _applySqlQuery,
                    children: [
                      if (_isApplyingQuery) ...[
                        Skeleton(className: 'h-4 w-4 rounded-full mr-2'),
                        text('Applying...'),
                      ] else
                        text('Apply Query'),
                    ],
                  ),
              ]),
            ]),
          ],
        ),
      ],
    );
  }

  Future<void> _applySqlQuery() async {
    if (_sqlQuery.isEmpty) return;

    _logger.info(
      'Applying SQL query: ${_sqlQuery.substring(0, _sqlQuery.length.clamp(0, 100))}${_sqlQuery.length > 100 ? '...' : ''}',
    );

    setState(() {
      _isApplyingQuery = true;
      _queryError = null;
    });

    try {
      await component.dataSource.setSqlQuery(_sqlQuery);

      setState(() {
        _isApplyingQuery = false;
        _queryError = null;
      });

      _logger.info('SQL query applied successfully');
      component.onQueryApplied?.call();
    } catch (e) {
      final errorMessage = e.toString();
      _logger.warning('Failed to apply SQL query: $errorMessage');

      setState(() {
        _queryError = errorMessage;
        _isApplyingQuery = false;
      });

      component.onError?.call('SQL Error: $errorMessage');
    }
  }

  /// Update the editor with a new query from external source
  void _updateQuery(String newQuery) {
    newQuery = newQuery.trim();
    if (newQuery != _sqlQuery) {
      setState(() {
        _sqlQuery = newQuery;
        _queryError = null;
      });
    }
  }
}
