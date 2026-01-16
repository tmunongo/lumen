import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/domain/entities/markdown_document.dart';

void main() {
  group('MarkdownDocument', () {
    test('props are correctly assigned in constructor', () {
      final now = DateTime.now();
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'project-1',
        filename: 'test.md',
        title: 'Test Document',
        content: 'content',
        createdAt: now,
        modifiedAt: now,
        tags: ['tag1'],
      );

      expect(doc.id, '1');
      expect(doc.projectId, 1);
      expect(doc.projectSlug, 'project-1');
      expect(doc.filename, 'test.md');
      expect(doc.title, 'Test Document');
      expect(doc.content, 'content');
      expect(doc.createdAt, now);
      expect(doc.modifiedAt, now);
      expect(doc.tags, ['tag1']);
      expect(doc.isDirty, false);
      expect(doc.filePath, 'project-1/test.md');
    });

    test('updateContent updates content and marks as dirty', () {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'T',
      );

      final originalTime = doc.modifiedAt;
      doc.updateContent('new content');

      expect(doc.content, 'new content');
      expect(doc.isDirty, true);
      expect(
        doc.modifiedAt.isAfter(
          originalTime.subtract(const Duration(milliseconds: 1)),
        ),
        true,
      );
    });

    test('updateContent does nothing if content is same', () {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'T',
        content: 'content',
      );

      doc.isDirty = false;
      final originalTime = doc.modifiedAt;

      doc.updateContent('content');

      expect(doc.isDirty, false);
      expect(doc.modifiedAt, originalTime);
    });

    test('updateTitle updates title and marks as dirty', () {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'Old',
      );

      doc.updateTitle('New');

      expect(doc.title, 'New');
      expect(doc.isDirty, true);
    });

    test('addTag adds normalized tag and marks dirty', () {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'T',
      );

      doc.addTag('  TAG1  ');

      expect(doc.tags, contains('tag1'));
      expect(doc.isDirty, true);
    });

    test('addTag ignores duplicates', () {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'T',
        tags: ['tag1'],
      );

      doc.isDirty = false;
      doc.addTag('TAG1');

      expect(doc.tags.length, 1);
      expect(doc.isDirty, false);
    });

    test('removeTag removes tag and marks dirty', () {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'T',
        tags: ['tag1', 'tag2'],
      );

      doc.removeTag('TAG1');

      expect(doc.tags, ['tag2']);
      expect(doc.isDirty, true);
    });

    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'T',
        createdAt: now,
        modifiedAt: now,
        tags: ['tag1'],
      );

      final json = doc.toJson();
      final fromJson = MarkdownDocument.fromJson(json);

      expect(fromJson.id, doc.id);
      expect(fromJson.projectId, doc.projectId);
      expect(fromJson.projectSlug, doc.projectSlug);
      expect(fromJson.filename, doc.filename);
      expect(fromJson.title, doc.title);
      expect(fromJson.tags, doc.tags);
      // DateTime precision might be slightly lost in JSON, check closeness if strict equality fails
      // but usually toIso8601String is precise enough for standard tests unless microseconds involved.
      // We'll trust exact match for now as implementation uses toIso8601String.
      expect(
        fromJson.createdAt.toIso8601String(),
        doc.createdAt.toIso8601String(),
      );
    });

    test('copyWith works correctly', () {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'p1',
        filename: 'f.md',
        title: 'T',
      );

      final copy = doc.copyWith(title: 'New Title');

      expect(copy.id, doc.id);
      expect(copy.title, 'New Title');
      expect(copy.filename, doc.filename);
    });
  });
}
