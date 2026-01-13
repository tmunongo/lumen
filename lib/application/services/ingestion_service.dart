import 'dart:async';

import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/services/content_extractor.dart';
import 'package:lumen/domain/services/html_sanitizer.dart';
import 'package:lumen/infrastructure/services/web_fetcher.dart';

class IngestionResult {
  final bool success;
  final String? errorMessage;
  final Artifact? artifact;

  IngestionResult.success(this.artifact) : success = true, errorMessage = null;

  IngestionResult.failure(this.errorMessage) : success = false, artifact = null;
}

class IngestionService {
  final ArtifactRepository _repository;
  final WebFetcher _fetcher;
  final ContentExtractor _extractor;
  final HtmlSanitizer _sanitizer;

  IngestionService({
    required ArtifactRepository repository,
    required WebFetcher fetcher,
    required ContentExtractor extractor,
    required HtmlSanitizer sanitizer,
  }) : _repository = repository,
       _fetcher = fetcher,
       _extractor = extractor,
       _sanitizer = sanitizer;

  /// Ingest a URL into an artifact
  /// This method is idempotent - calling it multiple times with the same
  /// artifact will re-fetch and update the content
  Future<IngestionResult> ingest(Artifact artifact) async {
    if (artifact.type != ArtifactType.rawLink &&
        artifact.type != ArtifactType.webPage) {
      return IngestionResult.failure('Only link artifacts can be ingested');
    }

    if (artifact.sourceUrl == null) {
      return IngestionResult.failure('Artifact has no source URL');
    }

    try {
      // Fetch the page
      final fetchResult = await _fetcher.fetch(artifact.sourceUrl!);

      // Extract readable content
      final extracted = await _extractor.extract(
        fetchResult.content,
        fetchResult.finalUrl,
      );

      // Sanitize HTML
      final sanitized = _sanitizer.sanitize(extracted.cleanedHtml);

      // Update artifact
      artifact.markFetched(cleanedContent: sanitized);

      // If extracted title is better, use it
      if (extracted.title.isNotEmpty &&
          extracted.title != 'Untitled' &&
          artifact.title == artifact.sourceUrl) {
        artifact.title = extracted.title;
      }

      // Save to repository
      await _repository.update(artifact);

      return IngestionResult.success(artifact);
    } on WebFetchException catch (e) {
      return IngestionResult.failure('Failed to fetch: ${e.message}');
    } catch (e) {
      return IngestionResult.failure('Unexpected error: $e');
    }
  }

  /// Ingest multiple artifacts in sequence
  /// Returns a map of artifact ID to result
  Future<Map<int, IngestionResult>> ingestBatch(
    List<Artifact> artifacts,
  ) async {
    final results = <int, IngestionResult>{};

    for (final artifact in artifacts) {
      results[artifact.id] = await ingest(artifact);

      // Small delay to be respectful to servers
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }
}
