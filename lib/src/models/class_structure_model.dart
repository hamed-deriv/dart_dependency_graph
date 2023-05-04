
class ClassStructureModel {
  ClassStructureModel({
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
