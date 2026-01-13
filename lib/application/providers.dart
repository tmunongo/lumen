import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:lumen/application/services/project_service.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/repositories/project_repository.dart';
import 'package:lumen/domain/repositories/tag_repository.dart';
import 'package:lumen/infrastructure/database/isar_database.dart';
import 'package:lumen/infrastructure/repositories/isar_artifact_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_project_repository.dart';
import 'package:lumen/infrastructure/repositories/isar_tag_repository.dart';

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

final projectServiceProvider = Provider<ProjectService>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectService(repository);
});

// State notifier for projects list
final projectsProvider = StreamProvider<List<Project>>((ref) async* {
  final service = ref.watch(projectServiceProvider);

  yield await service.getAllProjects();

  // In production, you'd set up Isar watchers here for reactive updates
  // For now, we'll rely on manual refreshes
});
