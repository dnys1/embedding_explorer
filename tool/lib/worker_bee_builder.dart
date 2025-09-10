// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Builder definitons for `worker_bee_builder`.
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:worker_bee/worker_bee.dart';

import 'src/copy_builder.dart';
import 'src/hive_generator.dart';
import 'src/worker_generator.dart';

/// Generates platform-specific boilerplate for [WorkerBee]-annotated classes.
Builder workerBeeBuilder(BuilderOptions options) =>
    SharedPartBuilder([WorkerBeeGenerator()], 'worker_bee');

/// Generates Hive definitions for packages with multiple worker bee types.
Builder workerHiveBuilder(BuilderOptions options) => LibraryBuilder(
  WorkerHiveGenerator(),
  generatedExtension: '.debug.dart',
  additionalOutputExtensions: ['.release.dart'],
  options: options,
);

/// Copies generated JS artifacts to `lib/` for publishing.
Builder workerCopyBuilder(BuilderOptions options) => WorkerCopyBuilder();
