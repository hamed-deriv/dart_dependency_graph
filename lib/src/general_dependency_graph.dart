import 'dart:io';

import 'package:dart_dependency_graph/src/base_dependency_graph.dart';
import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

class GeneralDependencyGraph extends BaseDependencyGraph {
  factory GeneralDependencyGraph() => _instance;

  GeneralDependencyGraph._internal();

  static final GeneralDependencyGraph _instance =
      GeneralDependencyGraph._internal();

  @override
  List<ClassStructureModel> parseFile(String path) {
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
}
