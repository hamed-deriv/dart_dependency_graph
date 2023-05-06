import 'dart:io';

import 'package:dart_dependency_graph/src/base_dependency_graph.dart';
import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

class BlocDependencyGraph implements BaseDependencyGraph {
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
    final RegExp cubitOrBlocClassPattern = RegExp(r'class\s+(\w+(Cubit|Bloc))');
    final RegExp stateListenerClassPattern = RegExp(r'(\w+StateListener)');

    final String fileContent = File(path).readAsStringSync();

    final List<ClassStructureModel> result = <ClassStructureModel>[];

    final Iterable<String?> classes = cubitOrBlocClassPattern
        .allMatches(fileContent)
        .map((RegExpMatch match) => match.group(1));

    final Iterable<String?> listeners = stateListenerClassPattern
        .allMatches(fileContent)
        .map((RegExpMatch match) => match.group(1));

    String className = '';
    final List<String> listenerNames = <String>[];

    for (final String? name in classes) {
      className = name!;
    }

    for (final String? listenerName in listeners) {
      listenerNames.add(listenerName!);
    }

    if (_isValidCubit(className, listenerNames)) {
      result.add(
        ClassStructureModel(
          type: ClassType.concreteClass,
          name: className,
          interfaces: listenerNames
              .map((String element) =>
                  element.replaceAll('StateListener', 'Cubit'))
              .toList(),
        ),
      );
    }

    return result;
  }

  @override
  String getGraph(List<ClassStructureModel> classStructures) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('digraph {');
    buffer.writeln('  rankdir=LR;');

    for (final ClassStructureModel classStructure in classStructures) {
      buffer.writeln('  ${classStructure.name} [shape=box];');

      if (classStructure.interfaces != null) {
        for (final String listenerName in classStructure.interfaces!) {
          buffer.writeln('  ${classStructure.name} -> $listenerName;');
        }
      }
    }

    buffer.writeln('}');

    return '$buffer';
  }

  @override
  Future<void> generateOutput(List<ClassStructureModel> classStructures) async {
    File('bloc_dependency_graph.dot')
        .writeAsStringSync(getGraph(classStructures));

    await Process.run(
      'dot',
      <String>[
        '-Tsvg',
        'bloc_dependency_graph.dot',
        '-o',
        'bloc_dependency_graph.svg',
      ],
    );
  }

  bool _isValidCubit(String className, List<String> listenerNames) =>
      className.isNotEmpty &&
      className.startsWith(RegExp(r'^(?!(Fake|Mock|_))\w+'));
}
