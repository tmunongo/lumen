import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';

class IsarArtifactRepository implements ArtifactRepository {
  final Isar isar;

  IsarArtifactRepository(this.isar);

  @override
  Future<Artifact> create(Artifact artifact) async {
    await isar.writeTxn(() async {
      await isar.artifacts.put(artifact);
    });
    return artifact;
  }

  @override
  Future<Artifact?> findById(int id) async {
    return await isar.artifacts.get(id);
  }

  @override
  Future<List<Artifact>> findByProject(int projectId) async {
    return await isar.artifacts
        .filter()
        .projectIdEqualTo(projectId)
        .sortByModifiedAtDesc()
        .findAll();
  }

  @override
  Future<List<Artifact>> findByTag(int projectId, String tag) async {
    final normalized = tag.trim().toLowerCase();
    return await isar.artifacts
        .filter()
        .projectIdEqualTo(projectId)
        .tagsElementContains(normalized)
        .sortByModifiedAtDesc()
        .findAll();
  }

  @override
  Future<List<Artifact>> findByTags(int projectId, List<String> tags) async {
    if (tags.isEmpty) return [];

    final normalized = tags.map((t) => t.trim().toLowerCase()).toSet();
    final artifacts = await findByProject(projectId);

    return artifacts.where((artifact) {
      final artifactTags = artifact.tags.toSet();
      return normalized.any((tag) => artifactTags.contains(tag));
    }).toList();
  }

  @override
  Future<void> update(Artifact artifact) async {
    await isar.writeTxn(() async {
      await isar.artifacts.put(artifact);
    });
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.artifacts.delete(id);
    });
  }
}
