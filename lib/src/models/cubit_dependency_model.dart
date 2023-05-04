class CubitDependencyModel {
  CubitDependencyModel({
    required this.cubitName,
    required this.listenerNames,
  });

  final String cubitName;
  final List<String> listenerNames;

  @override
  String toString() =>
      'CubitDependency{cubitName: $cubitName, listenerNames: $listenerNames}';
}
