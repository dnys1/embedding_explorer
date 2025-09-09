import 'package:jaspr/browser.dart';

abstract class ChangeNotifierX with ChangeNotifier {
  var _disposed = false;

  void setState(VoidCallback fn) {
    if (_disposed) return;
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
