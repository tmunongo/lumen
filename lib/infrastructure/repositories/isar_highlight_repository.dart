import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/artifact_highlight.dart';
import 'package:lumen/domain/repositories/highlight_repository.dart';

class IsarHighlightRepository implements HighlightRepository {
  final Isar _isar;

  IsarHighlightRepository(this._isar);

  @override
  Future<ArtifactHighlight> create(ArtifactHighlight highlight) async {
    await _isar.writeTxn(() async {
      await _isar.artifactHighlights.put(highlight);
    });
    return highlight;
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await _isar.artifactHighlights.delete(id);
    });
  }

  @override
  Future<List<ArtifactHighlight>> findByArtifact(int artifactId) async {
    return await _isar.artifactHighlights
        .filter()
        .artifactIdEqualTo(artifactId)
        .sortByCreatedAt()
        .findAll();
  }

  @override
  Future<void> update(ArtifactHighlight highlight) async {
    await _isar.writeTxn(() async {
      await _isar.artifactHighlights.put(highlight);
    });
  }
}
