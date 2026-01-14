import 'package:lumen/domain/entities/artifact_link.dart';

/// Repository interface for managing artifact links
abstract class LinkRepository {
  /// Create a new link between artifacts
  Future<ArtifactLink> create(ArtifactLink link);

  /// Delete a link by its ID
  Future<void> delete(int id);

  /// Find all links from a source artifact (outgoing)
  Future<List<ArtifactLink>> findOutgoingLinks(int artifactId);

  /// Find all links to a target artifact (incoming/backlinks)
  Future<List<ArtifactLink>> findIncomingLinks(int artifactId);

  /// Find all links in a project
  Future<List<ArtifactLink>> findByProject(int projectId);

  /// Check if a link already exists between two artifacts
  Future<bool> linkExists(int sourceId, int targetId);

  /// Find a specific link between two artifacts
  Future<ArtifactLink?> findLink(int sourceId, int targetId);

  /// Delete all links involving an artifact (for cleanup when artifact is deleted)
  Future<void> deleteAllForArtifact(int artifactId);
}
