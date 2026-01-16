import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/infrastructure/services/project_storage_service.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ProjectStorageService', () {
    late Directory tempDir;
    late ProjectStorageService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('lumen_test_');
      service = TestProjectStorageService(tempDir);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('slugify generates correct slugs', () {
      expect(service.slugify('My Project'), 'my-project');
      expect(service.slugify('  Test  Project  '), 'test-project');
      expect(service.slugify('Project #1'), 'project-1');
      expect(
        service.slugify('Mixed_Case_With-Dashes'),
        'mixed-case-with-dashes',
      );
    });

    test('getProjectDirectory creates directory if not exists', () async {
      final slug = 'test-project';
      final dir = await service.getProjectDirectory(slug);

      expect(await dir.exists(), true);
      expect(p.basename(dir.path), slug);
      expect(dir.parent.path, tempDir.path);
    });

    test('manifest lifecycle (create, read, update)', () async {
      final slug = 'test-project';
      await service.getProjectDirectory(slug);

      // Create
      await service.createManifest(
        projectId: 1,
        projectName: 'Test Project',
        projectSlug: slug,
      );

      // Read
      var manifest = await service.getManifest(slug);
      expect(manifest, isNotNull);
      expect(manifest!.projectId, 1);
      expect(manifest.projectName, 'Test Project');
      expect(manifest.markdownFiles, isEmpty);

      // Update (add markdown file)
      await service.addMarkdownToManifest(slug, 'note.md');

      manifest = await service.getManifest(slug);
      expect(manifest!.markdownFiles, contains('note.md'));

      // Remove markdown file
      await service.removeMarkdownFromManifest(slug, 'note.md');
      manifest = await service.getManifest(slug);
      expect(manifest!.markdownFiles, isEmpty);
    });

    test('markdown file lifecycle (write, read, delete)', () async {
      final slug = 'test-project';
      await service.createManifest(
        projectId: 1,
        projectName: 'Test Project',
        projectSlug: slug,
      );

      final filename = 'note.md';
      final content = '# Hello World';

      // Write
      await service.writeMarkdownFile(slug, filename, content);

      // Check file exists physically
      final file = await service.getMarkdownFile(slug, filename);
      expect(await file.exists(), true);

      // Read
      final readContent = await service.readMarkdownFile(slug, filename);
      expect(readContent, content);

      // Delete
      await service.deleteMarkdownFile(slug, filename);
      expect(await file.exists(), false);
    });

    test('deleteProjectDirectory removes entire folder', () async {
      final slug = 'delete-me';
      await service.createManifest(
        projectId: 1,
        projectName: 'Delete Me',
        projectSlug: slug,
      );
      await service.writeMarkdownFile(slug, 'note.md', 'content');

      expect(await service.projectDirectoryExists(slug), true);

      await service.deleteProjectDirectory(slug);

      expect(await service.projectDirectoryExists(slug), false);
    });

    test('listProjectSlugs returns correct list', () async {
      await service.getProjectDirectory('p1');
      await service.getProjectDirectory('p2');
      // Hidden dir
      await Directory(p.join(tempDir.path, '.hidden')).create();

      final slugs = await service.listProjectSlugs();

      expect(slugs, containsAll(['p1', 'p2']));
      expect(slugs.contains('.hidden'), false);
    });
  });
}

// Subclass to override getStorageDirectory for testing
class TestProjectStorageService extends ProjectStorageService {
  final Directory testDir;

  TestProjectStorageService(this.testDir);

  @override
  Future<Directory> getStorageDirectory() async {
    return testDir;
  }
}
