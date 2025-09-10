import 'dart:io';

import 'package:build/build.dart';
import 'package:build_modules/build_modules.dart';
import 'package:glob/glob.dart';

Builder buildTailwind(BuilderOptions options) => TailwindBuilder(options);

class TailwindBuilder implements Builder {
  final BuilderOptions options;

  TailwindBuilder(this.options);

  @override
  Future<void> build(BuildStep buildStep) async {
    final scratchSpace = await buildStep.fetchResource(scratchSpaceResource);

    final nodeModules = await buildStep
        .findAssets(Glob('web/node_modules/**'))
        .toList();
    final tailwindConfig = AssetId(
      buildStep.inputId.package,
      'web/tailwind.config.js',
    );
    await buildStep.canRead(tailwindConfig);
    await scratchSpace.ensureAssets({
      buildStep.inputId,
      ...nodeModules,
      AssetId(buildStep.inputId.package, 'web/package.json'),
      tailwindConfig,
    }, buildStep);

    final outputId = buildStep.inputId
        .changeExtension('')
        .changeExtension('.css');

    // in order to rebuild when source files change
    final assets = await buildStep
        .findAssets(Glob('{lib,web}/**.dart'))
        .toList();
    await Future.wait(assets.map((a) => buildStep.canRead(a)));
    await scratchSpace.ensureAssets(assets.toSet(), buildStep);

    final args = <String>[
      '--input',
      scratchSpace.fileFor(buildStep.inputId).path,
      '--output',
      scratchSpace.fileFor(outputId).path,
    ];
    final result = await Process.run('tailwindcss', args);

    if (result.exitCode != 0) {
      final errorOutput = StringBuffer();
      errorOutput.writeln('Error running tailwindcss (${result.exitCode}):');
      if (result.stdout != null && (result.stdout as String).isNotEmpty) {
        errorOutput.writeln('STDOUT:');
        errorOutput.writeln(result.stdout);
      }
      if (result.stderr != null && (result.stderr as String).isNotEmpty) {
        errorOutput.writeln('STDERR:');
        errorOutput.writeln(result.stderr);
      }
      throw StateError(errorOutput.toString());
    }

    await scratchSpace.copyOutput(outputId, buildStep);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    'web/{{file}}.tw.css': ['web/{{file}}.css'],
  };
}
