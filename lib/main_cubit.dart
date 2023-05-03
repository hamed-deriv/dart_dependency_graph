import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  final directory = Directory(arguments.first);
  final cubitClassPattern = RegExp(r'class\s+(\w+Cubit)');
  final stateListenerClassPattern = RegExp(r'(\w+StateListener)');

  final List<CubitDependency> dependencies = [];

  for (final file in _findDartFiles(directory)) {
    final content = file.readAsStringSync();
    final classes =
        cubitClassPattern.allMatches(content).map((match) => match.group(1));
    final listeners = stateListenerClassPattern
        .allMatches(content)
        .map((match) => match.group(1));

    String className = '';
    List<String> listenerNames = [];

    for (final name in classes) {
      className = name!;
    }

    for (final listenerName in listeners) {
      listenerNames.add(listenerName!);
    }

    if (_isValid(className, listenerNames)) {
      dependencies.add(
        CubitDependency(
          cubitName: className,
          listenerNames: listenerNames
              .map((element) => element.replaceAll('StateListener', 'Cubit'))
              .toList(),
        ),
      );
    }
  }

  print(printAsReadmeGraph(dependencies));
}

bool _isValid(String className, List<String> listenerNames) =>
    className.isNotEmpty &&
    listenerNames.isNotEmpty &&
    className.startsWith(RegExp(r'^(?!(Fake|Mock|_))\w+'));

List<File> _findDartFiles(Directory directory) {
  return directory
      .listSync(recursive: true)
      .where(
          (entity) => entity is File && path.extension(entity.path) == '.dart')
      .cast<File>()
      .toList();
}

String printAsGraph(List<CubitDependency> dependencies) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('digraph {');
  buffer.writeln('  rankdir=LR;');

  for (final dependency in dependencies) {
    buffer.writeln('  ${dependency.cubitName} [shape=box];');

    for (final listenerName in dependency.listenerNames) {
      buffer.writeln('  ${dependency.cubitName} -> $listenerName;');
    }
  }

  buffer.writeln('}');

  return '$buffer';
}

String printAsReadmeGraph(List<CubitDependency> dependencies) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('```mermaid');
  buffer.writeln('graph LR;');

  for (final dependency in dependencies) {
    buffer.writeln('  ${dependency.cubitName}["${dependency.cubitName}"];');

    for (final listenerName in dependency.listenerNames) {
      buffer.writeln('  ${dependency.cubitName} --> $listenerName;');
    }
  }

  buffer.writeln('```');

  return '$buffer';
}

class CubitDependency {
  CubitDependency({
    required this.cubitName,
    required this.listenerNames,
  });

  final String cubitName;
  final List<String> listenerNames;

  @override
  String toString() =>
      'CubitDependency{cubitName: $cubitName, listenerNames: $listenerNames}';
}
