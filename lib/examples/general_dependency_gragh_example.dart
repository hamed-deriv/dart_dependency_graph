import 'dart:io';

import 'package:dart_dependency_graph/general_dependency_gragh.dart';
import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

void main(List<String> arguments) async {
  final List<ClassStructureModel> projectStructure = <ClassStructureModel>[];

  final String path = arguments.first;
  final List<FileSystemEntity> entities =
      GeneralDependencyGraph().getAllFiles(path);

  for (final FileSystemEntity entity in entities) {
    projectStructure
        .addAll(GeneralDependencyGraph().parseDartFile(entity.path));
  }

  await GeneralDependencyGraph().generateOutput(projectStructure);
}
