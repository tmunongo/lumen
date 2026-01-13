import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/tag.dart';
import 'package:lumen/domain/repositories/tag_repository.dart';

class IsarTagRepository implements TagRepository {
  final Isar isar;

  IsarTagRepository(this.isar);

  @override
  Future<Tag> create(Tag tag) async {
    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
    return tag;
  }

  @override
  Future<Tag?> findById(int id) async {
    return await isar.tags.get(id);
  }

  @override
  Future<Tag?> findByName(int projectId, String name) async {
    final normalized = name.trim().toLowerCase();
    return await isar.tags
        .filter()
        .projectIdEqualTo(projectId)
        .nameEqualTo(normalized)
        .findFirst();
  }

  @override
  Future<List<Tag>> findByProject(int projectId) async {
    return await isar.tags
        .filter()
        .projectIdEqualTo(projectId)
        .sortByUsageCountDesc()
        .findAll();
  }

  @override
  Future<void> update(Tag tag) async {
    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.tags.delete(id);
    });
  }
}
