import 'dart:io';

import 'package:dart_dependency_graph/general_dependency_graph.dart';
import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

void main(List<String> arguments) async {
  final List<ClassStructureModel> projectStructure = <ClassStructureModel>[];

  final List<FileSystemEntity> entities =
      GeneralDependencyGraph().getAllFiles(arguments.first);

  for (final FileSystemEntity entity in entities) {
    projectStructure
        .addAll(GeneralDependencyGraph().parseDartFile(entity.path));
  }

  await GeneralDependencyGraph().generateOutput(projectStructure);
}
