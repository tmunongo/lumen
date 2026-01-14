import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/models/artifact_relationship.dart';

class RelationshipService {
  /// Find all artifacts related to the given artifact
  RelatedArtifactCluster findRelatedArtifacts(
    Artifact anchor,
    List<Artifact> allArtifacts,
  ) {
    if (anchor.tags.isEmpty) {
      return RelatedArtifactCluster(anchor: anchor, relationships: []);
    }

    final anchorTags = anchor.tags.toSet();
    final relationships = <ArtifactRelationship>[];

    for (final candidate in allArtifacts) {
      // Skip self
      if (candidate.id == anchor.id) continue;

      // Skip artifacts with no tags
      if (candidate.tags.isEmpty) continue;

      // Find shared tags
      final candidateTags = candidate.tags.toSet();
      final shared = anchorTags.intersection(candidateTags);

      // Only create relationship if tags overlap
      if (shared.isNotEmpty) {
        relationships.add(
          ArtifactRelationship(
            source: anchor,
            target: candidate,
            sharedTags: shared,
          ),
        );
      }
    }

    // Sort by strength descending
    relationships.sort((a, b) => b.strength.compareTo(a.strength));

    return RelatedArtifactCluster(anchor: anchor, relationships: relationships);
  }

  /// Find all artifacts in the same connected component
  /// Uses breadth-first search through tag relationships
  List<Artifact> findConnectedNetwork(
    Artifact start,
    List<Artifact> allArtifacts,
  ) {
    final visited = <int>{};
    final queue = <Artifact>[start];
    final network = <Artifact>[];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (visited.contains(current.id)) continue;
      visited.add(current.id);
      network.add(current);

      // Find all directly connected artifacts
      final cluster = findRelatedArtifacts(current, allArtifacts);
      for (final rel in cluster.relationships) {
        if (!visited.contains(rel.target.id)) {
          queue.add(rel.target);
        }
      }
    }

    return network;
  }

  /// Analyze which tags tend to appear together
  /// Returns map of tag -> map of co-occurring tag -> count
  Map<String, Map<String, int>> analyzeTagCooccurrence(
    List<Artifact> artifacts,
  ) {
    final cooccurrence = <String, Map<String, int>>{};

    for (final artifact in artifacts) {
      if (artifact.tags.length < 2) continue;

      // For each pair of tags in this artifact
      for (var i = 0; i < artifact.tags.length; i++) {
        for (var j = i + 1; j < artifact.tags.length; j++) {
          final tag1 = artifact.tags[i];
          final tag2 = artifact.tags[j];

          // Increment both directions
          cooccurrence.putIfAbsent(tag1, () => {});
          cooccurrence[tag1]![tag2] = (cooccurrence[tag1]![tag2] ?? 0) + 1;

          cooccurrence.putIfAbsent(tag2, () => {});
          cooccurrence[tag2]![tag1] = (cooccurrence[tag2]![tag1] ?? 0) + 1;
        }
      }
    }

    return cooccurrence;
  }

  /// Find artifacts that bridge different topic clusters
  /// These are artifacts with diverse tags that don't usually appear together
  List<Artifact> findBridgeArtifacts(List<Artifact> artifacts) {
    final cooccurrence = analyzeTagCooccurrence(artifacts);
    final bridges = <Artifact>[];

    for (final artifact in artifacts) {
      if (artifact.tags.length < 2) continue;

      // Calculate average co-occurrence for this artifact's tags
      var totalCooccurrence = 0;
      var pairCount = 0;

      for (var i = 0; i < artifact.tags.length; i++) {
        for (var j = i + 1; j < artifact.tags.length; j++) {
          final tag1 = artifact.tags[i];
          final tag2 = artifact.tags[j];

          totalCooccurrence += cooccurrence[tag1]?[tag2] ?? 0;
          pairCount++;
        }
      }

      // Low average co-occurrence means tags rarely appear together
      // This artifact bridges different clusters
      if (pairCount > 0) {
        final avgCooccurrence = totalCooccurrence / pairCount;
        if (avgCooccurrence < 2.0) {
          bridges.add(artifact);
        }
      }
    }

    return bridges;
  }

  /// Suggest tags based on artifacts that share tags with current artifact
  Set<String> suggestTags(Artifact artifact, List<Artifact> allArtifacts) {
    if (artifact.tags.isEmpty) return {};

    final suggestions = <String, int>{};
    final currentTags = artifact.tags.toSet();

    // Find related artifacts
    final cluster = findRelatedArtifacts(artifact, allArtifacts);

    // Collect tags from related artifacts
    for (final rel in cluster.relationships) {
      // Weight suggestions by relationship strength
      final weight = (rel.strength * 10).round();

      for (final tag in rel.target.tags) {
        if (!currentTags.contains(tag)) {
          suggestions[tag] = (suggestions[tag] ?? 0) + weight;
        }
      }
    }

    // Sort by frequency and return top suggestions
    final sorted = suggestions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toSet();
  }
}
