import 'package:lumen/domain/entities/tag.dart';

abstract class TagRepository {
  Future<Tag> create(Tag tag);
  Future<Tag?> findById(int id);
  Future<Tag?> findByName(int projectId, String name);
  Future<List<Tag>> findByProject(int projectId);
  Future<void> update(Tag tag);
  Future<void> delete(int id);
}
