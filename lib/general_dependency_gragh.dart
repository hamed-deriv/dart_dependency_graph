import 'dart:io';

import 'package:dart_dependency_graph/src/base_dependency_graph.dart';
import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

class GeneralDependencyGraph implements BaseDependencyGraph {
  factory GeneralDependencyGraph() => _instance;

  GeneralDependencyGraph._internal();

  static final GeneralDependencyGraph _instance =
      GeneralDependencyGraph._internal();

  @override
  List<FileSystemEntity> getAllFiles(String path) => Directory(path)
      .listSync(recursive: true)
      .where(
        (FileSystemEntity entry) =>
            entry is File && entry.path.endsWith('.dart'),
      )
      .toList();

  @override
  List<ClassStructureModel> parseDartFile(String path) {
    final List<ClassStructureModel> result = <ClassStructureModel>[];

    final String fileContent = File(path).readAsStringSync();

    final RegExp extractionRegex = RegExp(
      r'(abstract\s+)?(class|extension)\s+(\w+)\s*(extends\s+([\w<>]+))?(?:\s*with\s+([\w,\s]+))?(?:\s*implements\s+([\w,\s]+))?',
      multiLine: true,
    );

    final Iterable<RegExpMatch> matches =
        extractionRegex.allMatches(fileContent);

    for (final RegExpMatch match in matches) {
      final bool isAbstract = match.group(1) != null;
      final String? className = match.group(3);
      final String? superClass = match.group(5);
      final String? mixins = match.group(6);
      final String? interfaces = match.group(7);

      result.add(
        ClassStructureModel(
          type: isAbstract ? ClassType.abstractClass : ClassType.concreteClass,
          name: className!,
          superClasse: superClass,
          interfaces:
              interfaces?.split(',').map((String item) => item.trim()).toList(),
          mixins: mixins?.split(',').map((String item) => item.trim()).toList(),
        ),
      );
    }

    return result;
  }

  @override
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

  @override
  Future<void> generateOutput(
    List<ClassStructureModel> projectStructure,
  ) async {
    File('dependency_graph.dot').writeAsStringSync(getGraph(projectStructure));

    await Process.run(
      'dot',
      <String>[
        '-Tsvg',
        'dependency_graph.dot',
        '-o',
        'dependency_graph.svg',
      ],
    );
  }
}
