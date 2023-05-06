import 'dart:io';

import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

void main(List<String> arguments) async {
  final List<ClassStructureModel> projectStructure = <ClassStructureModel>[];

  final String path = arguments.first;
  final List<FileSystemEntity> entities = _getAllFiles(path);

  for (final FileSystemEntity entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      projectStructure.addAll(_parseDartFile(entity.path));
    }
  }

  await _generateOutput(projectStructure);
}

List<FileSystemEntity> _getAllFiles(String path) =>
    Directory(path).listSync(recursive: true);

List<ClassStructureModel> _parseDartFile(String path) {
  final List<ClassStructureModel> result = <ClassStructureModel>[];

  final String fileContent = File(path).readAsStringSync();

  final RegExp extractionRegex = RegExp(
    r'(abstract\s+)?(class|extension)\s+(\w+)\s*(extends\s+([\w<>]+))?(?:\s*with\s+([\w,\s]+))?(?:\s*implements\s+([\w,\s]+))?',
    multiLine: true,
  );

  final Iterable<RegExpMatch> matches = extractionRegex.allMatches(fileContent);

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

String _printGraph(List<ClassStructureModel> classStructures) {
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

Future<void> _generateOutput(List<ClassStructureModel> projectStructure) async {
  File('dependency_graph.dot').writeAsStringSync(_printGraph(projectStructure));

  await Process.run(
    'dot',
    <String>['-Tpng', 'dependency_graph.dot', '-o', 'dependency_graph.png'],
  );
}
