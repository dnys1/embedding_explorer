import 'dart:convert';
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

    final tailwindConfig = AssetId(
      buildStep.inputId.package,
      'web/tailwind.config.js',
    );
    await buildStep.canRead(tailwindConfig);
    await scratchSpace.ensureAssets({
      buildStep.inputId,
      AssetId(buildStep.inputId.package, 'web/package.json'),
      AssetId(buildStep.inputId.package, 'web/pnpm-lock.yaml'),
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

    final webDir = scratchSpace.tempDir.uri.resolve('web/').toFilePath();

    await _runProcess('pnpm', ['install'], workingDirectory: webDir);
    await _runProcess('npx', [
      '@tailwindcss/cli',
      '--input',
      scratchSpace.fileFor(buildStep.inputId).path,
      '--output',
      scratchSpace.fileFor(outputId).path,
    ], workingDirectory: webDir);

    await scratchSpace.copyOutput(outputId, buildStep);
  }

  Future<void> _runProcess(
    String executable,
    List<String> args, {
    String? workingDirectory,
  }) async {
    final process = await Process.start(
      executable,
      args,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    final buffer = StringBuffer();
    final stdoutFuture = process.stdout
        .transform(utf8.decoder)
        .forEach(buffer.write);
    final stderrFuture = process.stderr
        .transform(utf8.decoder)
        .forEach(buffer.write);

    final exitCode = await process.exitCode;
    await stdoutFuture;
    await stderrFuture;

    if (exitCode != 0) {
      throw ProcessException(
        executable,
        args,
        'Process exited with code $exitCode:\n$buffer',
        exitCode,
      );
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    'web/{{file}}.tw.css': ['web/{{file}}.css'],
  };
}
