import 'dart:io';

import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

abstract class BaseDependencyGraph {
  List<FileSystemEntity> getAllFiles(String path) => Directory(path)
      .listSync(recursive: true)
      .where(
        (FileSystemEntity entry) =>
            entry is File && entry.path.endsWith('.dart'),
      )
      .toList();

  List<ClassStructureModel> parseFile(String path);

  String getGraph(List<ClassStructureModel> classStructures) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('digraph G {');
    buffer.writeln('  rankdir=LR;');

    for (final ClassStructureModel classStructure in classStructures) {
      buffer.writeln(
        '  ${classStructure.name} [shape=${classStructure.type == ClassType.abstractClass ? 'doubleoctagon' : 'rectangle'}];',
      );

      if (classStructure.superClasse != null) {
        buffer.writeln(
          '  ${classStructure.name} -> ${classStructure.superClasse};',
        );
      }

      if (classStructure.interfaces != null) {
        for (final String interface in classStructure.interfaces!) {
          buffer.writeln(
            '  ${classStructure.name} -> $interface [style=dashed, arrowhead=empty];',
          );
        }
      }

      if (classStructure.mixins != null) {
        for (final String mixin in classStructure.mixins!) {
          buffer.writeln(
            '  ${classStructure.name} -> $mixin [style=dashed, arrowhead=empty];',
          );
        }
      }
    }

    buffer.writeln('}');

    return '$buffer';
  }

  Future<void> generateOutput(List<ClassStructureModel> structure) async {
    final String name = '${runtimeType}DependencyGraph';

    File('$name.dot').writeAsStringSync(getGraph(structure));

    await Process.run('dot', <String>['-Tsvg', '$name.dot', '-o', '$name.svg']);
  }
}
