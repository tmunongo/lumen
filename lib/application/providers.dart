import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:lumen/application/services/artifact_service.dart';
import 'package:lumen/application/services/highlight_service.dart';
import 'package:lumen/application/services/ingestion_service.dart';
import 'package:lumen/application/services/link_service.dart';
import 'package:lumen/application/services/project_service.dart';
import 'package:lumen/application/services/relationship_service.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/repositories/highlight_repository.dart';
import 'package:lumen/domain/repositories/link_repository.dart';
import 'package:lumen/domain/repositories/project_repository.dart';
import 'package:lumen/domain/repositories/tag_repository.dart';
import 'package:lumen/infrastructure/database/isar_database.dart';
import 'package:lumen/infrastructure/repositories/isar_artifact_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_highlight_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_link_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_project_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_tag_repository.dart';
import 'package:lumen/infrastructure/services/html_sanitizer_impl.dart';
import 'package:lumen/infrastructure/services/readability_extractor.dart';
import 'package:lumen/infrastructure/services/web_fetcher.dart';

// Database instance provider
final isarProvider = FutureProvider<Isar>((ref) async {
  return await IsarDatabase.getInstance();
});

// Repository providers
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) throw Exception('Isar not initialized');
  return IsarProjectRepository(isar);
});

final artifactRepositoryProvider = Provider<ArtifactRepository>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) throw Exception('Isar not initialized');
  return IsarArtifactRepository(isar);
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) throw Exception('Isar not initialized');
  return IsarTagRepository(isar);
});

final linkRepositoryProvider = Provider<LinkRepository>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) throw Exception('Isar not initialized');
  return IsarLinkRepository(isar);
});

final highlightRepositoryProvider = Provider<HighlightRepository>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) throw Exception('Isar not initialized');
  return IsarHighlightRepository(isar);
});

// Service providers
final projectServiceProvider = Provider<ProjectService>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectService(repository);
});

final projectsProvider = StreamProvider<List<Project>>((ref) async* {
  final service = ref.watch(projectServiceProvider);
  yield await service.getAllProjects();
});

final webFetcherProvider = Provider<WebFetcher>((ref) {
  return WebFetcher();
});

final contentExtractorProvider = Provider((ref) {
  return ReadabilityExtractor();
});

final htmlSanitizerProvider = Provider((ref) {
  return HtmlSanitizerImpl();
});

final ingestionServiceProvider = Provider<IngestionService>((ref) {
  return IngestionService(
    repository: ref.watch(artifactRepositoryProvider),
    fetcher: ref.watch(webFetcherProvider),
    extractor: ref.watch(contentExtractorProvider),
    sanitizer: ref.watch(htmlSanitizerProvider),
  );
});

final artifactServiceProvider = Provider<ArtifactService>((ref) {
  return ArtifactService(
    artifactRepository: ref.watch(artifactRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
  );
});

final linkServiceProvider = Provider<LinkService>((ref) {
  return LinkService(
    linkRepository: ref.watch(linkRepositoryProvider),
    artifactRepository: ref.watch(artifactRepositoryProvider),
  );
});

final relationshipServiceProvider = Provider<RelationshipService>((ref) {
  return RelationshipService();
});

final highlightServiceProvider = Provider<HighlightService>((ref) {
  final repository = ref.watch(highlightRepositoryProvider);
  return HighlightService(repository);
});
