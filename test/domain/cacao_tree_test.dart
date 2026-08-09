import 'package:cakobean/domain/models/cacao_tree.dart';
import 'package:test/test.dart';

void main() {
  group('TreeStatus', () {
    test('every status round-trips through its name', () {
      for (final status in TreeStatus.values) {
        expect(
          TreeStatus.values.asNameMap()[status.name],
          status,
          reason: '${status.name} should parse back to itself',
        );
      }
    });

    test('unknown status name resolves to healthy', () {
      expect(TreeStatus.values.asNameMap()['not-a-status'], isNull);
    });
  });

  group('CacaoTree', () {
    final tree = CacaoTree(
      id: 't1',
      farmId: 'f1',
      name: 'Tree 1',
      variety: 'UF18',
      status: TreeStatus.healthy,
      createdAt: DateTime(2025, 1, 1),
    );

    test('copyWith keeps id, farmId and createdAt', () {
      final updated = tree.copyWith(name: 'Tree 2', status: TreeStatus.fruiting);
      expect(updated.id, 't1');
      expect(updated.farmId, 'f1');
      expect(updated.createdAt, tree.createdAt);
      expect(updated.name, 'Tree 2');
      expect(updated.status, TreeStatus.fruiting);
    });

    test('copyWith preserves unspecified fields', () {
      final updated = tree.copyWith(status: TreeStatus.dormant);
      expect(updated.name, 'Tree 1');
      expect(updated.variety, 'UF18');
      expect(updated.plantedOn, isNull);
    });
  });
}
