import 'package:jaspr/browser.dart';

abstract class ChangeNotifierX with ChangeNotifier {
  var _disposed = false;
  bool get disposed => _disposed;

  void setState(VoidCallback fn) {
    if (_disposed) return;
    fn();
    notifyListeners();
  }

  final List<VoidCallback> _onDisposeCallbacks = [];

  void onDispose(VoidCallback callback) {
    if (!_disposed) {
      _onDisposeCallbacks.add(callback);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final callback in _onDisposeCallbacks) {
      callback();
    }
    super.dispose();
  }
}
