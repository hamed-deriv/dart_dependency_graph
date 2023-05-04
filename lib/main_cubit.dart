import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:dart_dependency_graph/src/models/cubit_dependency_model.dart';

void main(List<String> arguments) {
  final Directory directory = Directory(arguments.first);
  final RegExp cubitClassPattern = RegExp(r'class\s+(\w+Cubit)');
  final RegExp stateListenerClassPattern = RegExp(r'(\w+StateListener)');

  final List<CubitDependencyModel> dependencies = <CubitDependencyModel>[];

  for (final File file in _findDartFiles(directory)) {
    final String content = file.readAsStringSync();
    final Iterable<String?> classes = cubitClassPattern
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

    if (_isValid(className, listenerNames)) {
      dependencies.add(
        CubitDependencyModel(
          cubitName: className,
          listenerNames: listenerNames
              .map((String element) =>
                  element.replaceAll('StateListener', 'Cubit'))
              .toList(),
        ),
      );
    }
  }

  print(printReadmeGraph(dependencies));
}

bool _isValid(String className, List<String> listenerNames) =>
    className.isNotEmpty &&
    listenerNames.isNotEmpty &&
    className.startsWith(RegExp(r'^(?!(Fake|Mock|_))\w+'));

List<File> _findDartFiles(Directory directory) => directory
    .listSync(recursive: true)
    .where((FileSystemEntity entity) =>
        entity is File && path.extension(entity.path) == '.dart')
    .cast<File>()
    .toList();

String printGraph(List<CubitDependencyModel> dependencies) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('digraph {');
  buffer.writeln('  rankdir=LR;');

  for (final CubitDependencyModel dependency in dependencies) {
    buffer.writeln('  ${dependency.cubitName} [shape=box];');

    for (final String listenerName in dependency.listenerNames) {
      buffer.writeln('  ${dependency.cubitName} -> $listenerName;');
    }
  }

  buffer.writeln('}');

  return '$buffer';
}

String printReadmeGraph(List<CubitDependencyModel> dependencies) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('```mermaid');
  buffer.writeln('graph LR;');

  for (final CubitDependencyModel dependency in dependencies) {
    buffer.writeln('  ${dependency.cubitName}["${dependency.cubitName}"];');

    for (final String listenerName in dependency.listenerNames) {
      buffer.writeln('  ${dependency.cubitName} --> $listenerName;');
    }
  }

  buffer.writeln('```');

  return '$buffer';
}
