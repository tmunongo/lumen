import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:lumen/application/services/artifact_service.dart';
import 'package:lumen/application/services/highlight_service.dart';
import 'package:lumen/application/services/ingestion_service.dart';
import 'package:lumen/application/services/link_service.dart';
import 'package:lumen/application/services/markdown_service.dart';
import 'package:lumen/application/services/project_service.dart';
import 'package:lumen/application/services/relationship_service.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/markdown_document.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/repositories/highlight_repository.dart';
import 'package:lumen/domain/repositories/link_repository.dart';
import 'package:lumen/domain/repositories/markdown_repository.dart';
import 'package:lumen/domain/repositories/project_repository.dart';
import 'package:lumen/domain/repositories/tag_repository.dart';
import 'package:lumen/infrastructure/database/isar_database.dart';
import 'package:lumen/infrastructure/repositories/file_markdown_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_artifact_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_highlight_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_link_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_project_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_tag_repository.dart';
import 'package:lumen/infrastructure/services/html_sanitizer_impl.dart';
import 'package:lumen/infrastructure/services/project_storage_service.dart';
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

// Project storage service (file-based)
final projectStorageServiceProvider = Provider<ProjectStorageService>((ref) {
  return ProjectStorageService();
});

// Markdown repository (file-based)
final markdownRepositoryProvider = Provider<MarkdownRepository>((ref) {
  return FileMarkdownRepository(ref.watch(projectStorageServiceProvider));
});

// Service providers
final projectServiceProvider = Provider<ProjectService>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  final artifactRepository = ref.watch(artifactRepositoryProvider);
  final tagRepository = ref.watch(tagRepositoryProvider);
  final artifactService = ref.watch(artifactServiceProvider);

  return ProjectService(
    projectRepository: projectRepository,
    artifactRepository: artifactRepository,
    tagRepository: tagRepository,
    artifactService: artifactService,
  );
});

final showArchivedProjectsProvider = StateProvider<bool>((ref) => false);

final projectsProvider = StreamProvider<List<Project>>((ref) async* {
  final service = ref.watch(projectServiceProvider);
  final showArchived = ref.watch(showArchivedProjectsProvider);
  yield await service.getAllProjects(includeArchived: showArchived);
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

// Markdown service
final markdownServiceProvider = Provider<MarkdownService>((ref) {
  return MarkdownService(
    repository: ref.watch(markdownRepositoryProvider),
    storageService: ref.watch(projectStorageServiceProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
  );
});

// Markdown documents provider for a specific project
final projectMarkdownDocumentsProvider =
    FutureProvider.family<List<MarkdownDocument>, int>((ref, projectId) async {
      final service = ref.watch(markdownServiceProvider);
      return await service.getProjectDocuments(projectId);
    });

// Project by ID provider
final projectByIdProvider = FutureProvider.family<Project?, int>((
  ref,
  projectId,
) async {
  final service = ref.watch(projectServiceProvider);
  return await service.getProject(projectId);
});

// Artifacts by Project ID provider
final projectArtifactsProvider = FutureProvider.family<List<Artifact>, int>((
  ref,
  projectId,
) async {
  final repository = ref.watch(artifactRepositoryProvider);
  return await repository.findByProject(projectId);
});

// Artifacts by Tag provider
final projectArtifactsByTagProvider =
    FutureProvider.family<List<Artifact>, ({int projectId, String tagName})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(artifactRepositoryProvider);
      return await repository.findByTag(params.projectId, params.tagName);
    });
