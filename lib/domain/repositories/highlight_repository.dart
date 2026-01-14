import 'package:lumen/domain/entities/artifact_highlight.dart';

abstract interface class HighlightRepository {
  Future<ArtifactHighlight> create(ArtifactHighlight highlight);
  Future<void> delete(int id);
  Future<List<ArtifactHighlight>> findByArtifact(int artifactId);
  Future<void> update(ArtifactHighlight highlight);
}
