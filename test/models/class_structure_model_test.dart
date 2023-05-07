import 'package:test/test.dart';

import 'package:dart_dependency_graph/src/models/class_structure_model.dart';

void main() {
  group('ClassStructureModel test =>', () {
    test('toString() returns correct output.', () {
      final ClassStructureModel model = ClassStructureModel(
        type: ClassType.concreteClass,
        name: 'MyClass',
        superClasse: 'ParentClass',
        interfaces: <String>['Interface1', 'Interface2'],
        mixins: <String>['Mixin1', 'Mixin2'],
      );

      expect(
        '$model',
        equals(
          'name: MyClass type: concreteClass superClass => ParentClass interfaces => [Interface1, Interface2] mixins => [Mixin1, Mixin2]',
        ),
      );
    });

    test('toString() handles null and empty properties.', () {
      final ClassStructureModel model = ClassStructureModel(
        type: ClassType.abstractClass,
        name: 'MyAbstractClass',
      );

      expect('$model', equals('name: MyAbstractClass type: abstractClass'));
    });
  });
}
