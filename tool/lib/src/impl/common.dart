// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:code_builder/code_builder.dart';

import '../type_visitor.dart';
import '../types.dart';

/// The platform target.
enum Target {
  /// VM (non-Web) target
  vm,

  /// Web target
  js,
}

/// {@template worker_bee_builder.worker_impl}
/// A [target]-specific implementation of a worker.
/// {@endtemplate}
class WorkerImpl {
  /// {@macro worker_bee_builder.worker_impl}
  const WorkerImpl(this.target, this.impl);

  /// The [target] platform.
  final Target target;

  /// The implementation code.
  final String impl;
}

/// {@template worker_bee_builder.impl_generator}
/// Base class for Worker Bee implementation generators.
/// {@endtemplate}
abstract class ImplGenerator {
  /// {@macro worker_bee_builder.impl_generator}
  ImplGenerator(this.workerEl, this.requestEl, this.responseEl) {
    workerName = workerEl.name3!;
    workerImplName = '_\$$workerName';
    workerType = Reference(workerName, workerEl.library2.uri.toString());
    _checkCtors(workerEl.constructors2);

    requestType = requestEl.thisType.accept(symbolVisitor);
    responseType =
        responseEl?.thisType.accept(symbolVisitor) ?? DartTypes.core.void$;
  }

  void _checkCtors(List<ConstructorElement2> ctors) {
    var hasUnnamed = false;
    var hasCreate = false;
    for (final ctor in ctors) {
      if (ctor.isDefaultConstructor) {
        hasUnnamed = true;
        continue;
      }
      if (ctor.name3 == 'create' && ctor.isFactory) {
        hasCreate = true;
        continue;
      }
    }

    if (!hasUnnamed || !hasCreate) {
      throw ArgumentError(
        'Constructors must follow the pattern:\n'
        '$workerName();\n'
        'factory $workerName.create() = $workerImplName;',
      );
    }
  }

  /// Common symbol visitor instance.
  static const symbolVisitor = SymbolVisitor();

  /// The class element of the user-defined worker.
  final ClassElement2 workerEl;

  /// The class element of the request type of the worker.
  final ClassElement requestEl;

  /// The class element of the response type of the worker, if any.
  final ClassElement? responseEl;

  /// The name of the worker class.
  late final String workerName;

  /// The name of the to-be-generated implementation class.
  late final String workerImplName;

  /// The `code_builder` type of [workerEl].
  late final Reference workerType;

  /// The `code_builder` type of [requestEl].
  late final Reference requestType;

  /// The `code_builder` type of [responseEl].
  late final Reference responseType;

  /// Generates the library representing the worker bee implementation and
  /// supporting items.
  Library generate();
}
