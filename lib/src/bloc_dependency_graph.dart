import 'dart:io';

import 'package:dart_dependency_graph/src/base_dependency_graph.dart';
import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

class BlocDependencyGraph extends BaseDependencyGraph {
  factory BlocDependencyGraph() => _instance;

  BlocDependencyGraph._internal();

  static final BlocDependencyGraph _instance = BlocDependencyGraph._internal();

  @override
  List<ClassStructureModel> parseFile(String path) {
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

  bool _isValidCubit(String className, List<String> listenerNames) =>
      className.isNotEmpty &&
      className.startsWith(RegExp(r'^(?!(Fake|Mock|_))\w+'));
}
