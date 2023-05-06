import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

void main(List<String> arguments) {
  final Directory directory = Directory(arguments.first);
  final RegExp cubitOrBlocClassPattern = RegExp(r'class\s+(\w+(Cubit|Bloc))');
  final RegExp stateListenerClassPattern = RegExp(r'(\w+StateListener)');

  final List<ClassStructureModel> dependencies = <ClassStructureModel>[];

  for (final File file in _findDartFiles(directory)) {
    final String content = file.readAsStringSync();
    final Iterable<String?> classes = cubitOrBlocClassPattern
        .allMatches(content)
        .map((RegExpMatch match) => match.group(1));

    final Iterable<String?> listeners = stateListenerClassPattern
        .allMatches(content)
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
      dependencies.add(
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
  }

  print(printGraph(dependencies));
}

bool _isValidCubit(String className, List<String> listenerNames) =>
    className.isNotEmpty &&
    className.startsWith(RegExp(r'^(?!(Fake|Mock|_))\w+'));

List<File> _findDartFiles(Directory directory) => directory
    .listSync(recursive: true)
    .where((FileSystemEntity entity) =>
        entity is File && path.extension(entity.path) == '.dart')
    .cast<File>()
    .toList();

String printGraph(List<ClassStructureModel> dependencies) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('digraph {');
  buffer.writeln('  rankdir=LR;');

  for (final ClassStructureModel dependency in dependencies) {
    buffer.writeln('  ${dependency.name} [shape=box];');

    if (dependency.interfaces != null) {
      for (final String listenerName in dependency.interfaces!) {
        buffer.writeln('  ${dependency.name} -> $listenerName;');
      }
    }
  }

  buffer.writeln('}');

  return '$buffer';
}
