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

  for (var element in result) {
    print(element);
  }
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
        superClasse: superClass,
        interfaces: interfaces?.split(','),
        mixins: mixins?.split(','),
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
      'name: $name, type: ${type.name}, superClasse: $superClasse, interfaces: $interfaces, mixins: $mixins';
}

enum ClassType {
  concreteClass,
  abstractClass,
}
