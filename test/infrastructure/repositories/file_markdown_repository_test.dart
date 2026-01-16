import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/domain/entities/markdown_document.dart';
import 'package:lumen/infrastructure/repositories/file_markdown_repository.dart';
import 'package:lumen/infrastructure/services/project_storage_service.dart';

// Reuse TestProjectStorageService from service test or define here
class TestProjectStorageService extends ProjectStorageService {
  final Directory testDir;

  TestProjectStorageService(this.testDir);

  @override
  Future<Directory> getStorageDirectory() async {
    return testDir;
  }
}

void main() {
  group('FileMarkdownRepository', () {
    late Directory tempDir;
    late ProjectStorageService storageService;
    late FileMarkdownRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('lumen_repo_test_');
      storageService = TestProjectStorageService(tempDir);
      repository = FileMarkdownRepository(storageService);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('create stores document and updates metadata', () async {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'test.md',
        title: 'Test',
        content: '# Content',
      );

      // Setup manifest
      await storageService.createManifest(
        projectId: 1,
        projectName: 'P1',
        projectSlug: 'p1',
      );

      final created = await repository.create(doc);

      expect(created.isDirty, false);

      // Verify file exists
      final storedContent = await storageService.readMarkdownFile(
        'p1',
        'test.md',
      );
      expect(storedContent, '# Content');

      // Verify metadata
      final retrieved = await repository.findById('1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test');
    });

    test('findById returns null for non-existent id', () async {
      expect(await repository.findById('missing'), isNull);
    });

    test('update modifies content and metadata', () async {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'test.md',
        title: 'Test',
        content: '# Init',
      );

      await storageService.createManifest(
        projectId: 1,
        projectName: 'P1',
        projectSlug: 'p1',
      );
      await repository.create(doc);

      // Update
      final updatedDoc = doc.copyWith(content: '# New', title: 'New Title');
      await repository.update(updatedDoc);

      // Verify
      final retrieved = await repository.findById('1');
      expect(retrieved!.content, '# New');
      expect(retrieved.title, 'New Title');

      final storedContent = await storageService.readMarkdownFile(
        'p1',
        'test.md',
      );
      expect(storedContent, '# New');
    });

    test('delete removes file and metadata', () async {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'deleter.md',
        title: 'Delete Me',
      );

      await storageService.createManifest(
        projectId: 1,
        projectName: 'P1',
        projectSlug: 'p1',
      );
      await repository.create(doc);

      // Verify exists
      expect(await repository.findById('1'), isNotNull);

      // Delete
      await repository.delete('1');

      // Verify gone
      expect(await repository.findById('1'), isNull);
      expect(await storageService.readMarkdownFile('p1', 'deleter.md'), isNull);
    });

    test('findByProject returns all docs for project', () async {
      await storageService.createManifest(
        projectId: 1,
        projectName: 'P1',
        projectSlug: 'p1',
      );
      await storageService.createManifest(
        projectId: 2,
        projectName: 'P2',
        projectSlug: 'p2',
      );

      final doc1 = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: '1.md',
        title: '1',
      );
      final doc2 = MarkdownDocument(
        id: '2',
        projectId: 1,
        projectSlug: 'p1',
        filename: '2.md',
        title: '2',
      );
      final doc3 = MarkdownDocument(
        id: '3',
        projectId: 2,
        projectSlug: 'p2',
        filename: '3.md',
        title: '3',
      );

      await repository.create(doc1);
      await repository.create(doc2);
      await repository.create(doc3);

      final p1Docs = await repository.findByProject(1);
      expect(p1Docs.length, 2);
      expect(p1Docs.map((d) => d.id), containsAll(['1', '2']));

      final p2Docs = await repository.findByProject(2);
      expect(p2Docs.length, 1);
      expect(p2Docs.first.id, '3');
    });

    test('filenameExists checks existence', () async {
      await storageService.createManifest(
        projectId: 1,
        projectName: 'P1',
        projectSlug: 'p1',
      );
      await storageService.writeMarkdownFile('p1', 'exist.md', '');

      expect(await repository.filenameExists('p1', 'exist.md'), true);
      expect(await repository.filenameExists('p1', 'nope.md'), false);
    });
  });
}
