import 'package:lumen/domain/entities/artifact.dart';

abstract class ArtifactRepository {
  Future<Artifact> create(Artifact artifact);
  Future<Artifact?> findById(int id);
  Future<List<Artifact>> findByProject(int projectId);
  Future<List<Artifact>> findByTag(int projectId, String tag);
  Future<List<Artifact>> findByTags(int projectId, List<String> tags);
  Future<void> update(Artifact artifact);
  Future<void> delete(int id);
}
