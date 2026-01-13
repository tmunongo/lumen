import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/domain/entities/artifact.dart';

void main() {
  group('Artifact', () {
    test('creates webPage artifact', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.webPage,
        title: 'Great Article',
        sourceUrl: 'https://example.com',
      );
      expect(artifact.title, 'Great Article');
      expect(artifact.type, ArtifactType.webPage);
      expect(artifact.isFetched, false);
    });

    test('creates note artifact', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'My Thoughts',
        content: 'Deep insights here...',
      );
      expect(artifact.content, 'Deep insights here...');
    });

    test('throws on empty title', () {
      expect(
        () => Artifact(projectId: 1, type: ArtifactType.note, title: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on quote without attribution', () {
      expect(
        () => Artifact(
          projectId: 1,
          type: ArtifactType.quote,
          title: 'Quote',
          content: 'Some text',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on link artifact without sourceUrl', () {
      expect(
        () => Artifact(projectId: 1, type: ArtifactType.rawLink, title: 'Link'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('markFetched transitions rawLink to webPage', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.rawLink,
        title: 'Pending',
        sourceUrl: 'https://example.com',
      );

      artifact.markFetched(
        cleanedContent: '<p>Clean content</p>',
        assetPath: '/local/path',
      );

      expect(artifact.type, ArtifactType.webPage);
      expect(artifact.isFetched, true);
      expect(artifact.content, '<p>Clean content</p>');
      expect(artifact.localAssetPath, '/local/path');
    });

    test('markFetched throws on non-link artifacts', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Note',
      );

      expect(
        () => artifact.markFetched(cleanedContent: 'test'),
        throwsA(isA<StateError>()),
      );
    });

    test('tags are normalized and deduplicated', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Test',
      );

      artifact.addTag('AI');
      artifact.addTag('  ai  ');
      artifact.addTag('Machine Learning');

      expect(artifact.tags, ['ai', 'machine learning']);
    });

    test('throws on empty tag', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Test',
      );

      expect(() => artifact.addTag(''), throwsA(isA<ArgumentError>()));
    });

    test('throws on tag exceeding 50 characters', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Test',
      );

      expect(() => artifact.addTag('a' * 51), throwsA(isA<ArgumentError>()));
    });

    test('removeTag works correctly', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Test',
        tags: ['ai', 'ml'],
      );

      artifact.removeTag('AI'); // Case insensitive
      expect(artifact.tags, ['ml']);
    });

    test('setTags replaces all tags', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Test',
        tags: ['old'],
      );

      artifact.setTags(['New', 'Tags', 'new']); // Deduplicates
      expect(artifact.tags, ['new', 'tags']);
    });
  });
}
