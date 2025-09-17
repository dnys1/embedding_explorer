import 'dart:js_interop';

import 'package:async/async.dart';
import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';
import 'package:sqlite3/common.dart' as sqlite3;
import 'package:timing/timing.dart';
import 'package:web/web.dart' as web;

import '../../database/database.dart';
import '../model/outerbase_message.dart';

class ConfigurationViewDataPage extends StatefulComponent {
  const ConfigurationViewDataPage({super.key, required this.configDb});

  final DatabaseHandle configDb;

  @override
  State<ConfigurationViewDataPage> createState() =>
      _ConfigurationViewDataPageState();
}

class _ConfigurationViewDataPageState extends State<ConfigurationViewDataPage> {
  static final Logger _logger = Logger('ConfigurationViewDataPage');

  JSFunction? _messageHandler;

  web.HTMLIFrameElement get _iframe =>
      web.document.querySelector('iframe') as web.HTMLIFrameElement;

  void _postMessage(Object message) {
    _logger.finest('Posting message: $message');
    _iframe.contentWindowCrossOrigin!.postMessage(
      message.jsify(),
      'https://studio.outerbase.com'.toJS,
    );
  }

  @override
  void initState() {
    super.initState();
    context.binding.addPostFrameCallback(() {
      _setupMessageHandlers();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _removeMessageHandlers();
  }

  void _setupMessageHandlers() {
    _messageHandler = (web.MessageEvent event) {
      if (event.origin != 'https://studio.outerbase.com') {
        return;
      }
      final data = event.data.dartify();
      if (data is! Map) {
        _logger.warning('Invalid message format received: $data');
        return;
      }
      _logger.finest('Received message: $data');
      Future<void>(() async {
        switch (data) {
          case {
                'type': final String type,
                'id': final int id,
                'statements': [final String statement],
              } ||
              {
                'type': final String type,
                'id': final int id,
                'statement': final String statement,
              }:
            final result = await Result.capture(_handleQuery(id, statement));
            if (result.isError) {
              _postMessage(
                MessageWrapper(
                  type: type,
                  id: id,
                  error: result.asError!.error.toString(),
                ).toJson(),
              );
            } else {
              final data = result.asValue!.value;
              _postMessage(
                MessageWrapper(
                  type: type,
                  id: id,
                  data: type == 'transaction' ? [data.toJson()] : data.toJson(),
                ).toJson(),
              );
            }
          default:
            _logger.warning('Unknown message type received: ${data['type']}');
        }
      });
    }.toJS;
    web.window.addEventListener('message', _messageHandler!);
  }

  Future<ResultSet> _handleQuery(int id, String statement) async {
    final tracker = AsyncTimeTracker();
    final result =
        await tracker.track(() => component.configDb.select(statement))
            as sqlite3.ResultSet;
    return ResultSet(
      rows: result,
      headers: result.columnNames.map((it) {
        return DriverResultHeader(
          name: it,
          displayName: it,
          originalType: null,
          type: null,
        );
      }).toList(),
      stat: DriverStats(
        rowsAffected: result.length,
        rowsRead: result.length,
        rowsWritten: null,
        queryDurationMs: tracker.duration.inMilliseconds,
      ),
      lastInsertRowid: null,
    );
  }

  void _removeMessageHandlers() {
    if (_messageHandler != null) {
      web.window.removeEventListener('message', _messageHandler!);
      _messageHandler = null;
    }
  }

  @override
  Component build(BuildContext context) {
    return iframe(
      src: 'https://studio.outerbase.com/embed/sqlite',
      classes: 'h-full w-full',
      [],
    );
  }
}
