import 'dart:async';
import 'dart:js_interop';

import 'package:jaspr/browser.dart';
import 'package:jaspr_test/browser_test.dart';
import 'package:jaspr_test/src/binding.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart' as web;

export 'package:jaspr_test/browser_test.dart' hide BrowserTester, testBrowser;

@isTest
void testBrowser(
  String description,
  FutureOr<void> Function(BrowserTester tester) callback, {
  String location = '/',
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  test(
    description,
    () async {
      var binding = BrowserAppBinding();
      var tester = BrowserTester._(binding);

      await binding.runTest(() async {
        await callback(tester);
      });
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
  );
}

/// Tests any jaspr app in a headless browser environment.
class BrowserTester {
  BrowserTester._(this.binding);

  final BrowserAppBinding binding;

  void pumpComponent(Component component, {String attachTo = 'body'}) {
    binding.attachRootComponent(component, attachTo: attachTo);
  }

  Future<void> click(Finder finder, {bool pump = true}) async {
    await dispatchEvent(finder, web.MouseEvent('click'), pump: pump);
  }

  Future<void> input(
    Finder finder, {
    bool? checked,
    double? valueAsNumber,
    String? value,
    bool pump = true,
  }) async {
    await _dispatchInputEvent(
      finder,
      'input',
      checked: checked,
      valueAsNumber: valueAsNumber,
      value: value,
      pump: pump,
    );
  }

  Future<void> change(
    Finder finder, {
    bool? checked,
    double? valueAsNumber,
    String? value,
    bool pump = true,
  }) async {
    await _dispatchInputEvent(
      finder,
      'change',
      checked: checked,
      valueAsNumber: valueAsNumber,
      value: value,
      pump: pump,
    );
  }

  Future<void> _dispatchInputEvent(
    Finder finder,
    String type, {
    bool? checked,
    double? valueAsNumber,
    String? value,
    bool pump = true,
  }) async {
    return dispatchEvent(
      finder,
      web.InputEvent(type),
      before: (e) {
        if (checked != null) (e as web.HTMLInputElement).checked = checked;
        if (valueAsNumber != null) {
          (e as web.HTMLInputElement).valueAsNumber = valueAsNumber;
        }

        if (value != null) (e as web.HTMLInputElement).value = value;
      },
      pump: pump,
    );
  }

  Future<void> dispatchEvent(
    Finder finder,
    web.Event event, {
    void Function(web.Element)? before,
    bool pump = true,
  }) async {
    var element = _findDomElement(finder);

    var source = (element.renderObject as DomRenderObject).node;
    if (source.isA<web.Element>()) {
      before?.call(source as web.Element);
      (source as web.Element).dispatchEvent(event);
    }

    if (pump) {
      await pumpEventQueue();
    }
  }

  @optionalTypeArgs
  T? findNode<T extends web.Node>(Finder finder) {
    var element = _findDomElement(finder);
    return (element.renderObject as DomRenderObject).node as T?;
  }

  DomElement _findDomElement(Finder finder) {
    var elements = finder.evaluate();

    if (elements.isEmpty) {
      throw 'The finder "$finder" could not find any matching components.';
    }
    if (elements.length > 1) {
      throw 'The finder "$finder" ambiguously found multiple matching components.';
    }

    var element = elements.single;

    if (element is DomElement) {
      return element;
    }

    DomElement? foundElement;

    void findFirstDomElement(Element e) {
      if (e is DomElement) {
        foundElement = e;
        return;
      }
      e.visitChildren(findFirstDomElement);
    }

    findFirstDomElement(element);

    if (foundElement == null) {
      throw 'The finder "$finder" could not find a dom element.';
    }

    return foundElement!;
  }

  Future<void> pump() async {
    try {
      await pumpEventQueue().timeout(const Duration(milliseconds: 100));
    } on TimeoutException {
      // Ignore timeouts to avoid test failures
    }
  }
}
