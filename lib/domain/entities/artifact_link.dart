import 'package:isar/isar.dart';

part 'artifact_link.g.dart';

/// Types of relationships between artifacts
enum LinkType {
  related,     // General connection (default)
  supports,    // Evidence or supporting material
  contradicts, // Conflicting information
  background,  // Prerequisite/context reading
  quotes,      // Source of a quote
  dependsOn,   // Technical dependency
}

/// Explicit link between two artifacts.
/// Links are directional but the system treats them as bidirectional
/// by querying both outgoing and incoming links.
@collection
class ArtifactLink {
  Id id = Isar.autoIncrement;

  /// The artifact that created the link
  @Index()
  late int sourceArtifactId;

  /// The artifact being linked to
  @Index()
  late int targetArtifactId;

  /// Project scope for efficient queries
  @Index()
  late int projectId;

  /// Type of relationship
  @Enumerated(EnumType.name)
  LinkType type = LinkType.related;

  DateTime? createdAt;

  /// Optional note explaining why this link exists
  String? note;

  ArtifactLink({
    required this.sourceArtifactId,
    required this.targetArtifactId,
    required this.projectId,
    this.type = LinkType.related,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArtifactLink &&
        other.sourceArtifactId == sourceArtifactId &&
        other.targetArtifactId == targetArtifactId;
  }

  @override
  int get hashCode => sourceArtifactId.hashCode ^ targetArtifactId.hashCode;

  /// Get human-readable label for this link type
  String get typeLabel {
    switch (type) {
      case LinkType.related:
        return 'Related';
      case LinkType.supports:
        return 'Supports';
      case LinkType.contradicts:
        return 'Contradicts';
      case LinkType.background:
        return 'Background';
      case LinkType.quotes:
        return 'Quotes';
      case LinkType.dependsOn:
        return 'Depends On';
    }
  }
}

