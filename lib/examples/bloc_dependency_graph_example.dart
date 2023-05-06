import 'dart:io';

import 'package:dart_dependency_graph/src/bloc_dependency_graph.dart';
import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

void main(List<String> arguments) async {
  final List<ClassStructureModel> projectStructure = <ClassStructureModel>[];

  final List<FileSystemEntity> entities =
      BlocDependencyGraph().getAllFiles(arguments.first);

  for (final FileSystemEntity entity in entities) {
    projectStructure.addAll(BlocDependencyGraph().parseFile(entity.path));
  }

  await BlocDependencyGraph().generateOutput(projectStructure);
}
