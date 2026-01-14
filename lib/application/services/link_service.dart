import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_link.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/repositories/link_repository.dart';

/// Service for managing bidirectional artifact links
class LinkService {
  final LinkRepository _linkRepository;
  final ArtifactRepository _artifactRepository;

  LinkService({
    required LinkRepository linkRepository,
    required ArtifactRepository artifactRepository,
  })  : _linkRepository = linkRepository,
        _artifactRepository = artifactRepository;

  /// Create a link from source to target artifact
  /// Returns the created link, or null if link already exists
  Future<ArtifactLink?> createLink(
    int sourceId,
    int targetId,
    int projectId, {
    LinkType type = LinkType.related,
    String? note,
  }) async {
    // Prevent self-linking
    if (sourceId == targetId) {
      throw ArgumentError('Cannot link an artifact to itself');
    }

    // Check if link already exists
    if (await _linkRepository.linkExists(sourceId, targetId)) {
      return null;
    }

    final link = ArtifactLink(
      sourceArtifactId: sourceId,
      targetArtifactId: targetId,
      projectId: projectId,
      type: type,
      note: note,
    );

    return await _linkRepository.create(link);
  }

  /// Remove a link between two artifacts
  Future<void> removeLink(int sourceId, int targetId) async {
    final link = await _linkRepository.findLink(sourceId, targetId);
    if (link != null) {
      await _linkRepository.delete(link.id);
    }
  }

  /// Get all artifacts linked FROM this artifact (outgoing)
  Future<List<Artifact>> getOutgoingLinkedArtifacts(int artifactId) async {
    final links = await _linkRepository.findOutgoingLinks(artifactId);
    final artifacts = <Artifact>[];

    for (final link in links) {
      final artifact = await _artifactRepository.findById(link.targetArtifactId);
      if (artifact != null) {
        artifacts.add(artifact);
      }
    }

    return artifacts;
  }

  /// Get outgoing links paired with their target artifacts
  Future<List<({ArtifactLink link, Artifact artifact})>> getOutgoingLinksWithArtifacts(
    int artifactId,
  ) async {
    final links = await _linkRepository.findOutgoingLinks(artifactId);
    final result = <({ArtifactLink link, Artifact artifact})>[];

    for (final link in links) {
      final artifact = await _artifactRepository.findById(link.targetArtifactId);
      if (artifact != null) {
        result.add((link: link, artifact: artifact));
      }
    }
    return result;
  }

  /// Get all artifacts linking TO this artifact (backlinks/incoming)
  Future<List<Artifact>> getBacklinks(int artifactId) async {
    final links = await _linkRepository.findIncomingLinks(artifactId);
    final artifacts = <Artifact>[];

    for (final link in links) {
      final artifact = await _artifactRepository.findById(link.sourceArtifactId);
      if (artifact != null) {
        artifacts.add(artifact);
      }
    }

    return artifacts;
  }

  /// Get incoming links paired with their source artifacts
  Future<List<({ArtifactLink link, Artifact artifact})>> getIncomingLinksWithArtifacts(
    int artifactId,
  ) async {
    final links = await _linkRepository.findIncomingLinks(artifactId);
    final result = <({ArtifactLink link, Artifact artifact})>[];

    for (final link in links) {
      final artifact = await _artifactRepository.findById(link.sourceArtifactId);
      if (artifact != null) {
        result.add((link: link, artifact: artifact));
      }
    }
    return result;
  }

  /// Get all linked artifacts (both directions combined, deduplicated)
  Future<List<Artifact>> getAllLinkedArtifacts(int artifactId) async {
    final outgoing = await getOutgoingLinkedArtifacts(artifactId);
    final incoming = await getBacklinks(artifactId);

    // Combine and deduplicate
    final seen = <int>{};
    final result = <Artifact>[];

    for (final artifact in [...outgoing, ...incoming]) {
      if (!seen.contains(artifact.id)) {
        seen.add(artifact.id);
        result.add(artifact);
      }
    }

    return result;
  }

  /// Get outgoing links with metadata
  Future<List<ArtifactLink>> getOutgoingLinks(int artifactId) async {
    return await _linkRepository.findOutgoingLinks(artifactId);
  }

  /// Get incoming links with metadata  
  Future<List<ArtifactLink>> getIncomingLinks(int artifactId) async {
    return await _linkRepository.findIncomingLinks(artifactId);
  }

  /// Check if two artifacts are linked (in either direction)
  Future<bool> areLinked(int artifactId1, int artifactId2) async {
    return await _linkRepository.linkExists(artifactId1, artifactId2) ||
        await _linkRepository.linkExists(artifactId2, artifactId1);
  }

  /// Delete all links for an artifact (cleanup when artifact is deleted)
  Future<void> deleteAllLinksForArtifact(int artifactId) async {
    await _linkRepository.deleteAllForArtifact(artifactId);
  }
}
