import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  final directory = Directory(arguments.first);
  final cubitClassPattern = RegExp(r'class\s+(\w+Cubit)\b');
  final stateListenerClassPattern = RegExp(r'(\w+StateListener)\b');

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

    if (className.isNotEmpty &&
        className.startsWith(RegExp(r'^(?!(Fake|Mock|_))\w+')) &&
        listenerNames.isNotEmpty) {
      dependencies.add(
        CubitDependency(
          cubitName: className,
          listenerNames: listenerNames
              .map((e) => e.replaceAll('StateListener', 'Cubit'))
              .toList(),
        ),
      );
    }
  }

  print(printAsGraph(dependencies));
}

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
