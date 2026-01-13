import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/infrastructure/repositories/isar_project_repository.dart';

void main() {
  late Isar isar;
  late IsarProjectRepository repository;

  setUp(() async {
    isar = await Isar.open(
      [ProjectSchema],
      directory: '',
      name: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
    repository = IsarProjectRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('IsarProjectRepository', () {
    test('create and findById', () async {
      final project = Project(name: 'Test Project');
      await repository.create(project);

      final found = await repository.findById(project.id);
      expect(found, isNotNull);
      expect(found!.name, 'Test Project');
    });

    test('findByName returns correct project', () async {
      await repository.create(Project(name: 'Alpha'));
      await repository.create(Project(name: 'Beta'));

      final found = await repository.findByName('Beta');
      expect(found, isNotNull);
      expect(found!.name, 'Beta');
    });

    test('findByName returns null for non-existent', () async {
      final found = await repository.findByName('NonExistent');
      expect(found, isNull);
    });

    test('findAll excludes archived by default', () async {
      await repository.create(Project(name: 'Active'));
      final archived = Project(name: 'Archived')..archive();
      await repository.create(archived);

      final projects = await repository.findAll();
      expect(projects.length, 1);
      expect(projects.first.name, 'Active');
    });

    test('findAll includes archived when requested', () async {
      await repository.create(Project(name: 'Active'));
      final archived = Project(name: 'Archived')..archive();
      await repository.create(archived);

      final projects = await repository.findAll(includeArchived: true);
      expect(projects.length, 2);
    });

    test('update persists changes', () async {
      final project = Project(name: 'Original');
      await repository.create(project);

      project.rename('Updated');
      await repository.update(project);

      final found = await repository.findById(project.id);
      expect(found!.name, 'Updated');
    });

    test('delete removes project', () async {
      final project = Project(name: 'ToDelete');
      await repository.create(project);

      await repository.delete(project.id);

      final found = await repository.findById(project.id);
      expect(found, isNull);
    });

    test('name uniqueness is enforced', () async {
      await repository.create(Project(name: 'Unique'));

      // Isar handles duplicate unique index by updating
      final duplicate = Project(name: 'Unique');
      await repository.create(duplicate);

      final all = await repository.findAll(includeArchived: true);
      expect(all.length, 1); // Only one project with this name
    });
  });
}
