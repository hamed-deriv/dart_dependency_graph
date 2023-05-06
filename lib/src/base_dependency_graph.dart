import 'dart:io';

import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

abstract class BaseDependencyGraph {
  List<FileSystemEntity> getAllFiles(String path);

  List<ClassStructureModel> parseDartFile(String path);

  String getGraph(List<ClassStructureModel> classStructures);

  Future<void> generateOutput();
}
