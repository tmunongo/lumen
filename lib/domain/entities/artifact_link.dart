import 'package:isar/isar.dart';

part 'artifact_link.g.dart';

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

  DateTime? createdAt;

  /// Optional note explaining why this link exists
  String? note;

  ArtifactLink({
    required this.sourceArtifactId,
    required this.targetArtifactId,
    required this.projectId,
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
}
