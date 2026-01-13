import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/infrastructure/repositories/isar_artifact_repository.dart';

void main() {
  late Isar isar;
  late IsarArtifactRepository repository;

  setUp(() async {
    isar = await Isar.open(
      [ArtifactSchema],
      directory: '',
      name: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );
    repository = IsarArtifactRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('IsarArtifactRepository', () {
    test('create and findById', () async {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Test Note',
        content: 'Content here',
      );
      await repository.create(artifact);

      final found = await repository.findById(artifact.id);
      expect(found, isNotNull);
      expect(found!.title, 'Test Note');
      expect(found.content, 'Content here');
    });

    test('findByProject returns artifacts for project', () async {
      await repository.create(
        Artifact(projectId: 1, type: ArtifactType.note, title: 'P1 Note'),
      );
      await repository.create(
        Artifact(projectId: 2, type: ArtifactType.note, title: 'P2 Note'),
      );
      await repository.create(
        Artifact(projectId: 1, type: ArtifactType.note, title: 'P1 Another'),
      );

      final artifacts = await repository.findByProject(1);
      expect(artifacts.length, 2);
      expect(artifacts.every((a) => a.projectId == 1), true);
    });

    test('findByProject sorts by modifiedAt desc', () async {
      final old = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Old',
        modifiedAt: DateTime(2024, 1, 1),
      );
      final recent = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Recent',
        modifiedAt: DateTime(2024, 6, 1),
      );

      await repository.create(old);
      await repository.create(recent);

      final artifacts = await repository.findByProject(1);
      expect(artifacts.first.title, 'Recent');
      expect(artifacts.last.title, 'Old');
    });

    test('findByTag returns matching artifacts', () async {
      await repository.create(
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'AI Article',
          tags: ['ai', 'ml'],
        ),
      );
      await repository.create(
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'Web Dev',
          tags: ['webdev'],
        ),
      );
      await repository.create(
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'ML Research',
          tags: ['ml', 'research'],
        ),
      );

      final artifacts = await repository.findByTag(1, 'ml');
      expect(artifacts.length, 2);
      expect(artifacts.any((a) => a.title == 'AI Article'), true);
      expect(artifacts.any((a) => a.title == 'ML Research'), true);
    });

    test('findByTag is case-insensitive', () async {
      await repository.create(
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'Test',
          tags: ['AI'],
        ),
      );

      final artifacts = await repository.findByTag(1, 'ai');
      expect(artifacts.length, 1);
    });

    test('findByTags returns artifacts matching any tag', () async {
      await repository.create(
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'A',
          tags: ['ai'],
        ),
      );
      await repository.create(
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'B',
          tags: ['blockchain'],
        ),
      );
      await repository.create(
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'C',
          tags: ['crypto'],
        ),
      );

      final artifacts = await repository.findByTags(1, ['ai', 'crypto']);
      expect(artifacts.length, 2);
      expect(artifacts.any((a) => a.title == 'A'), true);
      expect(artifacts.any((a) => a.title == 'C'), true);
    });

    test('update persists changes', () async {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Original',
      );
      await repository.create(artifact);

      artifact.updateContent('New content');
      await repository.update(artifact);

      final found = await repository.findById(artifact.id);
      expect(found!.content, 'New content');
    });

    test('delete removes artifact', () async {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Delete Me',
      );
      await repository.create(artifact);

      await repository.delete(artifact.id);

      final found = await repository.findById(artifact.id);
      expect(found, isNull);
    });
  });
}
