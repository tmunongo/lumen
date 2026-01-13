import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/repositories/project_repository.dart';

class IsarProjectRepository implements ProjectRepository {
  final Isar isar;

  IsarProjectRepository(this.isar);

  @override
  Future<Project> create(Project project) async {
    await isar.writeTxn(() async {
      await isar.projects.put(project);
    });
    return project;
  }

  @override
  Future<Project?> findById(int id) async {
    return await isar.projects.get(id);
  }

  @override
  Future<Project?> findByName(String name) async {
    return await isar.projects.filter().nameEqualTo(name).findFirst();
  }

  @override
  Future<List<Project>> findAll({bool includeArchived = false}) async {
    if (includeArchived) {
      return await isar.projects.where().findAll();
    }
    return await isar.projects.filter().isArchivedEqualTo(false).findAll();
  }

  @override
  Future<void> update(Project project) async {
    await isar.writeTxn(() async {
      await isar.projects.put(project);
    });
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.projects.delete(id);
    });
  }
}
