import 'dart:io';

final _forbiddenImport = RegExp(
  r'''^\s*(?:import|export)\s+['"](?:package:flutter/|dart:ui(?:/|['"]))''',
  multiLine: true,
);

void main() {
  final violations = <String>[];
  for (final entity in Directory('examples').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll('\\', '/');
    if (!path.contains('/lib/') && !path.contains('/benchmark/')) continue;
    final source = entity.readAsStringSync();
    if (_forbiddenImport.hasMatch(source)) violations.add(path);
  }

  if (violations.isNotEmpty) {
    stderr.writeln('FFrame application source must use FFrame APIs only:');
    for (final path in violations) {
      stderr.writeln('  $path');
    }
    exitCode = 1;
    return;
  }
  stdout
      .writeln('FFrame API import policy passed for example application code.');
}
