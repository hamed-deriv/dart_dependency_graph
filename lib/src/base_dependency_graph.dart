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

  String getGraph(List<ClassStructureModel> classStructures);

  Future<void> generateOutput(List<ClassStructureModel> structure) async {
    final String name = '${runtimeType}DependencyGraph';

    File('$name.dot').writeAsStringSync(getGraph(structure));

    await Process.run('dot', <String>['-Tsvg', '$name.dot', '-o', '$name.svg']);
  }
}
