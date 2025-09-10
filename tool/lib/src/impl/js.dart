// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';

import '../types.dart';
import 'common.dart';

/// {@template worker_bee_builder.vm_generator}
/// Generates the JS implementation of a worker bee.
/// {@endtemplate}
class JsGenerator extends ImplGenerator {
  /// {@macro worker_bee_builder.vm_generator}
  JsGenerator(
    super.classEl,
    super.requestTypeEl,
    super.responseTypeEl, {
    required this.declaresJsEntrypoint,
    required this.declaresFallbackUrls,
    required this.hiveEntrypointId,
  });

  /// Whether the base implementation overrides `jsEntrypoint`, in which case
  /// we should not generate it.
  final bool declaresJsEntrypoint;

  /// Whether the base implementation overrides `fallbackUrls`, in which case
  /// we should not generate it.
  final bool declaresFallbackUrls;

  /// The ID/location of the hive entrypoint, used to generate paths correctly.
  final AssetId hiveEntrypointId;

  @override
  Library generate() {
    return Library((b) => b..body.addAll([_workerClass]));
  }

  late final _packageName = hiveEntrypointId.package;

  late final _workersJs = hiveEntrypointId.changeExtension('.js');
  late final _workersJsPath =
      'packages/$_packageName/${_workersJs.path.replaceFirst('lib/', '')}';

  Code get _jsEntrypoint {
    return Code('''
// Default to the compiled, published worker.
return '$_workersJsPath';
''');
  }

  Code get _fallbackUrls {
    return Block.of([
      const Code('''
    // When running in a test, we need to find the `packages` directory which
    // is symlinked in the root `test/` directory.
    final baseUri = Uri.base;
    final basePath = baseUri.pathSegments
        .takeWhile((segment) => segment != 'test')
        .map(Uri.encodeComponent)
        .join('/');'''),
      declareConst(
        'relativePath',
      ).assign(literalString(_workersJsPath)).statement,
      const Code(r'''
    final testRelativePath = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '$basePath/test/$relativePath',
    ).toString();'''),
      literalList([
        refer('relativePath'),
        refer('testRelativePath'),
      ]).returned.statement,
    ]);
  }

  Class get _workerClass => Class(
    (c) => c
      ..name = workerImplName
      ..docs.add('/// The JS implementation of [${workerType.symbol}].')
      ..extend = refer(workerName)
      ..methods.addAll([
        Method(
          (m) => m
            ..annotations.add(DartTypes.core.override)
            ..returns = DartTypes.core.string
            ..type = MethodType.getter
            ..name = 'name'
            ..body = literalString(workerName).code,
        ),
        if (!declaresJsEntrypoint)
          Method(
            (m) => m
              ..annotations.add(DartTypes.core.override)
              ..returns = DartTypes.core.string
              ..type = MethodType.getter
              ..name = 'jsEntrypoint'
              ..body = _jsEntrypoint,
          ),
        if (!declaresFallbackUrls)
          Method(
            (m) => m
              ..annotations.add(DartTypes.core.override)
              ..returns = DartTypes.core.list(DartTypes.core.string)
              ..type = MethodType.getter
              ..name = 'fallbackUrls'
              ..body = _fallbackUrls,
          ),
      ]),
  );
}
