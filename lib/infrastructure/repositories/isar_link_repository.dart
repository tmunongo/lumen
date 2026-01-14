import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/artifact_link.dart';
import 'package:lumen/domain/repositories/link_repository.dart';

class IsarLinkRepository implements LinkRepository {
  final Isar isar;

  IsarLinkRepository(this.isar);

  @override
  Future<ArtifactLink> create(ArtifactLink link) async {
    await isar.writeTxn(() async {
      await isar.artifactLinks.put(link);
    });
    return link;
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.artifactLinks.delete(id);
    });
  }

  @override
  Future<List<ArtifactLink>> findOutgoingLinks(int artifactId) async {
    return await isar.artifactLinks
        .filter()
        .sourceArtifactIdEqualTo(artifactId)
        .findAll();
  }

  @override
  Future<List<ArtifactLink>> findIncomingLinks(int artifactId) async {
    return await isar.artifactLinks
        .filter()
        .targetArtifactIdEqualTo(artifactId)
        .findAll();
  }

  @override
  Future<List<ArtifactLink>> findByProject(int projectId) async {
    return await isar.artifactLinks
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
  }

  @override
  Future<bool> linkExists(int sourceId, int targetId) async {
    final link = await findLink(sourceId, targetId);
    return link != null;
  }

  @override
  Future<ArtifactLink?> findLink(int sourceId, int targetId) async {
    return await isar.artifactLinks
        .filter()
        .sourceArtifactIdEqualTo(sourceId)
        .targetArtifactIdEqualTo(targetId)
        .findFirst();
  }

  @override
  Future<void> deleteAllForArtifact(int artifactId) async {
    await isar.writeTxn(() async {
      // Delete outgoing links
      final outgoing = await isar.artifactLinks
          .filter()
          .sourceArtifactIdEqualTo(artifactId)
          .findAll();
      for (final link in outgoing) {
        await isar.artifactLinks.delete(link.id);
      }

      // Delete incoming links
      final incoming = await isar.artifactLinks
          .filter()
          .targetArtifactIdEqualTo(artifactId)
          .findAll();
      for (final link in incoming) {
        await isar.artifactLinks.delete(link.id);
      }
    });
  }
}
