import 'package:lumen/domain/entities/artifact.dart';

class ArtifactRelationship {
  final Artifact source;
  final Artifact target;
  final Set<String> sharedTags;
  final double strength;

  ArtifactRelationship({
    required this.source,
    required this.target,
    required this.sharedTags,
  }) : strength = _calculateStrength(source, target, sharedTags);

  static double _calculateStrength(
    Artifact source,
    Artifact target,
    Set<String> sharedTags,
  ) {
    // Jaccard similarity: intersection / union
    final sourceTags = source.tags.toSet();
    final targetTags = target.tags.toSet();
    final union = sourceTags.union(targetTags);

    if (union.isEmpty) return 0.0;

    return sharedTags.length / union.length;
  }

  bool get isStrong => strength >= 0.5;
  bool get isMedium => strength >= 0.25 && strength < 0.5;
  bool get isWeak => strength < 0.25;
}

class RelatedArtifactCluster {
  final Artifact anchor;
  final List<ArtifactRelationship> relationships;

  RelatedArtifactCluster({required this.anchor, required this.relationships});

  List<ArtifactRelationship> get strongRelationships =>
      relationships.where((r) => r.isStrong).toList();

  List<ArtifactRelationship> get mediumRelationships =>
      relationships.where((r) => r.isMedium).toList();

  List<ArtifactRelationship> get weakRelationships =>
      relationships.where((r) => r.isWeak).toList();

  int get totalRelated => relationships.length;
}
