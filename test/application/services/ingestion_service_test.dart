import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/application/services/ingestion_service.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/services/content_extractor.dart';
import 'package:lumen/domain/services/html_sanitizer.dart';
import 'package:lumen/infrastructure/services/web_fetcher.dart';
import 'package:mocktail/mocktail.dart';

class MockArtifactRepository extends Mock implements ArtifactRepository {}

class MockWebFetcher extends Mock implements WebFetcher {}

class MockContentExtractor extends Mock implements ContentExtractor {}

class MockHtmlSanitizer extends Mock implements HtmlSanitizer {}

void main() {
  late IngestionService service;
  late MockArtifactRepository repository;
  late MockWebFetcher fetcher;
  late MockContentExtractor extractor;
  late MockHtmlSanitizer sanitizer;
  setUp(() {
    repository = MockArtifactRepository();
    fetcher = MockWebFetcher();
    extractor = MockContentExtractor();
    sanitizer = MockHtmlSanitizer();

    service = IngestionService(
      repository: repository,
      fetcher: fetcher,
      extractor: extractor,
      sanitizer: sanitizer,
    );

    registerFallbackValue(Uri.parse('https://example.com'));
    group('IngestionService', () {
      test('successfully ingests a raw link', () async {
        final artifact = Artifact(
          projectId: 1,
          type: ArtifactType.rawLink,
          title: 'Test Article',
          sourceUrl: 'https://example.com/article',
        );
        when(() => fetcher.fetch(any())).thenAnswer(
          (_) async => WebFetchResult(
            content: '<html><body><h1>Article</h1><p>Content</p></body></html>',
            statusCode: 200,
            contentType: 'text/html',
            finalUrl: Uri.parse('https://example.com/article'),
          ),
        );

        when(() => extractor.extract(any(), any())).thenAnswer(
          (_) async => ExtractedContent(
            title: 'Article Title',
            cleanedHtml: '<h1>Article</h1><p>Content</p>',
          ),
        );

        when(
          () => sanitizer.sanitize(any()),
        ).thenReturn('<h1>Article</h1><p>Content</p>');

        when(() => repository.update(any())).thenAnswer((_) async => {});

        final result = await service.ingest(artifact);

        expect(result.success, true);
        expect(artifact.isFetched, true);
        expect(artifact.type, ArtifactType.webPage);
        verify(() => repository.update(artifact)).called(1);
      });

      test('fails gracefully on fetch error', () async {
        final artifact = Artifact(
          projectId: 1,
          type: ArtifactType.rawLink,
          title: 'Test',
          sourceUrl: 'https://example.com/missing',
        );

        when(
          () => fetcher.fetch(any()),
        ).thenThrow(WebFetchException('Not found', 404));

        final result = await service.ingest(artifact);

        expect(result.success, false);
        expect(result.errorMessage, contains('Failed to fetch'));
        verifyNever(() => repository.update(any()));
      });

      test('rejects non-link artifacts', () async {
        final artifact = Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'Note',
        );

        final result = await service.ingest(artifact);

        expect(result.success, false);
        expect(result.errorMessage, contains('Only link artifacts'));
      });

      test('rejects artifacts without sourceUrl', () async {
        final artifact = Artifact(
          projectId: 1,
          type: ArtifactType.rawLink,
          title: 'Invalid',
          sourceUrl: 'https://example.com',
        );
        artifact.sourceUrl = null; // Force null

        final result = await service.ingest(artifact);

        expect(result.success, false);
        expect(result.errorMessage, contains('no source URL'));
      });

      test('ingest is idempotent', () async {
        final artifact = Artifact(
          projectId: 1,
          type: ArtifactType.webPage,
          title: 'Already Fetched',
          sourceUrl: 'https://example.com',
          content: 'Old content',
        )..isFetched = true;

        when(() => fetcher.fetch(any())).thenAnswer(
          (_) async => WebFetchResult(
            content: '<html><body><p>New content</p></body></html>',
            statusCode: 200,
            contentType: 'text/html',
            finalUrl: Uri.parse('https://example.com'),
          ),
        );

        when(() => extractor.extract(any(), any())).thenAnswer(
          (_) async => ExtractedContent(
            title: 'Updated',
            cleanedHtml: '<p>New content</p>',
          ),
        );

        when(() => sanitizer.sanitize(any())).thenReturn('<p>New content</p>');
        when(() => repository.update(any())).thenAnswer((_) async => {});

        final result = await service.ingest(artifact);

        expect(result.success, true);
        expect(artifact.content, contains('New content'));
      });
    });
  });
}
