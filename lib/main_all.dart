import 'dart:io';

void main(List<String> arguments) {
  final List<DartClassStructure> result = [];

  String path = arguments.first;
  Directory dir = Directory(path);
  List<FileSystemEntity> entities = dir.listSync(recursive: true);

  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      result.addAll(parseDartFile(entity.path));
    }
  }

  print(printGraph(result));
}

String printGraph(List<DartClassStructure> classStructures) {
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('digraph G {');
  buffer.writeln('  rankdir=LR;');

  for (final classStructure in classStructures) {
    buffer.writeln(
      '  ${classStructure.name} [shape=${classStructure.type == ClassType.abstractClass ? 'doubleoctagon' : 'rectangle'}];',
    );

    if (classStructure.superClasse != null) {
      buffer.writeln(
        '  ${classStructure.name} -> ${classStructure.superClasse};',
      );
    }

    if (classStructure.interfaces != null &&
        classStructure.interfaces!.isNotEmpty) {
      for (final interface in classStructure.interfaces!) {
        buffer.writeln(
          '  ${classStructure.name} -> $interface [style=dashed, arrowhead=empty];',
        );
      }
    }

    if (classStructure.mixins != null && classStructure.mixins!.isNotEmpty) {
      for (final mixin in classStructure.mixins!) {
        buffer.writeln(
          '  ${classStructure.name} -> $mixin [style=dashed, arrowhead=empty];',
        );
      }
    }
  }

  buffer.writeln('}');

  return '$buffer';
}

List<DartClassStructure> parseDartFile(String path) {
  final List<DartClassStructure> result = [];

  var fileContent = File(path).readAsStringSync();

  final regex = RegExp(
    r'(abstract\s+)?(class|extension)\s+(\w+)\s*(extends\s+([\w<>]+))?(?:\s*with\s+([\w,<>\s]+))?(?:\s*implements\s+([\w,<>\s]+))?',
    multiLine: true,
  );

  final matches = regex.allMatches(fileContent);

  for (final match in matches) {
    final isAbstract = match.group(1) != null;
    final className = match.group(3);
    final superClass = match.group(5);
    final mixins = match.group(6);
    final interfaces = match.group(7);

    result.add(
      DartClassStructure(
        type: isAbstract ? ClassType.abstractClass : ClassType.concreteClass,
        name: className!,
        superClasse: superClass?.replaceAll('>', '').replaceAll('<', ''),
        interfaces: interfaces
            ?.split(',')
            .map((item) => item.trim().replaceAll('>', '').replaceAll('<', ''))
            .toList(),
        mixins: mixins
            ?.split(',')
            .map((item) => item.trim().replaceAll('>', '').replaceAll('<', ''))
            .toList(),
      ),
    );
  }

  return result;
}

class DartClassStructure {
  DartClassStructure({
    required this.type,
    required this.name,
    this.superClasse,
    this.interfaces,
    this.mixins,
  });

  final ClassType type;
  final String name;
  final String? superClasse;
  final List<String>? interfaces;
  final List<String>? mixins;

  @override
  String toString() =>
      'name: $name, type: ${type.name}, ${superClasse != null ? 'superClass => $superClasse, ' : ''}${interfaces != null ? 'interfaces => $interfaces, ' : ''}${mixins != null ? 'mixins => $mixins' : ''}';
}

enum ClassType {
  concreteClass,
  abstractClass,
}
