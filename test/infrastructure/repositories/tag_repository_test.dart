import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/tag.dart';
import 'package:lumen/infrastructure/repositories/isar_tag_repository.dart';

void main() {
  late Isar isar;
  late IsarTagRepository repository;

  setUp(() async {
    isar = await Isar.open(
      [TagSchema],
      directory: '',
      name: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
    repository = IsarTagRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('IsarTagRepository', () {
    test('create and findById', () async {
      final tag = Tag(projectId: 1, name: 'AI');
      await repository.create(tag);

      final found = await repository.findById(tag.id);
      expect(found, isNotNull);
      expect(found!.name, 'ai'); // Normalized
    });

    test('findByName returns correct tag', () async {
      await repository.create(Tag(projectId: 1, name: 'Machine Learning'));

      final found = await repository.findByName(1, 'machine learning');
      expect(found, isNotNull);
      expect(found!.name, 'machine learning');
    });

    test('findByName is case-insensitive', () async {
      await repository.create(Tag(projectId: 1, name: 'AI'));

      final found = await repository.findByName(1, 'AI');
      expect(found, isNotNull);
    });

    test('findByName scopes to project', () async {
      await repository.create(Tag(projectId: 1, name: 'Shared'));
      await repository.create(Tag(projectId: 2, name: 'Shared'));

      final found = await repository.findByName(1, 'Shared');
      expect(found!.projectId, 1);
    });

    test('findByProject returns all tags for project', () async {
      await repository.create(Tag(projectId: 1, name: 'Tag1'));
      await repository.create(Tag(projectId: 2, name: 'Tag2'));
      await repository.create(Tag(projectId: 1, name: 'Tag3'));

      final tags = await repository.findByProject(1);
      expect(tags.length, 2);
      expect(tags.every((t) => t.projectId == 1), true);
    });

    test('findByProject sorts by usage count desc', () async {
      await repository.create(Tag(projectId: 1, name: 'Low', usageCount: 2));
      await repository.create(Tag(projectId: 1, name: 'High', usageCount: 10));
      await repository.create(Tag(projectId: 1, name: 'Mid', usageCount: 5));

      final tags = await repository.findByProject(1);
      expect(tags[0].name, 'high');
      expect(tags[1].name, 'mid');
      expect(tags[2].name, 'low');
    });

    test('update persists changes', () async {
      final tag = Tag(projectId: 1, name: 'Test');
      await repository.create(tag);

      tag.incrementUsage();
      tag.incrementUsage();
      await repository.update(tag);

      final found = await repository.findById(tag.id);
      expect(found!.usageCount, 2);
    });

    test('delete removes tag', () async {
      final tag = Tag(projectId: 1, name: 'Delete');
      await repository.create(tag);

      await repository.delete(tag.id);

      final found = await repository.findById(tag.id);
      expect(found, isNull);
    });

    test('composite unique index enforces project+name uniqueness', () async {
      await repository.create(Tag(projectId: 1, name: 'Unique'));

      // Attempting to create duplicate will update instead
      final duplicate = Tag(projectId: 1, name: 'Unique');
      await repository.create(duplicate);

      final tags = await repository.findByProject(1);
      expect(tags.length, 1);
    });
  });
}
